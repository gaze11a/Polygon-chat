import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';
import 'package:polygon/routes/account/header_choice.dart';
import 'package:polygon/routes/home/user_detail/user_header.dart';
import 'package:polygon/routes/home/user_detail/user_name.dart';
import 'package:polygon/routes/home/user_detail/user_name_comment.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

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
  late String hobby;

  bool edit = false;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('name') ?? '';
    userMail = prefs.getString('mail') ?? '';
    userImage = prefs.getString('image') ?? '';
    userHeader = prefs.getString('header') ?? '';
    comment = prefs.getString('comment') ?? '';
    hobby = prefs.getString('hobby') ?? '';
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
          title: edit
              ? const Text(
                  "アカウントを編集",
                  style: TextStyle(color: Colors.black),
                )
              : const Text(
                  "アカウント",
                  style: TextStyle(
                    color: Color.fromRGBO(100, 205, 250, 1.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
          centerTitle: true,
          leading: edit
              ? InkWell(
                  onTap: () {
                    setState(() {
                      edit = false;
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.blueGrey,
                  ),
                )
              : const SizedBox(),
          actions: [
            edit
                ? ChangeNotifierProvider<Model>(
                    create: (_) => Model(),
                    child: Consumer<Model>(builder: (context, model, child) {
                      return TextButton(
                        child: const Text(
                          "保存",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        onPressed: () async {
                          model.startLoading();

                          getData();

                          await FirebaseFirestore.instance
                              .collection('user')
                              .doc(username)
                              .update({
                            'title': username,
                            'imageURL': userImage,
                            'headerURL': userHeader,
                            'comment': comment,
                            'mail': userMail,
                            'createdAt': Timestamp.now(),
                          });

                          model.endLoading();

                          await showDialog(
                            context: navigatorKey.currentContext!,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('保存完了'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () async {
                                      setState(() {
                                        edit = false;
                                        Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }))
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
        body: edit
            ? editBuilder(context)
            : FutureBuilder(
                future: getData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SingleChildScrollView(
                      child: Stack(
                        children: [
                          SizedBox(
                              width: size.width,
                              height: size.height,
                              child: Image.asset('assets/polygon.jpg')),
                          Column(
                            children: [
                              UserHeader(
                                  userheader: userHeader, userimage: userImage),
                              comment.isNotEmpty
                                  ? UserNameComment(username, comment)
                                  : UserName(username),
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
                  } else {
                    return Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }

  // 編集画面
  Widget editBuilder(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final controller = TextEditingController();
    controller.text = comment;

    return ChangeNotifierProvider<Model>(
      create: (_) => Model(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Image.asset('assets/polygon.jpg')),
                    Column(
                      children: <Widget>[
                        HeaderChoice(
                          username,
                          userHeader: userHeader,
                          userImage: userImage,
                        ),
                        UserName(username),
                        Container(
                          margin: const EdgeInsets.all(15.0),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: TextField(
                            controller: controller,
                            maxLength: 20,
                            style: const TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                top: 5.0,
                                bottom: 5.0,
                                left: 10.0,
                                right: 5.0,
                              ),
                              hintText: "ひとことを追加(20文字まで)",
                            ),
                            onChanged: (text) async {
                              comment = text;
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('comment', comment);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Consumer<Model>(builder: (context, model, child) {
            return model.isLoading
                ? Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox();
          }),
        ],
      ),
    );
  }
}
