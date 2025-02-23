import 'package:flutter/material.dart';
import 'package:polygon/drawer/contract.dart';
import 'package:polygon/drawer/privacy.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';

import '../user_login.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingPage(),
    );
  }
}

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool notification = false;
  String notificationText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(68, 114, 196, 1.0),
        title: Text("設定"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: <Widget>[
          GestureDetector(
            child: Container(
              child: ListTile(
                title: Text('利用規約'),
                trailing: Icon(Icons.navigate_next),
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContractPage(),
                ),
              );
            },
          ),
          GestureDetector(
            child: Container(
              child: ListTile(
                title: Text('プライバシーポリシー'),
                trailing: Icon(Icons.navigate_next),
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPage(),
                ),
              );
            },
          ),
          SizedBox(height: 20),

          // 🔹 アカウント削除オプション
          GestureDetector(
            child: Container(
              child: ListTile(
                title: Text(
                  'アカウント削除',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.delete, color: Colors.red),
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.red)),
              ),
            ),
            onTap: () async {
              print("[DEBUG] Delete button pressed!");

              final model = Provider.of<Model>(context, listen: false);

              // 🔹 まずパスワード入力を要求
              String? password = await model.showPasswordDialog(context);

              if (password == null || password.isEmpty) {
                print("[DEBUG] Password input canceled.");
                return; // 🔹 キャンセルしたら何もしない
              }

              print("[DEBUG] Password entered.");

              // 🔹 次に削除確認ダイアログを表示
              bool confirm = await model.dialog(context, "本当にアカウントを削除しますか？");

              if (!confirm) {
                print("[DEBUG] User canceled account deletion.");
                return; // 🔹 キャンセルしたら何もしない
              }

              print("[DEBUG] User confirmed deletion!");
              await model.deleteAccount(context, password);

              // 🔹 削除完了後に `UserLogin()` に遷移
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => UserLogin()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
