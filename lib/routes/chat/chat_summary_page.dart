import 'package:flutter/material.dart';
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
  bool isCalendarView = true;

  @override
  void initState() {
    super.initState();
    chatSummary = ChatSummary(widget.userId);
    chatSummary.fetchAndCacheAllMessages().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("会話履歴"),
        actions: [
          IconButton(
            icon: Icon(isCalendarView ? Icons.list : Icons.calendar_month),
            onPressed: () {
              setState(() => isCalendarView = !isCalendarView);
            },
          ),
        ],
      ),
      body: isCalendarView
          ? Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, _) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },

            calendarStyle: const CalendarStyle(
              cellMargin: EdgeInsets.symmetric(vertical: 4.0),
            ),

            daysOfWeekStyle: const DaysOfWeekStyle(
              dowTextFormatter: null, // デフォルトの曜日表示にする
              weekdayStyle: TextStyle(fontSize: 12), // 曜日の文字サイズ調整
              weekendStyle: TextStyle(fontSize: 12),
            ),

            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                chatSummary.generateSummary(
                  "${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}",
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
          return ListTile(
            title: Text(item['date']!),
            subtitle: Text(item['summary']!),
          );
        },
      ),
    );
  }
}



