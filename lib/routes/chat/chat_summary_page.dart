import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:polygon/routes/chat/chat_summary.dart';
import 'package:table_calendar/table_calendar.dart';

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

  late final Future<void> _initialization;  // クラス内に定義

  @override
  void initState() {
    super.initState();
    _initialization = initializeAndFetch();
    _loadViewPreference();
  }

  Future<void> initializeAndFetch() async {
    await Firebase.initializeApp();  // 追加で初期化を確実に待つ
    chatSummary = ChatSummary(widget.userId);
    await chatSummary.fetchAndCacheAllMessages();
    setState(() {});
  }


  Future<void> _loadViewPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCalendarView =
          prefs.getBool('chat_summary_view') ?? false; // デフォルトはリストビュー
    });
  }

  Future<void> _saveViewPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chat_summary_view', value);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization, // 初期化とメッセージ取得を待つ
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("エラー: ${snapshot.error}")),
          );
        }

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
          body: isCalendarView ? _buildCalendarView() : _buildListView(),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return Column(
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
                  ),
                ],
              ),
              child: FutureBuilder<String>(
                future: chatSummary.generateSummary(
                  "${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}",
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text("エラー: ${snapshot.error}");
                  }
                  return Text(
                    snapshot.data ?? "要約がありません",
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return FutureBuilder<List<Map<String, String>>>(
      future: chatSummary.getAllSummaries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("エラー: ${snapshot.error}"));
        }
        final items = snapshot.data ?? [];
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['date']!, // 日付を表示
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['summary']!.split('\n')[0], // タイトル部分
                      style: const TextStyle(
                        fontSize: 15, // タイトルのフォントサイズを大きく
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  item['summary']!.split('\n').skip(1).join('\n'), // 要約部分
                  style: const TextStyle(fontSize: 12),
                ),
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
              ),
            );
          },
        );
      },
    );
  }
}
