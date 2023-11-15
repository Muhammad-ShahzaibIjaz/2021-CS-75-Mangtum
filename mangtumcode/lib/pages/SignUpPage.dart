import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mangtumcode/Refrences/roleRef.dart';
import 'package:mangtumcode/Widgets/google.dart';
import 'package:mangtumcode/models/users_model.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneNumberController =
      TextEditingController(); // Add phone number controller
  String? _selectedRole;
  final List<String> roleOptions = ["Admin", "Buyer", "Render"];
  Completer<void> _googleSignInCompleter = Completer<void>();
  //sign up
  Future<void> signUp() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (_formKey.currentState!.validate()) {
      DocumentReference? roleRef;
      if (_selectedRole == "Admin") {
        roleRef = userRoleAdmin;
      } else if (_selectedRole == "Render") {
        roleRef = userRoleRender;
      } else if (_selectedRole == "Buyer") {
        roleRef = userRoleBuyer;
      }
      print("_selectedRole= $_selectedRole");
      print("roleref= $roleRef");
      try {
        // Sign up the user with email and password
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          // Send email verification
          await userCredential.user!.sendEmailVerification();

          // Create a Users object
          final user = Users(
              userEmail: _emailController.text,
              userPassword: _passwordController.text,
              userPhone: _phoneNumberController.text,
              name: _nameController.text,
              userRole: roleRef,
              isActive: true,
              created_at: Timestamp.now());

          // Store user data in Firestore
          await _firestore
              .collection('Users')
              .doc(userCredential.user!.uid)
              .set({
            'name': user.name,
            'email': user.userEmail,
            'phone': user.userPhone,
            'password': user.userPassword,
            'role': user.userRole,
            'isActive': true,
            'created_at': Timestamp.now(),
            'updated_at': Timestamp.now(),
            'emailVerified': false, // Initialize emailVerified to false
          });

          // User signed up successfully
          print("User signed up: ${userCredential.user?.uid}");

          // You can now inform the user that a verification email has been sent
          // and they need to verify their email before they can log in.
          // You may also provide a way for them to request a new verification email if needed.
        }
      } catch (e) {
        // Handle signup error
        print("Error signing up: $e");
        // You can also display an error message to the user here
      }
    }
  }

// ...

// Sign up with Google
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // The user canceled the sign-in process
      _googleSignInCompleter.completeError('Sign-in canceled');
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // Handle successful Google sign-in
        _googleSignInCompleter.complete();
        print("DONE");
        // You can navigate to another screen or perform other actions here
      } else {
        _googleSignInCompleter.completeError('Sign-in failed');
      }
    } catch (e) {
      print('$e');
      _googleSignInCompleter.completeError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'), // Add app bar title
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // Add back arrow
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back
            },
          ),
        ),
        body: Material(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40.0,
                  ),
                  Image.asset(
                    "Assets/images/MangtumLogo.png",
                    fit: BoxFit.cover,
                    height: 150.0,
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: "Name",
                        labelText: "Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.0, // Set the distance between fields
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        } else if (!value.contains('@')) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.0, // Set the distance between fields
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller:
                          _phoneNumberController, // Add phone number controller
                      decoration: InputDecoration(
                        hintText: "Phone Number",
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_android_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone number is required";
                        } else if (!value.startsWith("03") ||
                            value.length != 11) {
                          return "Enter a valid phone number starting with '03' and having a total of 11 characters";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.0, // Set the distance between fields
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.password_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        } else if (value.length < 8 ||
                            !value.contains(RegExp(r'[0-9]'))) {
                          return "Password must be at least 8 characters and contain at least one numeric character";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.0, // Set the distance between fields
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DropdownButtonFormField(
                      value: _selectedRole,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedRole = newValue as String?;
                        });
                      },
                      items: roleOptions.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: "Role",
                        labelText: "Role",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.query_stats_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Role is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  InkWell(
                    onTap: () {
                      signUp();
                    },
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
                    height: 20,
                  ),
                  GoogleSignInButton(
                    onPressed: () async {
                      await signInWithGoogle();
                      try {
                        await _googleSignInCompleter.future;
                        // Continue with other actions after successful Google sign-in
                      } catch (e) {
                        // Handle errors or canceled sign-in
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
