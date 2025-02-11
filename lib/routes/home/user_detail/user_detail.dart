import 'package:flutter/material.dart';
import 'package:polygon/routes/home/user_detail/user_header.dart';
import 'package:polygon/routes/home/user_detail/user_hobby.dart';
import 'package:polygon/routes/home/user_detail/user_name.dart';
import 'package:polygon/routes/home/user_detail/user_name_comment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polygon/routes/chat.dart';

class UserDetail extends StatelessWidget {
  final String title;
  final String imageURL;
  final String headerURL;
  final String comment;
  final List<String> userlist;

  UserDetail(this.title, this.imageURL, this.headerURL, this.comment, this.userlist);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: UserDetailPage(title, imageURL, headerURL, comment, userlist),
      ),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  final String title;
  final String imageURL;
  final String headerURL;
  final String comment;
  final List<String> userlist;

  UserDetailPage(this.title, this.imageURL, this.headerURL, this.comment, this.userlist);

  @override
  _UserDetailPageState createState() =>
      _UserDetailPageState(title, imageURL, headerURL, comment, userlist);
}

class _UserDetailPageState extends State<UserDetailPage> {
  final String title;
  final String imageURL;
  final String headerURL;
  final String comment;
  final List<String> userlist;

  _UserDetailPageState(this.title, this.imageURL, this.headerURL, this.comment, this.userlist);

  String username = '';
  String usermail = '';
  String userimage = '';
  String roomname = '';
  bool block = false;
  List<String> blockuser = [];

  bool chat = false;

  // Function to generate a unique room name
  String compstring(String a, String b) {
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
      print("username が取得できていません。処理を中断します。");
      return;
    }

    roomname = compstring(username, title);
    print("生成された roomname: $roomname");

    try {
      final stopwatch = Stopwatch()..start();
      DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.collection('room').doc(roomname).get();
      stopwatch.stop();
      print("Firestore get() 実行時間: ${stopwatch.elapsedMilliseconds}ms");

      if (!docSnapshot.exists) {
        print("チャットルームを作成します: $roomname");
        await FirebaseFirestore.instance.collection('room').doc(roomname).set({
          'member': [username, title],
          'block': false,
          'blockuser': [],
        });
        block = false;
        blockuser = [];
      } else {
        print("既存のチャットルームを取得: $roomname");
        final data = docSnapshot.data() as Map<String, dynamic>?;

        if (data == null) {
          print("Firestore のデータが null です。処理を中断します。");
          return;
        }

        block = data['block'] ?? false;
        blockuser = (data['blockuser'] as List<dynamic>?)?.cast<String>() ?? [];
        print("取得したデータ - block: $block, blockuser: $blockuser");
      }

      print("Firestore からのデータ取得完了");
    } catch (e) {
      print("Firestore でエラーが発生: $e");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();

    return Hero(
      tag: 'list' + title,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            UserHeader(userheader: headerURL, userimage: imageURL),
            comment.isNotEmpty ? UserNameComment(title, comment) : UserName(title),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: UserHobby(userlist),
            ),
            chat ? talkbutton(context) : Container(),
          ],
        ),
      ),
    );
  }

  Widget talkbutton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 7.0,
        shape: StadiumBorder(),
        backgroundColor: Colors.green,
      ),
      child: Text('二人だけで会話',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      onPressed: () async {
        print("ボタンが押されました");

        await makeChat(); // ここで完全にデータ取得を待つ
        print("makeChat() の処理完了");

        if (!mounted) {
          print("コンテキストが失われています。画面遷移をスキップ");
          return;
        }

        print("Chat画面に遷移します");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Chat(
              opponent: title,
              room: compstring(username, title),
              chatcompUrl: imageURL,
              block: block,
              blockuser: blockuser,
            ),
          ),
        );
        print("画面遷移完了");
      },
    );
  }
}
