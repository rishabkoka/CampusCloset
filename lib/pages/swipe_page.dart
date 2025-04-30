import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './chat_page.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

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

  final prefs = await loadPreferences();
  final categoryPrefs = prefs['categories']!;
  final locationPrefs = prefs['locations']!;

  final itemSnapshot = await FirebaseFirestore.instance
      .collection('items')
      .where('userId', isNotEqualTo: currentUserId)
      .get();

  List<QueryDocumentSnapshot> filteredItems = [];

  for (final doc in itemSnapshot.docs) {
    final category = doc['category'];
    final itemOwner = doc['userId'];
    final ownerCollege = await getUserCollege(itemOwner);

    if (
      doc['status'] == 'Available' &&
      categoryPrefs.contains(category) &&
      locationPrefs.contains(ownerCollege) &&
      !blockedUserIds.contains(itemOwner)
    ) {
      filteredItems.add(doc);
    }
}

  setState(() {
    closetItems = filteredItems;
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
    final emailAdd = userDoc['email'] ?? 'Unknown';

    final userDoc2 = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    final emailAdd2 = userDoc2['email'] ?? 'Unknown';


    final notif_status1 = userDoc['notifications'] ?? true;

    final notif_status2 = userDoc2['notifications'] ?? true;

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

    await _sendMatchNotification(
      receiverId: currentUserId,
      matcherId: ownerId,
    );

    await _sendMatchNotification(
      receiverId: ownerId,
      matcherId: currentUserId,
    );

    //send email notifications of match if notifs are on
    if(notif_status1 == true) {
      await _sendMatchEmail(emailAdd);
    }
    if(notif_status2 == true) {
      await _sendMatchEmail(emailAdd2);
    }

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

Future<void> _sendMatchEmail(String recipientEmail) async {
    String username = "closetcampus01@gmail.com";  // Your Gmail
    String password = "rhbk relj axqc kjrl";  // App Password (Replace with secure storage)

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, "Campus Closet")
      ..recipients.add(recipientEmail)
      ..subject = "You've got a match!"
      ..text = "1 new match on Campus Closet, check it out!";

    try {
      await send(message, smtpServer);
      print("✅ Invitation email sent successfully to $recipientEmail");
    } catch (e) {
      print("❌ Failed to send invite email: $e");
    }
  }


Future<void> _sendMatchNotification({
    required String receiverId,
    required String matcherId,
  }) async {
    try {

      // Save notification to Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': receiverId,
        'title': 'New Match!',
        'body': 'You matched with $matcherId',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'match',
      });

    } catch (e) {
      print('Error sending match notification: $e');
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
        title: Row(
            children: [
              const Text("Discover Closets",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 5,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                customizePopup(context);
              },
              child: Text("Customize",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              )
            ]
        )
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

void customizePopup(BuildContext context) async {
  final List<String> categories = [
    'Tops', 
    'Bottoms', 
    'Shoes', 
    'Bags', 
    'Accessories'
  ];
  final List<String> locations = [
    'Purdue University',
    'Indiana University',
    'University of Notre Dame',
    'Ball State University',
    'Indiana State University',
    'Rose-Hulman Institute of Technology',
    'Butler University',
    'Valparaiso University',
    'University of Evansville',
    'Purdue University Fort Wayne',
    'Wabash College'
  ];
  final saved = await loadPreferences();
  Set<String> selectedCategories = saved['categories']!.toSet();
  Set<String> selectedLocations = saved['locations']!.toSet();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Customize'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...categories.map((category) => CheckboxListTile(
                        value: selectedCategories.contains(category),
                        title: Text(category),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? isChecked) {
                          setState(() {
                            if (isChecked == true) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                        },
                      )),
                  const SizedBox(height: 16),
                  const Text('Select Locations', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...locations.map((location) => CheckboxListTile(
                        value: selectedLocations.contains(location),
                        title: Text(location),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? isChecked) {
                          setState(() {
                            if (isChecked == true) {
                              selectedLocations.add(location);
                            } else {
                              selectedLocations.remove(location);
                            }
                          });
                        },
                      )),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Default"),
                onPressed: () {
                  selectedCategories = categories.toSet();
                  selectedLocations = locations.toSet();
                  savePreferences(selectedCategories, selectedLocations);
                  Navigator.of(context).pop();
                  fetchItems();
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text('Apply'),
                onPressed: () {
                  savePreferences(selectedCategories, selectedLocations);
                  Navigator.of(context).pop();
                  fetchItems();
                },
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> savePreferences(Set<String> categories, Set<String> locations) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  await docRef.set({
    'categoryPreferences': categories.toList(),
    'locationPreferences': locations.toList(),
  }, SetOptions(merge: true));
}

Future<Map<String, List<String>>> loadPreferences() async {
const allCategories = [
    'Tops', 
    'Bottoms', 
    'Shoes', 
    'Bags', 
    'Accessories'
  ];
  const allLocations = [
    'Purdue University',
    'Indiana University',
    'University of Notre Dame',
    'Ball State University',
    'Indiana State University',
    'Rose-Hulman Institute of Technology',
    'Butler University',
    'Valparaiso University',
    'University of Evansville',
    'Purdue University Fort Wayne',
    'Wabash College'
  ];

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return {'categories': [], 'locations': []};

  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  final userDoc = await docRef.get();
  final data = userDoc.data() ?? {};

  final hasCategoryPrefs = data.containsKey('categoryPreferences');
  final hasLocationPrefs = data.containsKey('locationPreferences');

  final categoryPrefs = hasCategoryPrefs
      ? List<String>.from(data['categoryPreferences'])
      : allCategories;

  final locationPrefs = hasLocationPrefs
      ? List<String>.from(data['locationPreferences'])
      : allLocations;

  if (!hasCategoryPrefs || !hasLocationPrefs) {
    await docRef.set({
      if (!hasCategoryPrefs) 'categoryPreferences': allCategories,
      if (!hasLocationPrefs) 'locationPreferences': allLocations,
    }, SetOptions(merge: true));
  }

  return {
    'categories': categoryPrefs,
    'locations': locationPrefs,
  };
}

Future<String?> getUserCollege(String userId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!['college'] as String?;
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching college for user $userId: $e');
    return null;
  }
}

}
