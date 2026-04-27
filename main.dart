import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kidafutali cha Fundi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoginScreen();
        return RoleChecker(user: snapshot.data!);
      },
    );
  }
}

class RoleChecker extends StatelessWidget {
  final User user;
  RoleChecker({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) return ChooseRoleScreen();
        
        String role = snapshot.data!['role'];
        return role == 'Fundi' ? FundiHome() : MtejaHome();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLogin = true;

  void submit() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Ingia' : 'Jisajili')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: email, decoration: InputDecoration(labelText: 'Email')),
          TextField(controller: password, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
          SizedBox(height: 20),
          ElevatedButton(onPressed: submit, child: Text(isLogin ? 'Ingia' : 'Jisajili')),
          TextButton(onPressed: () => setState(() => isLogin = !isLogin), 
            child: Text(isLogin ? 'Huna akaunti? Jisajili' : 'Una akaunti? Ingia')),
        ]),
      ),
    );
  }
}

class ChooseRoleScreen extends StatelessWidget {
  void saveRole(String role, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'role': role,
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthGate()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wewe ni Nani?')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(onPressed: () => saveRole('Fundi', context), child: Text('Mimi ni FUNDI', style: TextStyle(fontSize: 20))),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () => saveRole('Mteja', context), child: Text('Mimi ni MTEJA', style: TextStyle(fontSize: 20))),
        ]),
      ),
    );
  }
}

class FundiHome extends StatelessWidget {
  final kazi = TextEditingController();
  final bei = TextEditingController();

  void ongezaKazi() {
    final user = FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance.collection('kazi').add({
      'fundiId': user.uid,
      'fundiEmail': user.email,
      'ainaYaKazi': kazi.text,
      'bei': bei.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    kazi.clear(); bei.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard ya Fundi'), actions: [
        IconButton(icon: Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())
      ]),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(children: [
            TextField(controller: kazi, decoration: InputDecoration(labelText: 'Aina ya Kazi: mf. Ujenzi')),
            TextField(controller: bei, decoration: InputDecoration(labelText: 'Bei: mf. 50000')),
            ElevatedButton(onPressed: ongezaKazi, child: Text('Ongeza Kazi')),
          ]),
        ),
        Divider(),
        Text('Kazi Zako:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('kazi').where('fundiId', isEqualTo: user.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              return ListView(
                children: snapshot.data!.docs.map((doc) => ListTile(
                  title: Text(doc['ainaYaKazi']),
                  subtitle: Text('TSh ${doc['bei']}'),
                )).toList(),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class MtejaHome extends StatelessWidget {
  void ombaKazi(String kaziId, String fundiEmail) {
    final user = FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance.collection('maombi').add({
      'kaziId': kaziId,
      'mtejaId': user.uid,
      'mtejaEmail': user.email,
      'fundiEmail': fundiEmail,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tafuta Fundi'), actions: [
        IconButton(icon: Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())
      ]),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('kazi').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) => Card(
              child: ListTile(
                title: Text(doc['ainaYaKazi'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Fundi: ${doc['fundiEmail']}\nBei: TSh ${doc['bei']}'),
                trailing: ElevatedButton(
                  child: Text('Omba Kazi'),
                  onPressed: () {
                    ombaKazi(doc.id, doc['fundiEmail']);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ombi limetumwa!')));
                  },
                ),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}