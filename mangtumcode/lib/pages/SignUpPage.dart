import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mangtumcode/Refrences/roleRef.dart';
import 'package:mangtumcode/models/users_model.dart';
import 'package:mangtumcode/pages/LoginPage.dart';

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
  TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedRole;
  String? _emailError;
  String? _nameError;
  String? _phoneError;
  String? _passwordError;
  String? _roleError;

  final List<String> roleOptions = ["Admin", "Buyer", "Render"];

  Future<void> signUp() async {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Name is required' : null;
      _emailError = _emailController.text.isEmpty ? 'Email is required' : null;
      _passwordError =
          _passwordController.text.isEmpty ? 'Password is required' : null;
      _phoneError =
          _phoneNumberController.text.isEmpty ? 'Phone is required' : null;
      _roleError = _selectedRole == null ? 'Role is required' : null;
    });

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

      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          await userCredential.user!.sendEmailVerification();

          final user = Users(
            userEmail: _emailController.text,
            userPassword: _passwordController.text,
            userPhone: _phoneNumberController.text,
            name: _nameController.text,
            userRole: roleRef,
            isActive: true,
            created_at: Timestamp.now(),
          );

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
            'emailVerified': false,
          });

          print("User signed up: ${userCredential.user?.uid}");
        }
      } catch (e) {
        print("Error signing up: $e");
      }
    } else {
      print("ACHA");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        color: Colors.white,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Form(
              key: _formKey,
              child: Container(
                width: double.infinity,
                height: 800.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                  border: Border.all(color: Colors.grey),
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
                              'assets/images/MangtumLogo.png',
                              width: 200.0,
                              height: 60.0,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Get Started Below,',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Name",
                            labelText: "Name",
                            errorText: _nameError,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "Email",
                            labelText: "Email",
                            errorText: _emailError,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            labelText: "Phone Number",
                            errorText: _phoneError,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone_android_outlined),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Password",
                            labelText: "Password",
                            errorText: _passwordError,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.password_outlined),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
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
                            errorText: _roleError,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.query_stats_outlined),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 200,
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              "Already have an account? Login",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Center(
                        child: InkWell(
                          onTap: () {
                            signUp();
                          },
                          child: Container(
                            width: 150,
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              "Create your account",
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
