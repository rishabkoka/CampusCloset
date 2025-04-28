import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_firebase_project/pages/send_email.dart'; // adjust path if needed

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserFullName;

  const ChatPage({
    Key? key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserFullName,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _rating = 0;

  void _sendMessage() async {
    final message = _messageController.text.trim();
    final timestamp = FieldValue.serverTimestamp();

    await _firestore.collection('chats').doc(widget.chatRoomId).collection('messages').add({
      'senderId': widget.currentUserId,
      'text': message,
      'timestamp': timestamp,
    });

    _messageController.clear();
  }

  void _showRatingDialog(BuildContext context) {
    double tempRating = _rating;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Rate ${widget.otherUserFullName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: tempRating,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: tempRating.toString(),
                  onChanged: (value) {
                    setState(() {
                      tempRating = value;
                    });
                  },
                ),
                Text('Rating: ${tempRating.toStringAsFixed(1)}'),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  await _firestore.collection('ratings').add({
                    'ratedBy': widget.currentUserId,
                    'ratedTo': widget.otherUserId,
                    'rating': tempRating,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  setState(() => _rating = tempRating);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You rated ${widget.otherUserName}')),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _firestore.collection('blocked_users').add({
                'blockedBy': widget.currentUserId,
                'blockedUserId': widget.otherUserId,
                'timestamp': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You have blocked ${widget.otherUserName}')),
              );
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController _reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please describe the issue:"),
            const SizedBox(height: 10),
            TextField(
              controller: _reportController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter your report...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final text = _reportController.text.trim();
              if (text.isEmpty) {
                Fluttertoast.showToast(msg: "Please enter a report.");
                return;
              }

              await sendIssueReport(
                  "Reported User: ${widget.otherUserName}\nUser ID: ${widget.otherUserId}\n\n$text");
              Fluttertoast.showToast(msg: "✅ Report sent successfully");
              Navigator.pop(context);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUserName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () => _showRatingDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            onPressed: () => _showReportDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.block),
            onPressed: () => _showBlockDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final senderId = msg['senderId'];
                    return ListTile(
                      title: Text(senderId == widget.currentUserId ? 'You' : widget.otherUserName),
                      subtitle: Text(msg['text']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      _sendMessage();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
