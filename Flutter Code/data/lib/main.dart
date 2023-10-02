import 'package:data/Widgets/themes.dart';
import 'package:data/firebase_options.dart';
import 'package:data/pages/AuthPage.dart';
import 'package:data/pages/ForgotPassPage.dart';
import 'package:data/pages/HomePage.dart';
import 'package:data/pages/LoginPage.dart';
import 'package:data/pages/SignInPage.dart';
import 'package:data/uities/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: HomePage(),
      themeMode: ThemeMode.light,
      theme: MyThemes.lightTheme(context),
      darkTheme: ThemeData(brightness: Brightness.dark),
      //initialRoute: MyRoutes.homeRoute,
      routes: {
        "/": (context) => LoginPage(),
        "/login": (context) => LoginPage(),
        MyRoutes.SignInRoute: (context) => SignInPage(),
        MyRoutes.ForgotPassRoute: (context) => ForgotPassPage(),
        MyRoutes.homeRoute: (context) => AuthPage()
      },
    );
  }
}
