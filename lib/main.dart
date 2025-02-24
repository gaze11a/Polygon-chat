import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:polygon/routes/utils/model.dart';
import 'login/user_login.dart';
import 'package:polygon/root.dart' as custom_root;
import 'package:polygon/login/first_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // ← 本番用
    appleProvider: AppleProvider.deviceCheck,      // ← iOS用
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Model()),
      ],
      child: const App(),
    ),
  );
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
      navigatorKey: navigatorKey,
      home: const CheckData(),
    );
  }
}

class CheckData extends StatelessWidget {
  const CheckData({super.key});

  Future<Map<String, dynamic>> getPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "mail": prefs.getString('mail'),
      "isFirstLaunch": prefs.getBool('isFirstLaunch') ?? true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getPrefItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final mail = snapshot.data?["mail"];
        final isFirstLaunch = snapshot.data?["isFirstLaunch"] ?? true;

        return isFirstLaunch
            ? const FirstView()
            : (mail != null ? custom_root.RootWidget(mail) : const UserLogin());
      },
    );
  }
}
