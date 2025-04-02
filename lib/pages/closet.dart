import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selling.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClosetPage extends StatefulWidget {
  const ClosetPage({Key? key}) : super(key: key);

  @override
  _ClosetPageState createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  bool isDeleteMode = false; // Toggles delete icons
  String sortBy = 'category';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F1E3),
        title: const Text('My Closet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isDeleteMode ? Icons.cancel : Icons.remove, size: 32, color: Colors.red),
            onPressed: () {
              setState(() {
                isDeleteMode = !isDeleteMode; // Toggle delete mode
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SellingPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Sort by: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width:10),
                DropdownButton<String>(
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(value: 'category', child: Text('Category')),
                    DropdownMenuItem(value: 'brand', child: Text('Brand')),
                    DropdownMenuItem(value: 'size', child: Text('Size')),
                    DropdownMenuItem(value: 'color', child: Text('Color')),
                    DropdownMenuItem(value: 'condition', child: Text('Condition')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('items')
              .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Your closet is empty."));
                }

          // Organize items by category
                Map<String, List<DocumentSnapshot>> groupedItems = {};

                for (var doc in snapshot.data!.docs) {
                  String key = doc[sortBy] ?? 'Unknown';
                  if(!groupedItems.containsKey(key)) {
                    groupedItems[key] = [];
                  }
                  groupedItems[key]!.add(doc);
                
                }
                List<String> sortedKeys = groupedItems.keys.toList()..sort();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedKeys.map((key) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: groupedItems[key]!.map((item) {
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Image.network(item['imageUrl'], width: 100, height: 100, fit: BoxFit.cover),
                                    ),
                                    if (isDeleteMode) // Show delete icon only in delete mode
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                                          onPressed: () => _confirmDelete(context, item.id),
                                        ),
                                      ),
                                  ],
                                );
                             }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('items').doc(itemId).delete();
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}