import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Hapa ndio Firebase anaanza
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fundi Mteja',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(), // Tunaenda Login moja kwa moja
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingia Fundi Mteja')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Karibu!', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Login na Google'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Jisajili'),
            ),
          ],
        ),
      ),
    );
  }
}