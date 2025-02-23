import 'package:flutter/material.dart';
import 'package:polygon/routes/home/user_detail/user_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polygon/routes/chat.dart';

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
  UserDetailPageState createState() =>
      UserDetailPageState(title, imageURL, headerURL, comment);
}

class UserDetailPageState extends State<UserDetailPage> {
  final String title;
  final String imageURL;
  final String headerURL;
  final String comment;

  UserDetailPageState(this.title, this.imageURL, this.headerURL, this.comment);

  String username = '';
  String usermail = '';
  String userimage = '';
  String roomname = '';
  bool block = false;
  List<String> blockuser = [];

  bool chat = false;

  // Function to generate a unique room name
  String compString(String a, String b) {
    return (a.compareTo(b) > 0) ? (b + a) : (a + b);
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? '';
      usermail = prefs.getString('mail') ?? '';
      userimage = prefs.getString('image') ?? '';
      chat = username != title;
    });
  }

  Future<void> makeChat() async {
    if (username.isEmpty) {
      debugPrint("username が取得できていません。処理を中断します。");
      return;
    }

    roomname = compString(username, title);
    debugPrint("生成された roomname: $roomname");

    try {
      final stopwatch = Stopwatch()..start();
      DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.collection('room').doc(roomname).get();
      stopwatch.stop();
      debugPrint("Firestore get() 実行時間: ${stopwatch.elapsedMilliseconds}ms");

      if (!docSnapshot.exists) {
        debugPrint("チャットルームを作成します: $roomname");
        await FirebaseFirestore.instance.collection('room').doc(roomname).set({
          'member': [username, title],
          'block': false,
          'blockuser': [],
        });
        block = false;
        blockuser = [];
      } else {
        debugPrint("既存のチャットルームを取得: $roomname");
        final data = docSnapshot.data() as Map<String, dynamic>?;

        if (data == null) {
          debugPrint("Firestore のデータが null です。処理を中断します。");
          return;
        }

        block = data['block'] ?? false;
        blockuser = (data['blockuser'] as List<dynamic>?)?.cast<String>() ?? [];
        debugPrint("取得したデータ - block: $block, blockuser: $blockuser");
      }

      debugPrint("Firestore からのデータ取得完了");
    } catch (e) {
      debugPrint("Firestore でエラーが発生: $e");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();

    return Hero(
      tag: 'list$title',
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            UserHeader(userheader: headerURL, userimage: imageURL),
            //comment.isNotEmpty ? UserNameComment(title, comment) : UserName(title),
            chat ? talkButton(context) : Container(),
          ],
        ),
      ),
    );
  }

  Widget talkButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 7.0,
        shape: const StadiumBorder(),
        backgroundColor: Colors.green,
      ),
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
              chatcompUrl: imageURL,
              block: block,
              blockuser: blockuser,
            ),
          ),
        );
        debugPrint("画面遷移完了");
      },
    );
  }
}
