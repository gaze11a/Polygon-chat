import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polygon/polygon_drawer.dart';
import 'package:polygon/routes/home/common_list.dart';
import 'package:polygon/routes/home/home_grid/home_tile.dart';
import 'package:polygon/routes/home/user_detail/user_detail.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget appBarTitle = const Text(
    "ホーム",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: const PolygonDrawer(),
      appBar: buildAppBar(),
      body: _isSearching ? buildSearchResults() : const CommonList(), // タブの代わりに CommonList を表示
    );
  }

  Widget buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .orderBy('title')
          .startAt([input])
          .endAt(['$input\\uf8ff'])
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('エラーが発生しました'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
      ],
    );
  }

  void toggleSearch() {
    setState(() {
      if (_isSearching) {
        icon = const Icon(Icons.search, color: Colors.blueGrey);
        appBarTitle = const Text(
          "ホーム",
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
