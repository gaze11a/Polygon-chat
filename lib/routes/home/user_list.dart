import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polygon/routes/home/user_detail/user_detail.dart';
import 'package:polygon/routes/home/user_tile/home_tile.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 130) / 2;
    final double itemWidth = size.width / 2;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .orderBy('createdAt', descending: true)
          .limit(60)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('エラーが発生しました'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('ユーザーが見つかりません'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(5.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: (itemWidth / itemHeight),
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            String title = data['title'] ?? '名無し';
            String imageURL = data['imageURL'] ?? '';
            String headerURL = data['headerURL'] ?? '';
            String commentText = data['comment'] ?? '';

            return Hero(
              tag: 'list$title',
              child: GestureDetector(
                child: HomeTile(title, imageURL, commentText),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UserDetail(title, imageURL, headerURL, commentText),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
