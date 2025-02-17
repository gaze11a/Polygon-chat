import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polygon/routes/home/home_grid/home_tile.dart';
import 'package:polygon/routes/home/user_detail/user_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonListPage(),
    );
  }
}

class CommonListPage extends StatefulWidget {
  @override
  _CommonListPageState createState() => _CommonListPageState();
}

class _CommonListPageState extends State<CommonListPage> {
  bool noChoice = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  // Removed hobbylist logic
  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hobby = prefs.getString('hobby') ?? '';
    setState(() {
      noChoice = hobby.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 130) / 2;
    final double itemWidth = size.width / 2;

    if (noChoice) {
      return const Center(
        child: Text('趣味が選択されていません。設定で選択してください。'),
      );
    }

    // Removed hobby filtering logic
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .snapshots(), // Removed hobby filtering
      builder: (context, snapshot) {
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
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.count(
          padding: const EdgeInsets.all(5.0),
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          crossAxisCount: 2,
          childAspectRatio: itemWidth / itemHeight,
          children: snapshot.data!.docs.map((document) {
            final data = document.data() as Map<String, dynamic>;
            return buildUserTile(data);
          }).toList(),
        );
      },
    );
  }

  Widget buildUserTile(Map<String, dynamic> data) {
    return Hero(
      tag: 'list${data['title']}',
      child: GestureDetector(
        child: HomeTile(
          data['title'],
          data['imageURL'],
          data['comment'],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetail(
                data['title'],
                data['imageURL'],
                data['headerURL'],
                data['comment'],
                [], // Passing an empty list
              ),
              fullscreenDialog: true,
            ),
          );
        },
      ),
    );
  }
}
