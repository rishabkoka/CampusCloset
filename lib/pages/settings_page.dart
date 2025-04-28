import 'package:flutter/material.dart';
import './profile_page.dart';
import './user_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (doc.exists) {
        setState(() {
          _notificationsEnabled = doc.data()?['notifications'] ?? true;
        });
      }
    }
  }

  Future<void> _updateNotificationSetting(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'notifications': value});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F1E3),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4F1E3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0),
              child:
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
            ),
            const SizedBox(height: 40), 
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 240, 238, 227),
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 30.0,
                  ),
                  const SizedBox(width: 30.0),
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 200.0),
                  Icon(
                    Icons.arrow_forward, // Right arrow icon
                    size: 24,
                    color: Colors.grey, // Icon color (same as text)
                  ),
                ]
              )
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 240, 238, 227),
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserSettings()),
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 30.0,
                  ),
                  const SizedBox(width: 30.0),
                  Text(
                    'User   ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 200.0),
                  Icon(
                    Icons.arrow_forward, // Right arrow icon
                    size: 24,
                    color: Colors.grey, // Icon color (same as text)
                  ),
                ]
              )
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 240, 238, 227),
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              onPressed: null,
              child: Row(
                children: [
                  Icon(
                    Icons.notifications,
                    size: 30.0,
                  ),
                  const SizedBox(width: 30.0),
                  Text(
                    'Notifications   ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _notificationsEnabled ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      await _updateNotificationSetting(value);
                    },
                    activeColor: Colors.blue,
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}