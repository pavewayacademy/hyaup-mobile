import 'package:flutter/material.dart';
import 'package:hyaup/repository/auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _firebaseIdToken = "";

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepository();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                _firebaseIdToken = await authRepository.getIdToken() ?? "";
                setState(() {});
              },
              child: const Text("Get Firebase Id Token"),
            ),
            Text(_firebaseIdToken),
          ],
        ),
      ),
    );
  }
}
