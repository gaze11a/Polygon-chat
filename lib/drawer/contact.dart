import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContactPage(),
    );
  }
}

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  TextEditingController emailSubject = TextEditingController();
  TextEditingController emailBody = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(68, 114, 196, 1.0),
        title: Text(
          "コンタクト",
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ChangeNotifierProvider<Model>(
        create: (_) => Model(),
        child: Consumer<Model>(builder: (context, model, child) {
          return SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0))),
                        child: TextField(
                          controller: emailSubject,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20.0),
                            hintText: 'タイトル',
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0))),
                        child: TextField(
                          controller: emailBody,
                          keyboardType: TextInputType.multiline,
                          maxLines: 18,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20.0),
                            hintText: 'ご意見・ご不満などお書きください',
                          ),
                        ),
                      ),
                      TextButton(
                        child: Text(
                          '送信',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(100, 205, 250, 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () async {
                          model.startLoading();
                          try {
                            await flutterEmailSenderMail();
                            model.endLoading();
                            model.dialog(context, "送信完了");
                            Navigator.of(context).pop();
                          } catch (e) {
                            model.endLoading();
                            model.dialog(context, "送信エラー");
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('※お使いのデバイスのメールアドレスで送信します'),
                      )
                    ],
                  ),
                ),
                model.isLoading
                    ? Container(
                  color: Colors.grey.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : SizedBox(),
              ],
            ),
          );
        }),
      ),
    );
  }

  flutterEmailSenderMail() async {
    final Email email = Email(
      body: '${emailBody.text}',
      subject: '${emailSubject.text}',
      recipients: ['polygon.chat@gmail.com'],
    );

    await FlutterEmailSender.send(email);
  }
}