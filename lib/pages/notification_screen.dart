import 'package:flutter/material.dart';
import 'notification_bell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('notifications')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('read', isEqualTo: false)
        .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No new notifications'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return ListTile(
                title: Text(doc['title']),
                subtitle: Text(doc['body']),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    FirebaseFirestore.instance.collection('notifications').doc(doc.id).update({
                      'read': true,
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}