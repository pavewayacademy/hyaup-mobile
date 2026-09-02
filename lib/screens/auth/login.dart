import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hyaup/repository/auth.dart';

import '../home.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  final AuthRepository _authRepository = AuthRepository();

  // Define our data controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HyaUp - Sign In")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Login Screen"),
            TextFormField(
              controller: widget._emailController,
              decoration: InputDecoration(label: Text("Email")),
            ),
            TextFormField(
              controller: widget._passwordController,
              decoration: InputDecoration(label: Text("Password")),
            ),
            ElevatedButton(
              onPressed: () async {
                print(widget._emailController.text);
                print(widget._passwordController.text);
                String? email = widget._emailController.text;
                String? password = widget._passwordController.text;
                if (email.isNotEmpty && password.isNotEmpty) {
                  try {
                    UserCredential? userCred = await widget._authRepository
                        .signInWithEmailAndPassword(email, password);
                    print(userCred);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    return;
                  } catch (e) {
                    print(e);
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Please enter both email and password"),
                  ),
                );
              },
              child: Text("Log In"),
            ),
          ],
        ),
      ),
    );
  }
}
