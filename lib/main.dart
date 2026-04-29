import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp()); // Washa app kwanza!
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fundi Mteja',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashWrapper(),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});
  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
final Future<FirebaseApp> _initialization = Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Kama Firebase amegoma
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Firebase imegoma: ${snapshot.error}'),
            ),
          );
        }

        // Kama Firebase amemaliza
        if (snapshot.connectionState == ConnectionState.done) {
          return const LoginPage(); // Nenda Login
        }

        // Bado ana-connect - onyesha loading
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Inaunganisha Firebase...'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error: $e');
    }
  }

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
              onPressed: signInWithGoogle, // HII NDIO IMEBADILIKA
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