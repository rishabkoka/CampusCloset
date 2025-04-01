import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './closet.dart'; // Import ClosetPage for MyCloset
import './swipe_page.dart'; // Import SwipePage for Home
import './chat_page.dart';  // Import ChatPage
import './settings_page.dart'; // Sidebar Menu
import './selling.dart';  // SellingPage for adding items

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String username = "Loading...";
  int _selectedIndex = 0;  // Default page is MyCloset

  // Pages for Bottom Navigation Bar
  final List<Widget> _pages = [
    const ClosetPage(),  // My Closet
    const SwipePage(),   // Home (Swipe Items)
    const ChatPage(      // Chat
      chatRoomId: "chatRoomId", 
      currentUserId: "userId", 
      otherUserId: "userId"
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  // Fetch user info from Firestore
  Future<void> _fetchUsername() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
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

  // Handle navigation item tap (Bottom Nav Bar)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Sign out method
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Title widget for the app bar
  Widget _title() {
    return const Text('CampusCloset',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F1E3),
        title: _title(),
      ),
      drawer: Drawer( // Sidebar Menu
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? 'User email',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cabin),
              title: const Text('My Closet'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellingPage()),  // Navigate to SellingPage (where users add items)
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                signOut(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],  // Show the current page based on selected index

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cabin),
            label: 'My Closet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
