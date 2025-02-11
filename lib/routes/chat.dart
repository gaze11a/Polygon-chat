import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatefulWidget {
  final String opponent;
  final String room;
  final String chatcompUrl;
  bool block;
  List<String> blockuser;

  Chat({
    Key? key,
    required this.opponent,
    required this.room,
    required this.chatcompUrl,
    this.block = false,
    this.blockuser = const [],
  }) : super(key: key);

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  String image = '';
  final TextEditingController messageController = TextEditingController();

  String? username;
  String? usermail;
  String? userimage;

  @override
  void initState() {
    super.initState();
    getData();
    sendInitialMessage(); // 🔥 画面遷移時に最初のメッセージを送信
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? '';
      usermail = prefs.getString('mail') ?? '';
    });
  }

  Future<void> sendInitialMessage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('room')
        .doc(widget.room)
        .collection(widget.room)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("Firestore: 初回メッセージを送信");
      await addMessageToFirebase('system', "チャットが開始されました。");
    } else {
      print("Firestore: 既にメッセージが存在するため送信しません");
    }
  }

  Future<void> addMessageToFirebase(String type, String content) async {
    if (content.isNotEmpty) {
      print("Firestore へのメッセージ送信開始: $content");

      try {
        await FirebaseFirestore.instance
            .collection('room')
            .doc(widget.room)
            .collection(widget.room) // ← Firestore にメッセージを追加
            .add({
          'type': type,
          'name': username,
          'content': content,
          'date': Timestamp.now(),
        });

        await FirebaseFirestore.instance.collection('room').doc(widget.room).update({
          'createdAt': Timestamp.now(),
          'lastMessage': content,
        });

        print("Firestore へのメッセージ送信成功");
      } catch (e) {
        print("Firestore へのメッセージ送信エラー: $e");
      }
    } else {
      print("メッセージが空のため送信しませんでした");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Model>(
      create: (_) => Model(),
      child: Consumer<Model>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: const Color.fromRGBO(68, 114, 196, 1.0),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.opponent,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: widget.block
                ? Center(child: Text('${widget.opponent}をブロックしています'))
                : Column(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('room')
                        .doc(widget.room)
                        .collection(widget.room) // Firestore の `messages` をリアルタイム取得
                        .where('date', isNotEqualTo: null) // 🔥 `date` がないデータを防ぐ
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var messages = snapshot.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var messageData = messages[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(messageData['name']),
                            subtitle: Text(messageData['content']),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'メッセージを入力',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          String content = messageController.text.trim();
                          if (content.isNotEmpty) {
                            await addMessageToFirebase('text', content); // 🔥 `messageController.text` を直接渡す
                            messageController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
