import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polygon/create_profile.dart';
import 'package:polygon/reset_password.dart';
import 'package:polygon/root.dart' as custom_root;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLogin createState() => _UserLogin();
}

class _UserLogin extends State<UserLogin> {
  String usermail = '';
  String userpassword = '';
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
      prefs.setString('hobby', (result['hobby'] as List<dynamic>?)?.join(',') ?? '');
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
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: Text(
                    'ポリゴンチャット',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    setState(() {
                      usermail = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "パスワード"),
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      userpassword = value;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    child: Text('ログイン', style: TextStyle(fontSize: 15)),
                    onPressed: () async {
                      try {
                        final loginResult = await auth.signInWithEmailAndPassword(
                          email: usermail,
                          password: userpassword,
                        );
                        if (loginResult.user?.emailVerified == true) {
                          await saveData(loginResult.user!.email!);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => custom_root.RootWidget(usermail: usermail),
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
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: 'アカウントをお持ちでない方は '),
                        TextSpan(
                          text: '新規登録',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setBool('isFirstChoice', true);
                              Navigator.of(context).push(MaterialPageRoute(
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
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: 'パスワードが分からない方は '),
                        TextSpan(
                          text: '再設定',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ResetPassword(),
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
