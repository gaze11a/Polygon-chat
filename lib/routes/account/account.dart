import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polygon/routes/utils/loading_dialog.dart';
import 'package:polygon/routes/home/user_detail/user_header.dart';
import 'package:polygon/routes/home/user_detail/user_name.dart';
import 'package:polygon/routes/home/user_detail/user_name_comment.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../utils/image_choice.dart';

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

  void safeCloseLoadingDialog(BuildContext context) {
    try {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to close loading dialog: $e");
    }
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
                loadingDialog(context);

                try {
                  await getData();

                  await FirebaseFirestore.instance.collection('user').doc(username).update({
                    'title': username,
                    'imageURL': userImage,
                    'headerURL': userHeader,
                    'comment': comment,
                    'mail': userMail,
                    'createdAt': Timestamp.now(),
                  });

                  safeCloseLoadingDialog(navigatorKey.currentContext!);

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
                } catch (e) {
                  debugPrint("[ERROR] Failed to save data: $e");
                  safeCloseLoadingDialog(navigatorKey.currentContext!); // 🔹 エラー時もローディングを閉じる
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
              safeCloseLoadingDialog(context);
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
                        // **🔹 編集モードのときは `ProfileImageChoice` & `HeaderImageChoice` を使う**
                        if (edit) ...[
                          HeaderImageChoice(username, userHeader), // 🔹 ヘッダー画像の変更
                          ProfileImageChoice(username, userImage), // 🔹 プロフィール画像の変更
                        ] else ...[
                          UserHeader(userheader: userHeader, userimage: userImage), // 🔹 通常モードのとき
                        ],
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
