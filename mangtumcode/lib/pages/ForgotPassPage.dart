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
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController, // Use _emailController here
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Email',
                errorText: _emailError,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text(
                'Reset Password',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
