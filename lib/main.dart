import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_login.dart';
import 'package:polygon/root.dart' as custom_root;
import 'package:polygon/first_launch/first_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ポリゴン',
      theme: ThemeData(
        primaryColor: Colors.blueGrey[900],
      ),
      home: const CheckData(),
    );
  }
}

class CheckData extends StatefulWidget {
  const CheckData({super.key});

  @override
  State<CheckData> createState() => CheckDataState(); // ✅ クラス名を修正
}

class CheckDataState extends State<CheckData> {
  String? mail;
  bool isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    getPrefItems();
  }

  Future<void> getPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mail = prefs.getString('mail');
      isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isFirstLaunch
        ? FirstView()
        : (mail != null ? custom_root.RootWidget(usermail: mail!) : UserLogin());
  }
}