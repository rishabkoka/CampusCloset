import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth.dart';
import 'package:flutter/material.dart';
import './settings_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final User? user = Auth().currentUser;
  String username = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (user!= null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? "No username";
        });
      } else {
        setState(() {
          username = "No username found";
        });
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    await Auth().signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _title() {
    return const Text('Home');
  }

  Widget _userInfo() {
    return Column(
      children: [
        Text(
          "Welcome, $username",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(user?.email ?? 'User email', style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _signOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => signOut(context),
      child: const Text('Sign Out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _title(),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 35.0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            }
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userInfo(),
            const SizedBox(height: 20),
            _signOutButton(context),
          ],
        ),
      ),
    );
  }
}
