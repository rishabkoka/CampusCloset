
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({Key? key}) : super(key: key);

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    fetchBlockedUsers();
  }

  void fetchBlockedUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('blocked_users')
        .where('blockedBy', isEqualTo: currentUserId)
        .get();

    setState(() {
      blockedUsers = snapshot.docs;
    });
  }

  void unblockUser(String docId, String blockedUserId) async {
    await FirebaseFirestore.instance
        .collection('blocked_users')
        .doc(docId)
        .delete();

    setState(() {
      blockedUsers.removeWhere((doc) => doc.id == docId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User has been unblocked.')),
    );
  }

  void showUnblockConfirmation(String docId, String username, String blockedUserId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unblock $username?'),
          content: const Text('Are you sure you want to unblock this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                unblockUser(docId, blockedUserId);
              },
              child: const Text('Unblock'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: blockedUsers.isEmpty
          ? const Center(child: Text('No blocked users'))
          : ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final doc = blockedUsers[index];
                final blockedUserId = doc['blockedUserId'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(blockedUserId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(title: Text('Loading...'));
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const ListTile(title: Text('User not found'));
                    }

                    final userData = snapshot.data!;
                    final username = userData['username'] ?? 'Unknown';

                    return ListTile(
                      title: Text(username),
                      trailing: IconButton(
                        icon: const Icon(Icons.block_flipped),
                        onPressed: () => showUnblockConfirmation(doc.id, username, blockedUserId),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}