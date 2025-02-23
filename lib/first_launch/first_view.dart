import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../user_login.dart';

// ignore: must_be_immutable
class FirstView extends StatelessWidget {
  const FirstView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FirstViewPage(),
    );
  }
}

class FirstViewPage extends StatefulWidget {
  const FirstViewPage({super.key});

  @override
  FirstViewPageState createState() => FirstViewPageState();
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
        title: const Text('利用規約'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(68, 114, 196, 1.0),
        automaticallyImplyLeading: false,
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.all(20),
          height: size.height / 1.5,
          decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromRGBO(68, 114, 196, 1.0), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Text(_out),
          ),
        ),
        CheckboxListTile(
          value: agree,
          title: const Text(
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
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromRGBO(100, 205, 250, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Text(
            '次へ',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          onPressed: () {
            if (agree) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicy(),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('チェックボックスにチェックを入れてください'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
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
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PrivacyPolicyPage(),
    );
  }
}

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  PrivacyPolicyPageState createState() => PrivacyPolicyPageState();
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
        title: const Text('プライバシーポリシー'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(68, 114, 196, 1.0),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            height: size.height / 1.5,
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromRGBO(68, 114, 196, 1.0), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(_out),
            ),
          ),
          CheckboxListTile(
            value: agree,
            title: const Text(
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
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromRGBO(100, 205, 250, 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'はじめる',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            onPressed: () async {
              if (agree) {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                prefs.setBool('isFirstLaunch', false);

                Navigator.of(navigatorKey.currentContext!).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => UserLogin(),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('チェックボックスにチェックを入れてください'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
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
