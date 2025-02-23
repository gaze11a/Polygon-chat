import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';
import 'package:polygon/routes/utils/model.dart';
import 'package:polygon/main.dart';
import 'package:polygon/routes/utils/loading_dialog.dart'; // 🔹 ローディングダイアログをインポート

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ContactPage(),
    );
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  final TextEditingController emailSubject = TextEditingController();
  final TextEditingController emailBody = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(68, 114, 196, 1.0),
        title: const Text("コンタクト"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ChangeNotifierProvider<Model>(
        create: (_) => Model(),
        child: Consumer<Model>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: TextField(
                        controller: emailSubject,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20.0),
                          hintText: 'タイトル',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: TextField(
                        controller: emailBody,
                        keyboardType: TextInputType.multiline,
                        maxLines: 18,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20.0),
                          hintText: 'ご意見・ご不満などお書きください',
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(100, 205, 250, 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () async {
                        final navigator = Navigator.of(context);

                        // 🔹 ローディングダイアログを表示
                        loadingDialog(context);

                        try {
                          await flutterEmailSenderMail();

                          // 🔹 ローディングダイアログを閉じる
                          navigator.pop();

                          // 🔹 完了ダイアログを表示
                          model.dialog(navigatorKey.currentContext!, "送信完了");
                        } catch (e) {
                          // 🔹 ローディングダイアログを閉じる
                          navigator.pop();

                          // 🔹 エラーダイアログを表示
                          model.dialog(navigatorKey.currentContext!, "送信エラー");
                        }
                      },
                      child: const Text(
                        '送信',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('※お使いのデバイスのメールアドレスで送信します'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> flutterEmailSenderMail() async {
    final Email email = Email(
      body: emailBody.text,
      subject: emailSubject.text,
      recipients: ['polygonchat.contact@gmail.com'],
    );

    await FlutterEmailSender.send(email);
  }
}
