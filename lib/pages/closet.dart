import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selling.dart';

class ClosetPage extends StatefulWidget {
  const ClosetPage({Key? key}) : super(key: key);

  @override
  _ClosetPageState createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  bool isDeleteMode = false; // Toggles delete icons

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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your closet is empty."));
          }

          // Organize items by category
          Map<String, List<DocumentSnapshot>> categorizedItems = {
            'Tops': [],
            'Bottoms': [],
            'Shoes': [],
            'Bags': [],
            'Accessories': []
          };
          for (var doc in snapshot.data!.docs) {
            String category = doc['category'] ?? '';
            if (categorizedItems.containsKey(category)) {
              categorizedItems[category]!.add(doc);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categorizedItems.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: entry.value.map((item) {
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