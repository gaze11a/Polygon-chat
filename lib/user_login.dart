import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polygon/create_profile.dart';
import 'package:polygon/reset_password.dart';
import 'package:polygon/root.dart' as custom_root;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';

import 'main.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  _UserLogin createState() => _UserLogin();
}

class _UserLogin extends State<UserLogin> {
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
                      try {
                        final loginResult = await auth.signInWithEmailAndPassword(
                          email: userMail,
                          password: userPassword,
                        );
                        if (loginResult.user?.emailVerified == true) {
                          await saveData(loginResult.user!.email!);
                          Navigator.of(navigatorKey.currentContext!).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => custom_root.RootWidget(userMail),
                            ),
                          );
                        } else {
                          setState(() {
                            infoText = 'メールアドレスの確認が必要です。';
                          });
                        }
                      } catch (e) {
                        setState(() {
                          infoText = 'ログインに失敗しました。';
                        });
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
                                builder: (context) => CreateProfile(),
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
}
