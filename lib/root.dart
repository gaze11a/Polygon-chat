import 'package:flutter/material.dart';
import 'package:polygon/routes/account/account.dart';
import 'package:polygon/routes/chatroom.dart';
import 'package:polygon/routes/home/home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RootWidget extends StatefulWidget {
  final String userMail;
  const RootWidget(this.userMail, {super.key});

  @override
  RootWidgetState createState() => RootWidgetState();
}

class RootWidgetState extends State<RootWidget> {
  int selectedIndex = 0;
  final List<BottomNavigationBarItem> bottomNavigationBarItems = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const footerIcons = [
    Icons.home,
    Icons.textsms,
    Icons.account_circle,
  ];

  static const footerItemNames = [
    'ホーム',
    'トーク',
    'アカウント',
  ];

  late List<Widget> routes;

  Future<void> pushToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    final String username = prefs.getString('name') ?? "";
    await FirebaseFirestore.instance.collection('token').doc(username).update({
      'fcmtoken': FieldValue.arrayUnion([token])
    });
  }

  @override
  void initState() {
    super.initState();
    bottomNavigationBarItems.add(activeState(0));
    for (var i = 1; i < footerItemNames.length; i++) {
      bottomNavigationBarItems.add(deactiveState(i));
    }
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    _firebaseMessaging.getToken().then((String? token) {
      if (token != null) {
        pushToken(token);
      }
    });
  }

  BottomNavigationBarItem activeState(int index) {
    return BottomNavigationBarItem(
      icon: Icon(footerIcons[index], color: Colors.black87),
      label: footerItemNames[index],
    );
  }

  BottomNavigationBarItem deactiveState(int index) {
    return BottomNavigationBarItem(
      icon: Icon(footerIcons[index], color: Colors.black26),
      label: footerItemNames[index],
    );
  }

  void setRoute() {
    routes = [Home(), const Chatroom(), const Account()];
  }

  void onItemTapped(int index) {
    setState(() {
      bottomNavigationBarItems[selectedIndex] = deactiveState(selectedIndex);
      bottomNavigationBarItems[index] = activeState(index);
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    setRoute();
    return Scaffold(
      body: routes.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: bottomNavigationBarItems,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
