import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:polygon/routes/home/home.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';

import 'main.dart';

class CreateProfile extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userImage = '';

  CreateProfile({super.key});

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
                    fontWeight: FontWeight.bold),
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
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: InkWell(
                        onTap: () async {
                          userImage =
                          await model.setImage('${model.userName} + image');
                        },
                        child: userImage.isEmpty
                            ? Container(
                            width: 130.0,
                            height: 130.0,
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white, width: 7),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image:
                                    const AssetImage('assets/preimage.JPG'),
                                    colorFilter: ColorFilter.mode(
                                        Colors.black.withAlpha(153),
                                        BlendMode.dstATop))),
                            child: const Icon(Icons.collections))
                            : Container(

                            width: 130.0,
                            height: 130.0,
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white, width: 7),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(userImage),
                                    colorFilter: ColorFilter.mode(
                                        Colors.black.withAlpha(153),
                                        BlendMode.dstATop))),
                          child: const Icon(Icons.collections),),
                      ),
                    ),
                    const Text('ユーザーアイコン'),
                    const Divider(
                      height: 20.0,
                      thickness: 2.0,
                    ),
                    model.textForm(context, 'ユーザー名', '例: 松雪パイラ'),
                    model.textForm(context, 'Eメール', '例: paira@polygon.com'),
                    model.textForm(context, 'パスワード', '半角英数字記号 (6文字以上)'),
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
                          model.startLoading();
                          model.checkform(context);

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
                                    'hobby': '',
                                    'mail': model.userMail,
                                    'createdAt': Timestamp.now(),
                                  },
                                );

                                await FirebaseFirestore.instance
                                    .collection('token')
                                    .doc(model.userName)
                                    .set({'fcmtoken': []});
                              }

                              model.endLoading();
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
                                              builder: (context) => HomePage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              model.endLoading();
                              model.dialog(navigatorKey.currentContext!, "そのユーザー名は既に登録されています。");
                            }
                          } catch (e) {
                            model.endLoading();
                            model.dialog(navigatorKey.currentContext!, "エラーが発生しました: ${e.toString()}");
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
