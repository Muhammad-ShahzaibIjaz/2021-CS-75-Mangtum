import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangtumcode/Refrences/roleRef.dart';
import 'package:mangtumcode/pages/HomePage.dart';
import 'package:mangtumcode/uities/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _passwordVisibility;
  final _formKey = GlobalKey<FormState>();
  bool _showError = false; // Track whether to show the error message

  bool changeState = false;

  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  final _form = GlobalKey<FormState>();

  bool isLoggingIn = false; // Added to track login state

  @override
  void initState() {
    super.initState();
    _passwordVisibility = false;
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

          MyRoutes.RenderEntryPage,

          arguments: {'userId': userUid}, // Pass the userId here
        );
      } else if (userRole == 'Buyer') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage.create(userId: userUid),
          ),
        );
      } else if (userRole == 'Admin') {
        Navigator.pushNamed(
          context,
          MyRoutes.AdminHomePage,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No user found for that email."),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Wrong password provided for that user.'),
        ));
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  "assets/images/download.jpg"), // Change to your image asset
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  height: 500.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    border: Border.all(color: Colors.grey), // Border color
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 0.0),
                              child: Image.asset(
                                'assets/images/MangtumLogo.png', // Change to your image asset
                                width: 200.0,
                                height: 60.0,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Welcome Back,',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily:
                                'Roboto', // Change to the font you prefer
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(color: Colors.black),
                            hintText: 'Enter your email here...',
                            hintStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              setState(() {
                                _showError = true; // Show error message
                              });
                              return "Email can not be empty";
                            }
                            setState(() {
                              _showError = false; // Hide error message
                            });
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisibility,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.black),
                            hintText: 'Enter your password here...',
                            hintStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisibility = !_passwordVisibility;
                                });
                              },
                              icon: Icon(
                                _passwordVisibility
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              setState(() {
                                _showError = true; // Show error message
                              });
                              return "Password can not be empty";
                            }
                            setState(() {
                              _showError = false; // Hide error message
                            });
                            return null;
                          },
                        ),
                        if (_showError)
                          SizedBox(
                            height: 16.0,
                            child: Text(
                              'Email or password cannot be empty.',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        SizedBox(height: 24.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                moveToForgotPassPage(context);
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  signInWithEmailAndPassword();
                                  print('Login pressed...');
                                }
                              },
                              child: Text('Login',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Add your navigation logic here
                                moveToSigninPage(context);
                                print('Create Account pressed...');
                              },
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
