import 'package:flutter/material.dart';
import './profile_page.dart';
import './user_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
                  const SizedBox(width: 220.0),
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
                    'User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 235.0),
                  Icon(
                    Icons.arrow_forward, // Right arrow icon
                    size: 24,
                    color: Colors.grey, // Icon color (same as text)
                  ),
                ]
              )
            )
          ]
        )
      )
    );
  }
}