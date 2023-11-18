import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mangtumcode/Repository/user_repository.dart';
import 'package:mangtumcode/Widgets/themes.dart';
import 'package:mangtumcode/firebase_options.dart';
import 'package:mangtumcode/pages/AddProductPage.dart';
import 'package:mangtumcode/pages/AdminDashboardPage.dart';
import 'package:mangtumcode/pages/ForgotPassPage.dart';
import 'package:mangtumcode/pages/HomePage.dart';
import 'package:mangtumcode/pages/LoginPage.dart';
import 'package:mangtumcode/pages/PaymentMethod.dart';
import 'package:mangtumcode/pages/RenderHomePage.dart';
import 'package:mangtumcode/pages/SignUpPage.dart';
import 'package:mangtumcode/uities/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Register the UserRepository here
  Get.put(UserRepository()); // Register UserRepository with GetX

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  get userId => null;

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
        MyRoutes.ForgotPassRoute: (context) => ForgotPassword(),
        MyRoutes.homeRoute: (context) => HomePage(),
        MyRoutes.RenderPage: (context) => RenderHomePage(),
        MyRoutes.AddProductPage: (context) => AddProductPage(),
        MyRoutes.PaymentMethodPage: (context) => PaymentMethodPage(),
        MyRoutes.AdminHomePage: (context) => AdminDashboardPage(),
      },
    );
  }
}
