import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:polygon/routes/utils/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_summary_page.dart';

class Chat extends StatefulWidget {
  final String opponent;
  final String room;
  final String chatCompUrl;
  final bool block;
  final List<String> blockUser;

  const Chat({
    super.key,
    required this.opponent,
    required this.room,
    required this.chatCompUrl,
    this.block = false,
    this.blockUser = const [],
  });

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  String image = '';
  final TextEditingController messageController = TextEditingController();

  String? username;
  String? userMail;
  String? userImage;

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
      userMail = prefs.getString('mail') ?? '';
    });
  }

  Future<String> getUrl(String username) async {
    DocumentSnapshot docSnapshot =
    await FirebaseFirestore.instance.collection('user').doc(username).get();
    Map<String, dynamic>? record = docSnapshot.data() as Map<String, dynamic>?;
    return record?['imageURL'] ?? '';
  }


  Future<void> sendInitialMessage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('room')
        .doc(widget.room)
        .collection(widget.room)
        .get();

    if (querySnapshot.docs.isEmpty) {
      debugPrint("Firestore: 初回メッセージを送信");
      await addMessageToFirebase('system', "チャットが開始されました。");
    } else {
      debugPrint("Firestore: 既にメッセージが存在するため送信しません");
    }
  }

  Future<void> addMessageToFirebase(String type, String content) async {
    if (content.isNotEmpty) {
      debugPrint("Firestore へのメッセージ送信開始: $content");

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

        debugPrint("Firestore へのメッセージ送信成功");
      } catch (e) {
        debugPrint("Firestore へのメッセージ送信エラー: $e");
      }
    } else {
      debugPrint("メッセージが空のため送信しませんでした");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Model>(
      create: (_) => Model(),
      child: Consumer<Model>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.blue.shade50,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: const Color.fromRGBO(68, 114, 196, 1.0),
              elevation: 2,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(widget.opponent,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatSummaryPage(userId: widget.room),
                    ));
                  },
                ),
              ],
            ),
            body: widget.block
                ? Center(
                child: Text('${widget.opponent}をブロックしています',
                    style: const TextStyle(fontSize: 16)))
                : Column(
                children: <Widget>[
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('room')
                          .doc(widget.room)
                          .collection(widget.room)
                          .where('date', isNotEqualTo: null)
                          .orderBy('date', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        var messages = snapshot.data!.docs;
                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var messageData = messages[index].data()
                            as Map<String, dynamic>;
                            bool isMe = messageData['name'] == username;
                            return FutureBuilder<String>(
                              future: getUrl(messageData['name']),
                              builder: (context, imageSnapshot) {
                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment: isMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (!isMe)
                                        CircleAvatar(
                                          backgroundImage: imageSnapshot.hasData && imageSnapshot.data!.isNotEmpty
                                              ? NetworkImage(imageSnapshot.data!)
                                              : const AssetImage('assets/preimage.JPG') as ImageProvider,
                                          radius: 16,
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 12),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Colors.blue.shade300
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade200,
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          messageData['content'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send,
                              color: Colors.blue.shade700),
                          onPressed: () async {
                            String content = messageController.text.trim();
                            if (content.isNotEmpty) {
                              await addMessageToFirebase('text', content);
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
