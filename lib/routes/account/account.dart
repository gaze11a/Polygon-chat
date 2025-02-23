import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polygon/loading_dialog.dart';
import 'package:polygon/routes/home/user_detail/user_header.dart';
import 'package:polygon/routes/home/user_detail/user_name.dart';
import 'package:polygon/routes/home/user_detail/user_name_comment.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AccountPage(),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  late String username;
  late String userMail;
  late String userImage;
  late String userHeader;
  late String comment;
  late Future<void> futureData;

  bool edit = false;

  @override
  void initState() {
    super.initState();
    futureData = getData(); // 🔹 データ取得の `Future`
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadingDialog(context); // 🔹 `initState` の後にローディングを表示
    });
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('name') ?? '';
    userMail = prefs.getString('mail') ?? '';
    userImage = prefs.getString('image') ?? '';
    userHeader = prefs.getString('header') ?? '';
    comment = prefs.getString('comment') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            edit ? "アカウントを編集" : "アカウント",
            style: TextStyle(
              color: edit ? Colors.black : const Color.fromRGBO(100, 205, 250, 1.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: edit
              ? IconButton(
            icon: const Icon(Icons.close, color: Colors.blueGrey),
            onPressed: () {
              setState(() {
                edit = false;
              });
            },
          )
              : const SizedBox(),
          actions: [
            edit
                ? TextButton(
              child: const Text(
                "保存",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onPressed: () async {
                loadingDialog(context); // 🔹 ローディング開始

                await getData();

                await FirebaseFirestore.instance.collection('user').doc(username).update({
                  'title': username,
                  'imageURL': userImage,
                  'headerURL': userHeader,
                  'comment': comment,
                  'mail': userMail,
                  'createdAt': Timestamp.now(),
                });

                closeLoadingDialog(context); // 🔹 ローディングダイアログを閉じる

                if (context.mounted) {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('保存完了'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              setState(() {
                                edit = false;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            )
                : TextButton(
              child: const Text(
                "編集",
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              onPressed: () {
                setState(() {
                  edit = true;
                });
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: futureData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(); // 何も表示しない
            } else {
              closeLoadingDialog(context); // 🔹 ローディングダイアログを閉じる
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    SizedBox(
                      width: size.width,
                      height: size.height,
                      child: Image.asset('assets/polygon.jpg'),
                    ),
                    Column(
                      children: [
                        UserHeader(userheader: userHeader, userimage: userImage),
                        comment.isNotEmpty ? UserNameComment(username, comment) : UserName(username),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Center(
                            child: Text(userMail),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
