import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './closet.dart'; 
import './swipe_page.dart'; 
import './matches_page.dart'; 
import './settings_page.dart'; 
import 'admin_panel_page.dart';
import './notification_bell.dart';
import './match_history_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String username = "Loading...";
  bool isModerator = false; // State variable to check if user is a moderator
  int _selectedIndex = 0; 

  final List<Widget> _pages = [
    const ClosetPage(),  
    const SwipePage(),   
    const MatchesPage(),
    const AdminPanelPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _countUnreadMessages();
  }


Future<void> _fetchUserData() async {
  if (user != null) {
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    DocumentSnapshot userDoc = await userRef.get();
    
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        username = userData['username'] ?? "No username";
        isModerator = userData['moderator'] ?? false;
      });

      // If the 'moderator' field does not exist, set it to false
      if (!userData.containsKey('moderator')) {
        await userRef.update({'moderator': false});
      }
    } else {
      // If the user document doesn't exist, create it with default values
      await userRef.set({
        'username': "No username",
        'moderator': false,
      });
      setState(() {
        username = "No username";
        isModerator = false;
      });
    }
  }
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int _unreadCount = 0;
  void _countUnreadMessages() {
    FirebaseFirestore.instance
    .collectionGroup('messages')
    .where('receiverId', isEqualTo: user!.uid)
    .where('read', isEqualTo: false)
    .snapshots()
    .listen((snapshot) {
      if(mounted) {
        setState(() => _unreadCount = snapshot.docs.length);
      }
    });

  }


  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

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
        actions: const [
          NotificationBell(),
        ],
      ),
      drawer: Drawer(
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
                  MaterialPageRoute(builder: (context) => const ClosetPage()),
                );
              },
            ),
            if (isModerator) // Conditionally show this ListTile
              ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Panel'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPanelPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Match History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MatchHistoryPage()),
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
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cabin),
            label: 'My Closet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.chat),
                if (_unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Chat',
            
          ),
        ],
      ),
    );
  }
}
