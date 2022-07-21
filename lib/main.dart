import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'index.dart';
import 'screens/auth/login_screen.dart';
import 'services/native_db_helper.dart';
import 'services/sqlite_db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.initDbLibrary();
  await DbHelper.initDb();
  await NativeDbHelper.initDb();
  Get.put(DataController());
  Get.put(AuthController());
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'zando application',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      // ignore: prefer_const_literals_to_create_immutables
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // ignore: prefer_const_literals_to_create_immutables
      supportedLocales: [const Locale('fr', 'FR')],
      home: const LoginScreen(),
    );
  }
}
