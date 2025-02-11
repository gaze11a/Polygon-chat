import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String message = '';
  String image = '';
  final TextEditingController messageController = TextEditingController();

  String? username;
  String? usermail;
  String? userimage;

  String randLetter() {
    const int bigLetterStart = 65;
    const int bigLetterCount = 26;
    var alphabetArray = <String>[];
    var rand = math.Random();
    for (var i = 0; i < 100; i++) {
      int number = rand.nextInt(bigLetterCount);
      int randomNumber = number + bigLetterStart;
      alphabetArray.add(String.fromCharCode(randomNumber));
    }
    return alphabetArray.join('');
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? '';
      usermail = prefs.getString('mail') ?? '';
    });
  }

  Future<void> addMessageToFirebase(String type) async {
    if (message.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('room')
          .doc(widget.room)
          .collection(widget.room)
          .add(
        {
          'type': type,
          'name': username,
          'content': message,
          'date': Timestamp.now(),
        },
      );
      FirebaseFirestore.instance.collection('room').doc(widget.room).update(
        {'createdAt': Timestamp.now(), 'lastMessage': message},
      );
    }
  }

  Future<void> blockUser() async {
    await FirebaseFirestore.instance.collection('room').doc(widget.room).update(
      {
        'block': !widget.block,
        'blockuser': FieldValue.arrayUnion([username])
      },
    );
    setState(() {
      widget.block = !widget.block;
      widget.blockuser.add(username!);
    });
  }

  Future<void> unblockUser() async {
    await FirebaseFirestore.instance.collection('room').doc(widget.room).update(
      {
        'block': !widget.block,
        'blockuser': FieldValue.arrayRemove([username])
      },
    );
    setState(() {
      widget.block = !widget.block;
      widget.blockuser.remove(username);
    });
  }

  Future<void> pushPost(String message) async {
    Map<String, String> headers = {'content-type': 'application/json'};
    String body =
    json.encode({"message": message, "opponent": widget.opponent});
    var url = Uri.parse(
        'https://us-central1-fluttetest-2b5b6.cloudfunctions.net/function-2');

    http.Response resp = await http.post(url, headers: headers, body: body);

    if (resp.statusCode == 500) {
      await Future.delayed(const Duration(seconds: 2));
      await http.post(url, headers: headers, body: body);
    }
  }

  Future<String> sendImageToStorage(File imageFile) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(widget.room)
        .child('${username}_${DateTime.now()}');

    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
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
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.block),
                  tooltip: 'ブロック',
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                              widget.blockuser.contains(username)
                                  ? '${widget.opponent}をブロック解除しますか？'
                                  : '${widget.opponent}をブロックしますか？'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('いいえ'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text('はい', style: TextStyle(color: Colors.red)),
                              onPressed: () async {
                                widget.blockuser.contains(username)
                                    ? await unblockUser()
                                    : await blockUser();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: widget.block
                ? Center(child: Text('${widget.opponent}をブロックしています'))
                : FutureBuilder(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: <Widget>[
                      Expanded(child: Container()), // メッセージリスト
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.photo),
                              onPressed: () async {
                                // 画像送信の処理
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: messageController,
                                decoration: InputDecoration(
                                  hintText: 'メッセージを入力',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onChanged: (text) => message = text,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () async {
                                if (message.isNotEmpty) {
                                  await addMessageToFirebase('text');
                                  messageController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        },
      ),
    );
  }
}
