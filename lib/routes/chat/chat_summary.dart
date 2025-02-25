import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSummary {
  final String userId;
  Map<String, List<String>> _cachedMessages = {};

  ChatSummary(this.userId);

  // 🔹 全メッセージを一括取得（Firestoreは初回のみ）
  Future<void> fetchAndCacheAllMessages() async {
    QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('room')
        .doc(userId)
        .collection(userId)
        .orderBy('date', descending: true)
        .get();

    for (var doc in snapshots.docs) {
      DateTime date = (doc['date'] as Timestamp).toDate();
      String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      _cachedMessages.putIfAbsent(dateKey, () => []).add(doc['content']);
    }
  }

  // 🔹 キャッシュから特定日の要約取得
  String generateSummary(String dateKey) {
    var messages = _cachedMessages[dateKey] ?? [];
    if (messages.isEmpty) return "この日はメッセージがありません。";
    return "会話要約: ${messages.take(3).join(' ')}"; // AIは後ほどここで置き換え
  }

  // 🔹 全要約リスト取得
  List<Map<String, String>> getAllSummaries() {
    return _cachedMessages.entries.map((entry) => {
      'date': entry.key,
      'summary': generateSummary(entry.key),
    }).toList();
  }

  // 🔹 要約をローカル保存
  Future<void> saveSummariesToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var entry in _cachedMessages.entries) {
      String summary = generateSummary(entry.key);
      await prefs.setString('chat_summary_${entry.key}', summary);
    }
  }
}
