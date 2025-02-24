import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polygon/login/create_profile.dart';
import 'package:polygon/login/reset_password.dart';
import 'package:polygon/root.dart' as custom_root;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';

import '../main.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  UserLoginState createState() => UserLoginState();
}

class UserLoginState extends State<UserLogin> {
  String userMail = '';
  String userPassword = '';
  String infoText = "";
  bool isLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> saveData(String mail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mail', mail);
    QuerySnapshot value = await FirebaseFirestore.instance
        .collection('user')
        .where('mail', isEqualTo: mail)
        .get();
    for (var result in value.docs) {
      prefs.setString('name', result['title'] ?? '');
      prefs.setString('image', result['imageURL'] ?? '');
      prefs.setString('header', result['headerURL'] ?? '');
      prefs.setString('comment', result['comment'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: SizedBox(
                      height: 150,
                      width: 150,
                      child: Image.asset('assets/logo.png')),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: Text(
                    'ポリゴンチャット',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    setState(() {
                      userMail = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "パスワード"),
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      userPassword = value;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    child: const Text('ログイン', style: TextStyle(fontSize: 15)),
                    onPressed: () async {
                      //loadingDialog(context);

                      try {
                        final loginResult = await auth.signInWithEmailAndPassword(
                          email: userMail,
                          password: userPassword,
                        );


                        String? idToken = await loginResult.user?.getIdToken();
                        debugPrint("ID Token: $idToken");

                        if (idToken != null) {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('idToken', idToken);

                          // Firestore に `fcmtoken` として配列で保存
                          await FirebaseFirestore.instance.collection('token').doc(userMail).set({
                            'fcmtoken': FieldValue.arrayUnion([idToken]), // ← 配列として保存
                          }, SetOptions(merge: true));
                        }

                        if (loginResult.user?.emailVerified == true) {
                          await saveData(loginResult.user!.email!);
                          Navigator.of(navigatorKey.currentContext!).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => custom_root.RootWidget(userMail),
                            ),
                          );
                        } else {
                          showDialog(
                            context: navigatorKey.currentContext!,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('メール認証が必要です'),
                                content: const Text('メールアドレスの確認を行ってください。'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } catch (e) {
                        showErrorDialog(navigatorKey.currentContext!, 'ログインに失敗しました。\nメールアドレスまたはパスワードが間違っています。');
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(text: 'アカウントをお持ちでない方は '),
                        TextSpan(
                          text: '新規登録',
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setBool('isFirstChoice', true);
                              Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(
                                builder: (context) => const CreateProfile(),
                              ));
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(text: 'パスワードが分からない方は '),
                        TextSpan(
                          text: '再設定',
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const ResetPassword(),
                              ));
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}
