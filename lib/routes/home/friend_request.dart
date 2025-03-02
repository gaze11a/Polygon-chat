import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendRequests extends StatelessWidget {
  const FriendRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FriendRequestsPage(),
    );
  }
}

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  FriendRequestsPageState createState() => FriendRequestsPageState();
}

class FriendRequestsPageState extends State<FriendRequestsPage> {
  String username = '';

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  Future<void> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "フレンドリクエスト",
          style: TextStyle(color: Color.fromRGBO(100, 205, 250, 1.0), fontWeight: FontWeight.bold),
        ),
      ),
      body: buildFriendRequests(),
    );
  }

  Widget buildFriendRequests() {
    if (username.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiver', isEqualTo: username)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('エラーが発生しました'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              '受け取ったフレンドリクエストはありません',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((document) {
            final data = document.data() as Map<String, dynamic>;
            String sender = data['sender'];
            return buildRequestTile(sender, document.id);
          }).toList(),
        );
      },
    );
  }

  Widget buildRequestTile(String sender, String requestId) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(sender, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => acceptFriendRequest(sender, requestId),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => declineFriendRequest(requestId),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> acceptFriendRequest(String sender, String requestId) async {
    try {
      // 自分のフレンドリストに追加
      await FirebaseFirestore.instance.collection('user').doc(username).collection('friends').doc(sender).set({
        'friend_id': sender,
        'added_at': FieldValue.serverTimestamp(),
      });

      // 相手のフレンドリストに追加
      await FirebaseFirestore.instance.collection('user').doc(sender).collection('friends').doc(username).set({
        'friend_id': username,
        'added_at': FieldValue.serverTimestamp(),
      });

      // フレンドリクエストを削除
      await FirebaseFirestore.instance.collection('friend_requests').doc(requestId).delete();

      setState(() {}); // UIを更新
    } catch (e) {
      debugPrint("フレンドリクエスト承認エラー: $e");
    }
  }

  Future<void> declineFriendRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('friend_requests').doc(requestId).delete();
      setState(() {});
    } catch (e) {
      debugPrint("[ERROR] フレンドリクエスト拒否失敗: $e");
    }
  }
}
