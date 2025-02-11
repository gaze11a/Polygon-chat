import 'package:flutter/material.dart';
import 'package:polygon/drawer/contact.dart';
import 'package:polygon/drawer/setting.dart';
import 'package:polygon/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PolygonDrawer extends StatelessWidget {
  const PolygonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width / 1.5,
      child: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              child: Text(
                "ポリゴンチャット",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'pupupu',
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(100, 205, 250, 1.0),
              ),
            ),
            ListTile(
              title: const Text('設定'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Setting(),
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
                          onPressed: () async {
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

                            await FirebaseFirestore.instance
                                .collection('token')
                                .doc(username)
                                .update({
                              'fcmtoken': FieldValue.arrayRemove([token])
                            });

                            prefs.clear();

                            prefs.setBool('isFirstLaunch', false);
                            prefs.setBool('isFirstChoice', false);
                            prefs.setBool('isExplain', false);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserLogin(),
                              ),
                            );
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
                    builder: (context) => Contact(),
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
