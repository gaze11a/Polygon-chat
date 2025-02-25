import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:polygon/routes/chat/chat_summary.dart';

class ChatSummaryPage extends StatefulWidget {
  final String userId;

  const ChatSummaryPage({super.key, required this.userId});

  @override
  ChatSummaryPageState createState() => ChatSummaryPageState();
}

class ChatSummaryPageState extends State<ChatSummaryPage> {
  late ChatSummary chatSummary;
  DateTime _selectedDay = DateTime.now();
  bool isCalendarView = false; // 初期設定をリストビューに変更

  @override
  void initState() {
    super.initState();
    chatSummary = ChatSummary(widget.userId);
    chatSummary.fetchAndCacheAllMessages().then((_) {
      setState(() {});
    });
    _loadViewPreference();
  }

  Future<void> _loadViewPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCalendarView = prefs.getBool('chat_summary_view') ?? false; // デフォルトはリストビュー
    });
  }

  Future<void> _saveViewPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chat_summary_view', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text(
          "会話履歴",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(68, 114, 196, 1.0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.list, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isCalendarView = false;
                  });
                  _saveViewPreference(false);
                },
              ),
              Switch(
                value: isCalendarView,
                onChanged: (value) {
                  setState(() {
                    isCalendarView = value;
                  });
                  _saveViewPreference(value);
                },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isCalendarView = true;
                  });
                  _saveViewPreference(true);
                },
              ),
            ],
          ),
        ],
      ),
      body: isCalendarView
          ? Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, _) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                ),
                cellMargin: const EdgeInsets.symmetric(vertical: 4.0),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                dowTextFormatter: null,
                weekdayStyle: TextStyle(fontSize: 12),
                weekendStyle: TextStyle(fontSize: 12),
              ),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Text(
                  chatSummary.generateSummary(
                    "${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}",
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      )
          : ListView.builder(
        itemCount: chatSummary.getAllSummaries().length,
        itemBuilder: (context, index) {
          var item = chatSummary.getAllSummaries()[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: ListTile(
              title: Text(
                item['date']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item['summary']!),
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}
