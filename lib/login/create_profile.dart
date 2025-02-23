import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:polygon/routes/utils/image_choice.dart'; // 🔥 追加
import 'package:polygon/routes/home/home.dart';
import 'package:provider/provider.dart';
import 'package:polygon/routes/utils/model.dart';

import '../routes/utils/loading_dialog.dart';
import '../main.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  CreateProfileState createState() => CreateProfileState();
}

class CreateProfileState extends State<CreateProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userImage = '';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Model>(
      create: (_) => Model(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                "新規登録",
                style: TextStyle(
                  color: Color.fromRGBO(90, 200, 250, 1.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              automaticallyImplyLeading: false,
            ),
            body: Consumer<Model>(builder: (context, model, child) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: <Widget>[
                    ProfileImageChoice(model.userName, userImage),

                    const Text('ユーザーアイコン'),
                    const Divider(height: 20.0, thickness: 2.0),

                    model.textForm(context, 'ユーザー名'),
                    model.textForm(context, 'Eメール'),
                    model.textForm(context, 'パスワード'),

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(100, 205, 250, 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () async {
                          loadingDialog(context);
                          model.checkForm(context);

                          try {
                            DocumentSnapshot docSnapshot =
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(model.userName)
                                .get();
                            if (!docSnapshot.exists) {
                              final result =
                              await auth.createUserWithEmailAndPassword(
                                email: model.userMail,
                                password: model.userPassword,
                              );

                              if (result.user != null) {
                                await result.user!.sendEmailVerification();
                                await FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(model.userName)
                                    .set(
                                  {
                                    'title': model.userName,
                                    'imageURL': userImage,
                                    'headerURL': '',
                                    'comment': '',
                                    'mail': model.userMail,
                                    'createdAt': Timestamp.now(),
                                  },
                                );

                                await FirebaseFirestore.instance
                                    .collection('token')
                                    .doc(model.userName)
                                    .set({'fcmtoken': []});
                              }

                              closeLoadingDialog(navigatorKey.currentContext!);

                              showDialog(
                                context: navigatorKey.currentContext!,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('送信されたリンクからメールアドレスを確認してください。'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('次へ'),
                                        onPressed: () async {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => const HomePage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              closeLoadingDialog(navigatorKey.currentContext!);
                              model.dialog(
                                  navigatorKey.currentContext!,
                                  "そのユーザー名は既に登録されています。");
                            }
                          } catch (e) {
                            closeLoadingDialog(navigatorKey.currentContext!);
                            model.dialog(
                                navigatorKey.currentContext!,
                                "エラーが発生しました: ${e.toString()}");
                          }
                        },
                        child: const Text(
                          'プロフィール登録',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
