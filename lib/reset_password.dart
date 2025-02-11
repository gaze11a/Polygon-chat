import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPassword createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
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
        title: Text(
          "パスワード再設定",
          style: TextStyle(
              color: Color.fromRGBO(90, 200, 250, 1.0),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                    child: Text(
                      'ポリゴンチャット',
                      style: TextStyle(fontFamily: 'pupupu', fontSize: 30),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text("登録しているメールアドレスに\n再設定用のリンクを送信いたします。"),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "メールアドレス"),
                    onChanged: (String value) {
                      setState(() {
                        userMail = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      child: Text(
                        '送信',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(100, 205, 250, 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          await auth.sendPasswordResetEmail(email: userMail);
                          Navigator.pop(context);
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
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(errorMessage),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('戻る'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
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
