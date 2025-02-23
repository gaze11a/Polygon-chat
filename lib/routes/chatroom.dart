import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat.dart';

class Chatroom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ChatroomPage(),
    );
  }
}

class ChatroomPage extends StatefulWidget {
  const ChatroomPage({Key? key}) : super(key: key);

  @override
  _ChatroomPageState createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  String username = '';
  String usermail = '';
  String userimage = '';
  bool showpaira = false;

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? '';
      usermail = prefs.getString('mail') ?? '';
      userimage = prefs.getString('image') ?? '';
      showpaira = prefs.getBool('showpaira') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(68, 114, 196, 1.0),
          elevation: 0,
          title: const Text(
            "トーク",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: Container(),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('room')
              .where("member", arrayContains: username)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'エラーが発生しました',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${snapshot.error}', // ここでエラーの詳細を表示
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/background.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return Card(
                      child: Tile(
                        roomMember: List<String>.from(data['member']),
                        block: data['block'] ?? false,
                        blockuser: List<String>.from(data['blockuser'] ?? []),
                        name: username,
                        lastMessage: data['lastMessage'] ?? '',
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final List<String> roomMember;
  final bool block;
  final List<String> blockuser;
  final String name;
  final String lastMessage;

  const Tile({
    Key? key,
    required this.roomMember,
    required this.name,
    required this.block,
    required this.blockuser,
    required this.lastMessage,
  }) : super(key: key);

  String compString(String a, String b) {
    return (a.compareTo(b) > 0) ? '$b$a' : '$a$b';
  }

  String removeUser(List<String> data, String name) {
    List<String> filtered = List<String>.from(data)..remove(name);
    return filtered.isNotEmpty ? filtered.first : '';
  }

  Future<String> getUrl(String username) async {
    DocumentSnapshot docSnapshot =
    await FirebaseFirestore.instance.collection('user').doc(username).get();

    Map<String, dynamic>? record = docSnapshot.data() as Map<String, dynamic>?;
    return record?['imageURL'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final String chatCompName = removeUser(roomMember, name);

    return FutureBuilder<String>(
      future: getUrl(chatCompName),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        return Slidable(
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [],
          ),
          child: Container(
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: snapshot.data!.isNotEmpty
                    ? NetworkImage(snapshot.data!)
                    : const AssetImage('assets/preimage.JPG') as ImageProvider,
                backgroundColor: Colors.white,
              ),
              title: Text(chatCompName),
              subtitle: Text(
                lastMessage.isEmpty ? "" : lastMessage,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Chat(
                      opponent: chatCompName,
                      room: compString(name, chatCompName),
                      block: block,
                      blockuser: blockuser,
                      chatcompUrl: snapshot.data!,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
