import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polygon/routes/home/user_detail/user_detail.dart';
import 'package:polygon/routes/home/user_tile/home_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer/polygon_drawer.dart';
import 'friend_request.dart';

class FriendList extends StatelessWidget {
  const FriendList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FriendListPage(),
    );
  }
}

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  FriendListPageState createState() => FriendListPageState();
}

class FriendListPageState extends State<FriendListPage> {
  Widget appBarTitle = const Text(
    "フレンド",
    style: TextStyle(
      color: Color.fromRGBO(100, 205, 250, 1.0),
      fontWeight: FontWeight.bold,
    ),
  );
  Icon icon = const Icon(Icons.search, color: Colors.blueGrey);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;
  String input = '';

  String username = '';

  @override
  void initState() {
    super.initState();
    getUsername(); // ← ここでusernameを取得する
  }

  Future<void> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? ''; // ← ここで取得
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: const PolygonDrawer(),
      appBar: buildAppBar(),
      body: _isSearching ? buildSearchResults() : buildFriendList(),
    );
  }

  Widget buildFriendList() {
    if (username.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .doc(username)
          .collection('friends')
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
              'まだフレンドがいません',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((document) {
            final data = document.data() as Map<String, dynamic>;
            String friendId = data['friend_id']; // 🔥 ここで friend_id を取得
            return buildFriendTile(friendId); // 🔥 friend_id を渡してユーザー情報を取得
          }).toList(),
        );
      },
    );
  }


  Widget buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .orderBy('title')
          .startAt([input])
          .endAt(['$input\uf8ff'])
          .limit(20)
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
              'ユーザーが見つかりません',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((document) {
            final data = document.data() as Map<String, dynamic>;
            return buildUserTile(data);
          }).toList(),
        );
      },
    );
  }

  Widget buildFriendTile(String friendId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('user').doc(friendId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        String title = userData['title'];
        String imageURL = userData['imageURL'];
        String commentText = userData['comment'];

        return Hero(
          tag: 'friend_$title',
          child: GestureDetector(
            child: HomeTile(title, imageURL, commentText), // フレンド表示用 UI
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetail(
                    title,
                    imageURL,
                    '',
                    commentText,
                  ),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
        );
      },
    );
  }


  Widget buildUserTile(Map<String, dynamic> data) {
    String title = data['title'];
    String imageURL = data['imageURL'];
    String headerURL = data['headerURL'];
    String commentText = data['comment'];

    return Hero(
      tag: 'list$title',
      child: GestureDetector(
        child: HomeTile(title, imageURL, commentText),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetail(
                title,
                imageURL,
                headerURL,
                commentText,
              ),
              fullscreenDialog: true,
            ),
          );
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: appBarTitle,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.blueGrey),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        IconButton(
          icon: icon,
          onPressed: toggleSearch,
        ),
        IconButton(
          icon: const Icon(Icons.group_add, color: Colors.blueGrey),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FriendRequests()),
            );
          },
        ),
      ],
    );
  }

  void toggleSearch() {
    setState(() {
      if (_isSearching) {
        icon = const Icon(Icons.search, color: Colors.blueGrey);
        appBarTitle = const Text(
          "フレンド",
          style: TextStyle(color: Color.fromRGBO(100, 205, 250, 1.0), fontWeight: FontWeight.bold),
        );
        _controller.clear();
        _isSearching = false;
      } else {
        icon = const Icon(Icons.close, color: Colors.blueGrey);
        _isSearching = true;
        appBarTitle = TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.blueGrey),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
            hintText: "すべてのユーザーを検索",
            hintStyle: TextStyle(color: Colors.blueGrey),
          ),
          onChanged: (text) {
            setState(() {
              input = text;
            });
          },
        );
      }
    });
  }
}