import 'package:flutter/material.dart';

class SignedInScreen extends StatelessWidget {
  const SignedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: const Center(
        child: Text('You signed in correctly', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
