import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './chat_page.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({Key? key}) : super(key: key);

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> matches = [];

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  void fetchMatches() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .get();

    setState(() {
      matches = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Matches"),
      ),
      body: matches.isEmpty
          ? const Center(child: Text("No matches yet"))
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final otherUserId = match['users'].firstWhere((userId) => userId != currentUserId);
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return const Text('Error fetching user data');
                    }

                    final otherUserData = snapshot.data;
                    return ListTile(
                      title: Text(otherUserData?['username'] ?? 'Unknown'),
                      subtitle: Text('Item: ${match['itemA']}'),
                      onTap: () {
                        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatPage(
      chatRoomId: match.id, // This will be your actual chat room ID
      currentUserId: currentUserId, // Pass the current user's ID
      otherUserId: otherUserId, // Pass the other user's ID
    ),
  ),
);

                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
