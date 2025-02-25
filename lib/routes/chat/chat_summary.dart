import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatSummary {
  final String userId;
  final Map<String, List<String>> _cachedMessages = {};
  final bool useOpenAI;

  ChatSummary(this.userId, {this.useOpenAI = true});

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
      String dateKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      _cachedMessages.putIfAbsent(dateKey, () => []).add(doc['content']);
    }
  }

  // 🔹 OpenAI APIにリクエストして要約を作成
  Future<String> generateSummary(String dateKey) async {
    var messages = _cachedMessages[dateKey] ?? [];
    if (messages.isEmpty) return "この日はメッセージがありません。";

    // 🔥 OpenAI APIを使わない場合は、簡易要約を返す
    if (!useOpenAI) {
      return "会話要約: ${messages.take(3).join(' ')}"; // 最初の3件をつなげる
    }

    // 🔹 Firestoreに要約があるかチェック
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('room')
        .doc(userId)
        .collection('summary')
        .doc(dateKey)
        .get();

    if (doc.exists) {
      return doc['summary'];
    }

    // 🔥 OpenAI APIで要約を生成
    const String apiKey = String.fromEnvironment("OPENAI_API_KEY", defaultValue: "NOT_SET");
    const String apiUrl = "https://api.openai.com/v1/chat/completions";

    const prompt = '''
以下の会話を要約してください。
- まず、一言で内容がわかるタイトルをつけること
- その下に、簡潔な要約を書く
- もし会話が挨拶だけなら「【挨拶】簡単な挨拶のみ」などとする
- 雑談や重要な話の場合は、要点を短くまとめる
- なるべく分かりやすい言葉で表現する
''';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {"role": "system", "content": prompt},
          {"role": "user", "content": messages.join("\n")}
        ],
        "max_tokens": 100,
      }),
    );

    debugPrint("OpenAI API Response: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      String summary = data["choices"][0]["message"]["content"];

      // Firestoreに要約を保存
      await FirebaseFirestore.instance
          .collection('room')
          .doc(userId)
          .collection('summary')
          .doc(dateKey)
          .set({
        'summary': summary,
        'createdAt': Timestamp.now(),
      });

      return summary;
    } else {
      throw Exception("Failed to fetch summary: ${response.body}");
    }
  }

  // 🔹 全要約リスト取得
  Future<List<Map<String, String>>> getAllSummaries() async {
    QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('room')
        .doc(userId)
        .collection('summary')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshots.docs
        .map((doc) => {
              'date': doc.id,
              'summary': doc['summary'] as String,
            })
        .toList();
  }
}
