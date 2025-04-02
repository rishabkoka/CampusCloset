import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './chat_page.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  List<DocumentSnapshot> closetItems = [];
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  PageController pageController = PageController();
  double startX = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

 void fetchItems() async {
  final blockedSnapshot = await FirebaseFirestore.instance
      .collection('blocked_users')
      .where('blockedBy', isEqualTo: currentUserId)
      .get();

  final blockedUserIds = blockedSnapshot.docs.map((doc) => doc['blockedUserId']).toList();

  final itemSnapshot = await FirebaseFirestore.instance
      .collection('items')
      .where('userId', isNotEqualTo: currentUserId)
      .get();

  final allItems = itemSnapshot.docs;

  setState(() {
    closetItems = allItems.where((doc) => !blockedUserIds.contains(doc['userId'])).toList();
    isLoading = false;
  });

  print("Filtered and fetched ${closetItems.length} swipeable items.");
}


  void handleSwipeRight(DocumentSnapshot item) async {
  final likedItemId = item.id;
  final ownerId = item['userId'];

  // Record the like
  await FirebaseFirestore.instance
      .collection('likes')
      .doc(currentUserId)
      .collection('liked')
      .doc(ownerId)
      .set({
    'itemId': likedItemId,
    'timestamp': FieldValue.serverTimestamp(),
  });

  // Check if match exists
  final matchCheck = await FirebaseFirestore.instance
      .collection('likes')
      .doc(ownerId)
      .collection('liked')
      .doc(currentUserId)
      .get();

  if (matchCheck.exists) {
    // Fetch the owner's user info
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
    final otherUserName = userDoc['username'] ?? 'Unknown';
    final otherUserFullName = userDoc['fullName'] ?? 'Unknown';

    // Save the match
    await FirebaseFirestore.instance
        .collection('matches')
        .doc('${currentUserId}_$ownerId')
        .set({
      'users': [currentUserId, ownerId],
      'itemA': likedItemId,
      'itemB': matchCheck['itemId'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🎉 It's a match!")),
    );

    // Navigate to chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatRoomId: '${currentUserId}_$ownerId',
          currentUserId: currentUserId,
          otherUserId: ownerId,
          otherUserName: otherUserName,
          otherUserFullName: otherUserFullName,
        ),
      ),
    );
  }
}


  void handleSwipeLeft(DocumentSnapshot item) async {
    final passedItemId = item.id;
    final ownerId = item['userId'];

    await FirebaseFirestore.instance
        .collection('passes')
        .doc(currentUserId)
        .collection('passed')
        .doc(ownerId)
        .set({
      'itemId': passedItemId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F1E3),
        title: const Text("Discover Closets",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : closetItems.isEmpty
              ? const Center(child: Text("No items to swipe on yet."))
              : PageView.builder(
                  controller: pageController,
                  itemCount: closetItems.length,
                  itemBuilder: (context, index) {
                    final item = closetItems[index];
                    return GestureDetector(
                      onHorizontalDragStart: (details) {
                        startX = details.globalPosition.dx;
                      },
                      onHorizontalDragEnd: (details) {
                        double swipeVelocity = details.primaryVelocity ?? 0;

                        if (swipeVelocity > 200) {
                          handleSwipeRight(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Liked 👍")),
                          );
                        } else if (swipeVelocity < -200) {
                          handleSwipeLeft(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Passed 👎")),
                          );
                        }

                        if (pageController.hasClients &&
                            index < closetItems.length - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: buildItemCard(item),
                    );
                  },
                ),
    );
  }

  Widget buildItemCard(DocumentSnapshot item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  item['imageUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    item['brand'] ?? 'Item',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item['category'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
