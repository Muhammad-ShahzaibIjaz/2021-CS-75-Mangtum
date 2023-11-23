import 'package:firebase_core/firebase_core.dart';


import 'package:sentry_flutter/sentry_flutter.dart';


import 'package:flutter/material.dart';


import 'package:get/get.dart';


import 'package:mangtumcode/Repository/user_repository.dart';


import 'package:mangtumcode/Widgets/themes.dart';


import 'package:mangtumcode/firebase_options.dart';


import 'package:mangtumcode/pages/AddProductPage.dart';


import 'package:mangtumcode/pages/AdminHomePage.dart';


import 'package:mangtumcode/pages/ForgotPassPage.dart';


import 'package:mangtumcode/pages/HomePage.dart';


import 'package:mangtumcode/pages/LoginPage.dart';


import 'package:mangtumcode/pages/PaymentMethod.dart';


import 'package:mangtumcode/pages/RenderHomePage.dart';


import 'package:mangtumcode/pages/SignUpPage.dart';


import 'package:mangtumcode/uities/routes.dart';


import 'package:flutter/widgets.dart';


import 'package:sentry/sentry.dart';


Future<void> main() async {



  await SentryFlutter.init(

    (options) {

      options.dsn =

          'https://5f8df37c131fe30ad7118b0a8159e12b@o4506264740429824.ingest.sentry.io/4506264791089152';


      options.tracesSampleRate = 1.0;


      // options.integrations.add(


      //   FirebaseIntegration(


      //     crashlytics: true, // Enable Crashlytics integration


      //   ),


      // );

    },

  );


  // Continue with the original code


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

