import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../user_login.dart';

// ignore: must_be_immutable
class FirstView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FirstViewPage(),
    );
  }
}

class FirstViewPage extends StatefulWidget {
  @override
  FirstViewPageState createState() => new FirstViewPageState();
}

class FirstViewPageState extends State<FirstViewPage> {
  String _out = '';
  bool agree = false;

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/contract.txt');
  }

  @override
  Widget build(BuildContext context) {
    loadAsset(context).then((value) {
      setState(() {
        _out = value;
      });
    });

    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('利用規約'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(68, 114, 196, 1.0),
        automaticallyImplyLeading: false,
      ),
      body: Column(children: [
        Container(
          margin: EdgeInsets.all(20),
          height: size.height / 1.5,
          child: SingleChildScrollView(
            child: Text(_out),
          ),
          decoration: BoxDecoration(
            border:
            Border.all(color: Color.fromRGBO(68, 114, 196, 1.0), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        CheckboxListTile(
          value: agree,
          title: Text(
            '利用規約に同意する',
          ),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool? value) async {
            setState(() {
              agree = value ?? false;
            });
          },
        ),
        TextButton(
          child: Text(
            '次へ',
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
          onPressed: () {
            if (agree) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicy(),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('チェックボックスにチェックを入れてください'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ]),
    );
  }
}

// ignore: must_be_immutable
class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PrivacyPolicyPage(),
    );
  }
}

class PrivacyPolicyPage extends StatefulWidget {
  @override
  PrivacyPolicyPageState createState() => new PrivacyPolicyPageState();
}

class PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String _out = '';
  bool agree = false;

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/privacy.txt');
  }

  @override
  Widget build(BuildContext context) {
    loadAsset(context).then((value) {
      setState(() {
        _out = value;
      });
    });

    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('プライバシーポリシー'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(68, 114, 196, 1.0),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            height: size.height / 1.5,
            child: SingleChildScrollView(
              child: Text(_out),
            ),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Color.fromRGBO(68, 114, 196, 1.0), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          CheckboxListTile(
            value: agree,
            title: Text(
              'プライバシーポリシーに同意する',
            ),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) async {
              setState(() {
                agree = value ?? false;
              });
            },
          ),
          TextButton(
            child: Text(
              'はじめる',
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
              if (agree) {
                final SharedPreferences prefs =
                await SharedPreferences.getInstance();
                prefs.setBool('isFirstLaunch', false);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => UserLogin(),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('チェックボックスにチェックを入れてください'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
