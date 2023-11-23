import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? _emailError;

  void _resetPassword() async {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'Email is required' : null;
    });

    if (_emailError == null) {
      try {
        final email = _emailController.text;
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: 'dummyPassword', // Provide a dummy password
        );

        // Check if the userCredential is not null, which means the email exists
        if (userCredential.user != null) {
          _auth.sendPasswordResetEmail(email: email);
          print('Password reset email sent.');
        } else {
          setState(() {
            _emailError = 'Email does not exist.';
          });
        }
      } catch (e) {
        print('Error sending password reset email: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email Address'),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                errorText: _emailError, // Add a comma here
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              'We will send you an email with a link to reset your password. Please enter the email associated with your account above.',
              style: TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            SizedBox(height: 16.0),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.amber),
                    foregroundColor: MaterialStateProperty.all(
                        Colors.white), // Set text color to white
                  ),
                  onPressed: _resetPassword,
                  child: Text('Send Reset Link'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
