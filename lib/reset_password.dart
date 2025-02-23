import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  ResetPasswordPage createState() => ResetPasswordPage();
}

class ResetPasswordPage extends State<ResetPassword> {
  String userMail = '';
  String text = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "パスワード再設定",
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: SizedBox(
                        height: 150,
                        width: 150,
                        child: Image.asset('assets/logo.png')),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 30.0),
                    child: Text(
                      'ポリゴンチャット',
                      style: TextStyle(fontFamily: 'pupupu', fontSize: 30),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text("登録しているメールアドレスに\n再設定用のリンクを送信いたします。"),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "メールアドレス"),
                    onChanged: (String value) {
                      setState(() {
                        userMail = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(100, 205, 250, 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          await auth.sendPasswordResetEmail(email: userMail);
                          Navigator.pop(navigatorKey.currentContext!);
                        } catch (error) {
                          String errorMessage = "メール送信に失敗しました。";
                          if (error is FirebaseAuthException) {
                            if (error.code == 'invalid-email') {
                              errorMessage = "無効なメールアドレスです。";
                            } else if (error.code == 'user-not-found') {
                              errorMessage = "メールアドレスが登録されていません。";
                            }
                          }
                          showDialog(
                            context: navigatorKey.currentContext!,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(errorMessage),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('戻る'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Text(
                        '送信',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
