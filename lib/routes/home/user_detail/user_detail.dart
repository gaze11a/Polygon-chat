import 'package:flutter/material.dart';
import 'package:polygon/routes/home/user_detail/user_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polygon/routes/chat/chat.dart';

import '../../../main.dart';

class UserDetail extends StatelessWidget {
  final String title;
  final String imageURL;
  final String headerURL;
  final String comment;

  const UserDetail(this.title, this.imageURL, this.headerURL, this.comment, {super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: UserDetailPage(title, imageURL, headerURL, comment),
      ),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  final String title;
  final String imageURL;
  final String headerURL;
  final String comment;

  const UserDetailPage(this.title, this.imageURL, this.headerURL, this.comment, {super.key});

  @override
  UserDetailPageState createState() => UserDetailPageState();
}

class UserDetailPageState extends State<UserDetailPage> {
  late final String title;
  late final String imageURL;
  late final String headerURL;
  late final String comment;

  String username = '';
  bool isFriend = false;
  bool isRequestSent = false;
  bool isSelf = false;

  String roomName = '';
  bool block = false;
  List<String> blockUser = [];

  bool chat = false;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    imageURL = widget.imageURL;
    headerURL = widget.headerURL;
    comment = widget.comment;
    getData();
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? '';
      isSelf = (username == title);
    });
    if (!isSelf) {
      checkFriendStatus();
    }
  }

  void checkFriendStatus() {
    FirebaseFirestore.instance
        .collection('user')
        .doc(username)
        .collection('friends')
        .doc(title)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() => isFriend = true);
      } else {
        setState(() => isFriend = false);
      }
    });
  }

  Future<void> sendFriendRequest() async {
    await FirebaseFirestore.instance.collection('friend_requests').add({
      'sender': username,
      'receiver': title,
      'timestamp': FieldValue.serverTimestamp(),
    });
    setState(() => isRequestSent = true);
  }

  Widget friendRequestButton() {
    if (isSelf) {
      return const Text("これはあなたのプロフィールです", style: TextStyle(color: Colors.grey, fontSize: 16));
    }
    if (isFriend) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(shape: const StadiumBorder(), backgroundColor: Colors.green),
        child: const Text('二人だけで会話',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        onPressed: () async {
          debugPrint("ボタンが押されました");

          await makeChat(); // ここで完全にデータ取得を待つ
          debugPrint("makeChat() の処理完了");

          if (!mounted) {
            debugPrint("コンテキストが失われています。画面遷移をスキップ");
            return;
          }

          debugPrint("Chat画面に遷移します");
          Navigator.of(navigatorKey.currentContext!).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Chat(
                opponent: title,
                room: compString(username, title),
                chatCompUrl: imageURL,
                block: block,
                blockUser: blockUser,
              ),
            ),
          );
          debugPrint("画面遷移完了");
        },
      );
    } else if (isRequestSent) {
      return const Text("フレンド申請中", style: TextStyle(color: Colors.orange, fontSize: 16));
    } else {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(shape: const StadiumBorder(), backgroundColor: Colors.blue),
        onPressed: sendFriendRequest,
        child: const Text('フレンド申請を送信', style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }
  }

  Future<void> makeChat() async {
    if (username.isEmpty) {
      debugPrint("username が取得できていません。処理を中断します。");
      return;
    }

    roomName = compString(username, title);
    debugPrint("生成された room name: $roomName");

    try {
      final stopwatch = Stopwatch()..start();
      DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.collection('room').doc(roomName).get();
      stopwatch.stop();
      debugPrint("Firestore get() 実行時間: ${stopwatch.elapsedMilliseconds}ms");

      if (!docSnapshot.exists) {
        debugPrint("チャットルームを作成します: $roomName");
        await FirebaseFirestore.instance.collection('room').doc(roomName).set({
          'member': [username, title],
          'block': false,
          'blockuser': [],
        });
        block = false;
        blockUser = [];
      } else {
        debugPrint("既存のチャットルームを取得: $roomName");
        final data = docSnapshot.data() as Map<String, dynamic>?;

        if (data == null) {
          debugPrint("Firestore のデータが null です。処理を中断します。");
          return;
        }

        block = data['block'] ?? false;
        blockUser = (data['blockuser'] as List<dynamic>?)?.cast<String>() ?? [];
        debugPrint("取得したデータ - block: $block, blockuser: $blockUser");
      }
      debugPrint("Firestore からのデータ取得完了");
    } catch (e) {
      debugPrint("Firestore でエラーが発生: $e");
      return;

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          UserHeader(userHeader: headerURL, userImage: imageURL),
          const SizedBox(height: 20),
          friendRequestButton(),
        ],
      ),
    );
  }

  String compString(String a, String b) {
    return (a.compareTo(b) > 0) ? (b + a) : (a + b);
  }
}
