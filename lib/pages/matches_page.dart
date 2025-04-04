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
  List<String> blockedUserIds = [];

  @override
  void initState() {
    super.initState();
    fetchBlockedUsers().then((_) => fetchMatches());
  }

  Future<void> fetchBlockedUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('blocked_users')
        .where('blockedBy', isEqualTo: currentUserId)
        .get();

    setState(() {
      blockedUserIds = snapshot.docs.map((doc) => doc['blockedUserId'] as String).toList();
    });
  }

  void fetchMatches() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .get();

    setState(() {
      matches = snapshot.docs.where((doc) {
        final users = List<String>.from(doc['users']);
        final otherUserId = users.firstWhere((id) => id != currentUserId);
        return !blockedUserIds.contains(otherUserId);
      }).toList();
    });
  }

  Future<double> fetchAverageRating(String userId) async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('ratedTo', isEqualTo: userId)
        .get();

    if (ratingsSnapshot.docs.isEmpty) return 0.0;

    double total = 0;
    for (var doc in ratingsSnapshot.docs) {
      total += (doc['rating'] ?? 0).toDouble();
    }

    return total / ratingsSnapshot.docs.length;
  }

  void showAverageRatingDialog(String userId, String username) async {
    double avgRating = await fetchAverageRating(userId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$username's Community Rating"),
        content: Text(
          avgRating == 0
              ? "No ratings yet."
              : "⭐ ${avgRating.toStringAsFixed(2)} / 5.0",
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
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
                final otherUserId = match['users']
                    .firstWhere((userId) => userId != currentUserId);

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherUserId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                      return const SizedBox();
                    }

                    final otherUserData = snapshot.data!;
                    final username = otherUserData['username'] ?? 'Unknown';
                    final fullName = otherUserData['fullName'] ?? 'Unknown';

                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(username)),
                          IconButton(
                            icon: const Icon(Icons.star, color: Colors.amber),
                            onPressed: () {
                              showAverageRatingDialog(otherUserId, username);
                            },
                          ),
                        ],
                      ),
                      subtitle: Text('Item: ${match['itemA']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              chatRoomId: match.id,
                              currentUserId: currentUserId,
                              otherUserId: otherUserId,
                              otherUserName: username,
                              otherUserFullName: fullName,
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