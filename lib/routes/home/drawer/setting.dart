import 'package:flutter/material.dart';
import 'package:polygon/routes/home/drawer/contract.dart';
import 'package:polygon/routes/home/drawer/privacy.dart';
import 'package:provider/provider.dart';
import 'package:polygon/routes/utils/model.dart';

import '../../../main.dart';
import '../../../login/user_login.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SettingPage(),
    );
  }
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  bool notification = false;
  String notificationText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(68, 114, 196, 1.0),
        title: const Text("設定"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: <Widget>[
          GestureDetector(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: const ListTile(
                title: Text('利用規約'),
                trailing: Icon(Icons.navigate_next),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContractPage(),
                ),
              );
            },
          ),
          GestureDetector(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: const ListTile(
                title: Text('プライバシーポリシー'),
                trailing: Icon(Icons.navigate_next),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // 🔹 アカウント削除オプション
          GestureDetector(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.red)),
              ),
              child: const ListTile(
                title: Text(
                  'アカウント削除',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.delete, color: Colors.red),
              ),
            ),
            onTap: () async {
              debugPrint("[DEBUG] Delete button pressed!");

              final model = Provider.of<Model>(context, listen: false);

              // 🔹 まずパスワード入力を要求
              String? password = await model.showPasswordDialog(context);

              if (password == null || password.isEmpty) {
                debugPrint("[DEBUG] Password input canceled.");
                return; // 🔹 キャンセルしたら何もしない
              }

              debugPrint("[DEBUG] Password entered.");

              // 🔹 次に削除確認ダイアログを表示
              bool confirm = await model.dialog(
                  navigatorKey.currentContext!, "本当にアカウントを削除しますか？");

              if (!confirm) {
                debugPrint("[DEBUG] User canceled account deletion.");
                return; // 🔹 キャンセルしたら何もしない
              }

              debugPrint("[DEBUG] User confirmed deletion!");
              await model.deleteAccount(navigatorKey.currentContext!, password);

              // 🔹 削除完了後に `UserLogin()` に遷移
              Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const UserLogin()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
