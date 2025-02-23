import 'package:flutter/material.dart';
import 'package:polygon/drawer/contract.dart';
import 'package:polygon/drawer/privacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        title: Text(
          "設定",
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(children: <Widget>[
        GestureDetector(
          child: Container(
            child: ListTile(
              title: Text('利用規約'),
              trailing: Icon(Icons.navigate_next),
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
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
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
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
      ]),
    );
  }
}
