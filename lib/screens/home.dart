import 'package:flutter/material.dart';
import 'package:hyaup/repository/auth.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  String firebaseIdToken = "";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                widget.firebaseIdToken =
                    await authRepository.getIdToken() ?? "";
                setState(() {});
                print(widget.firebaseIdToken);
              },
              child: Text("Get Firebase Id Token"),
            ),
            Text(widget.firebaseIdToken),
          ],
        ),
      ),
    );
  }
}
