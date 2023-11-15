import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mangtumcode/Refrences/roleRef.dart';
import 'package:mangtumcode/uities/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String textToChange = "";
  bool changeState = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool isLoggingIn = false; // Added to track login state
  //sign up

  // sign in
  Future<void> signInWithEmailAndPassword() async {
    try {
      setState(() {
        changeState = true;
        isLoggingIn = true; // Set to true while logging in
      });
      final UserCredential authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      // Get the user's UID
      final String userUid = authResult.user!.uid;
      print("UID $userUid");
      // Fetch the user's role from Firestore
      final String? userRole = await getUserRoleFromFirestore(userUid);

      setState(() {
        changeState = false;
        isLoggingIn = false; // Reset to false on error
      });
      print("userRole= $userRole");
      if (userRole == 'Render') {
        // Navigate to the Render home page
        Navigator.pushNamed(
          context,
          MyRoutes.RenderPage,
          arguments: {'userId': userUid}, // Pass the userId here
        );
      } else if (userRole == 'Buyer') {
        Navigator.pushNamed(
          context,
          MyRoutes.homeRoute,
          arguments: {'userId': userUid}, // Pass the userId here
        );
      } else {
        // Handle other roles or scenarios here
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        changeState = false;
        isLoggingIn = false; // Reset to false on error
      });
      print('Firebase Authentication Error: ${e.code}');
      if (e.code == 'user-not-found') {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("No user found for that email."),
            ),
          );
        }
      } else if (e.code == 'wrong-password') {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Wrong password provided for that user.'),
          ));
        }
      }
    }
  }

  // Functions
  moveToHomePage(BuildContext context) async {
    if (_form.currentState!.validate() && !isLoggingIn) {
      await signInWithEmailAndPassword();
    }
  }

  moveToSigninPage(BuildContext context) {
    Navigator.pushNamed(context, MyRoutes.SignInRoute);
  }

  moveToForgotPassPage(BuildContext context) {
    Navigator.pushNamed(context, MyRoutes.ForgotPassRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Material(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Image.asset(
                    "Assets/images/MangtumLogo.png", // Corrected asset path
                    fit: BoxFit.cover,
                    height: 150.0,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "Welcome $textToChange",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.lato().fontFamily,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 30,
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      )),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Enter Username",
                          labelText: "Username",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return "Username can not be empty";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          textToChange = value;
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      )),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.password_outlined),
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return "Password can not be empty";
                          } else if (value!.length < 8 == true) {
                            return "Password can not be less than 8";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      InkWell(
                        onTap: () {
                          if (_form.currentState!.validate()) {
                            signInWithEmailAndPassword();
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          width: isLoggingIn
                              ? 50
                              : 150, // Adjusted width based on login state
                          height: 40,
                          alignment: Alignment.center,
                          child: isLoggingIn
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : changeState
                                  ? Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      InkWell(
                        onTap: () => moveToSigninPage(context),
                        child: Container(
                          width: 150,
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(
                            "Create a new Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      InkWell(
                        onTap: () => moveToForgotPassPage(context),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.amber,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
