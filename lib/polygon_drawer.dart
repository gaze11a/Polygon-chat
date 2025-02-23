import 'package:flutter/material.dart';
import 'package:polygon/drawer/contact.dart';
import 'package:polygon/drawer/setting.dart';
import 'package:polygon/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class PolygonDrawer extends StatelessWidget {
  const PolygonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width / 1.5,
      child: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(100, 205, 250, 1.0),
              ),
              child: Text(
                "ポリゴンチャット",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'pupupu',
                ),
              ),
            ),
            ListTile(
              title: const Text('設定'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Setting(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('ログアウト'),
              onTap: () async {
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        '本当にログアウトしますか？',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'いいえ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text(
                            'はい',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () async {
                            final SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                            String username = prefs.getString('name') ?? '';
                            String token = prefs.getString('token') ?? '';

                            // 🔹 Firestore の `token` を削除（null の場合はスキップ）
                            try {
                              if (username.isNotEmpty && token.isNotEmpty) {
                                await FirebaseFirestore.instance
                                    .collection('token')
                                    .doc(username)
                                    .update({
                                  'fcmtoken': FieldValue.arrayRemove([token])
                                });
                                debugPrint("[DEBUG] Token removed from Firestore.");
                              }
                            } catch (e) {
                              debugPrint("[ERROR] Failed to remove token: $e");
                            }

                            // 🔹 SharedPreferences をクリア
                            await prefs.clear();
                            debugPrint("[DEBUG] SharedPreferences cleared.");

                            // 🔹 必要な設定値を復元
                            await prefs.setBool('isFirstLaunch', false);
                            await prefs.setBool('isFirstChoice', false);
                            await prefs.setBool('isExplain', false);

                            // 🔹 確実に画面を遷移するため `Future.delayed` を使用
                            Future.delayed(Duration.zero, () {
                              Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => UserLogin()),
                                    (route) => false,
                              );
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('コンタクト'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Contact(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
