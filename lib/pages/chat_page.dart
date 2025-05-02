import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_firebase_project/pages/send_email.dart';
import 'view_user_profile_page.dart';
import 'package:intl/intl.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;

  String? _suggestedLocation;

  @override
  void initState() {
    super.initState();
    _pickRandomPurdueLocation();
  }

  void _pickRandomPurdueLocation() {
    final locations = [
      "Purdue Memorial Union",
      "Greyhouse Coffee Co.",
      "Hicks Undergraduate Library",
      "West Lafayette Public Library",
      "Chauncey Hill Starbucks",
      "Krach Leadership Center"
    ];
    final random = Random();
    final randomSpot = locations[random.nextInt(locations.length)];
    setState(() {
      _suggestedLocation = "Suggested Meet-up: $randomSpot";
    });
  }

  Widget _buildMeetupBanner() {
    if (_suggestedLocation == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: Colors.green.shade100,
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(_suggestedLocation!, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    final timestamp = FieldValue.serverTimestamp();

    await _firestore.collection('chats').doc(widget.chatRoomId).collection('messages').add({
      'senderId': widget.currentUserId,
      'receiverId': widget.otherUserId,
      'text': message,
      'timestamp': timestamp,
      'read': false,
      'heartedBy': [],
    });

    _messageController.clear();
    

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.otherUserId).get();
    final notif_status = userDoc['notifications'] ?? true;
    if(notif_status == true) {
      sendMessageEmail(widget.otherUserId);
    }

    // Update mostRecent field in the match
    String user1 = widget.currentUserId;
    String user2 = widget.otherUserId;
    final docId1 = '$user1$user2';
    final docId2 = '$user2$user1';
    final matchRef1 = FirebaseFirestore.instance.collection('matches').doc(docId1);
    final matchRef2 = FirebaseFirestore.instance.collection('matches').doc(docId2);
    DocumentSnapshot snapshot1 = await matchRef1.get();
    DocumentSnapshot snapshot2 = await matchRef2.get();
    final data = {'mostRecent': Timestamp.now()};

    if (snapshot1.exists) {
      await matchRef1.set(data, SetOptions(merge: true));
    } else if (snapshot2.exists) {
      await matchRef2.set(data, SetOptions(merge: true));
    }
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

  void _showUnmatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unmatch"),
        content: const Text("Are you sure you want to unmatch? This will delete the chat history."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleUnmatch();
            },
            child: const Text("Unmatch"),
          ),
        ],
      ),
    );
  }


  Future<void> _handleUnmatch() async {
    try {
      // 1. Delete chat messages
      final chatRef = _firestore.collection('chats').doc(widget.chatRoomId);
      final messages = await chatRef.collection('messages').get();
      for (var msg in messages.docs) {
        await msg.reference.delete();
      }
      await chatRef.delete();

      // 2. Find and delete the match document containing both users
      final matchQuery = await _firestore
          .collection('matches')
          .where('users', arrayContains: widget.currentUserId)
          .get();

      for (var doc in matchQuery.docs) {
        final users = List<String>.from(doc['users']);
        if (users.contains(widget.otherUserId)) {
          await doc.reference.delete();
          break; // assuming only one match per user pair
        }
      }

      // 3. Feedback and navigation
      if (mounted) {
        Fluttertoast.showToast(msg: "Unmatched successfully.");
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to unmatch. Please try again.");
    }
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

  Widget _buildMessage(Map<String, dynamic> messageData, QueryDocumentSnapshot messageDoc) {
    bool isMe = messageData['senderId'] == widget.currentUserId;
    final heartedBy = List<String>.from(messageData['heartedBy'] ?? []);
    final isHearted = heartedBy.contains(widget.currentUserId);
    final messageRef = messageDoc.reference;

    // Get and format message time
    DateTime? messageTime;
    String timeText = '';
    String dateText = '';
    if (messageData['timestamp'] != null) {
      messageTime = (messageData['timestamp'] as Timestamp).toDate();
      timeText = DateFormat.jm().format(messageTime);
      final now = DateTime.now();
      final isToday = messageTime.year == now.year &&
                  messageTime.month == now.month &&
                  messageTime.day == now.day;
      dateText = isToday ? '' : DateFormat('MM/dd/yy').format(messageTime);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent.shade100 : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message text
            Flexible(
              child: Text(
                messageData['text'],
                style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16),
              ),
            ),
            
            // Heart button
            IconButton(
              icon: Icon(
                isHearted ? Icons.favorite : Icons.favorite_border,
                color: isHearted ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                if (isHearted) {
                  messageRef.update({
                    'heartedBy': FieldValue.arrayRemove([widget.currentUserId, widget.otherUserId]),
                  });
                } else {
                  messageRef.update({
                    'heartedBy': FieldValue.arrayUnion([widget.currentUserId, widget.otherUserId]),
                  });
                }
              },
            ),
            if (timeText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeText,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                    if (dateText.isNotEmpty)
                      Text(
                        dateText,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
        ),
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUserName}'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewUserProfilePage(otherUserId: widget.otherUserId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.heart_broken , color: Colors.red),
            onPressed: () => _showUnmatchDialog(context),
          ),
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
      body: SafeArea(
        child: Column(
          children: [
            _buildMeetupBanner(),
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

                  if (!_hasScrolled && messages.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                         _hasScrolled = true;
                      }
                    });
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageDoc = messages[index];
                      final messageData = messages[index].data() as Map<String, dynamic>;
                      print(messageData);
                      print(widget.chatRoomId);
                      return _buildMessage(messageData, messageDoc);
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}