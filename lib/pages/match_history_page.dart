import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchHistoryPage extends StatefulWidget {
  @override
  _MatchHistoryPageState createState() => _MatchHistoryPageState();
}

class _MatchHistoryPageState extends State<MatchHistoryPage> {
  List<DocumentSnapshot> matchedItems = [];
  String sortBy = 'category';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatchedItems();
  }

  Future<void> fetchMatchedItems() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final blockedUserIds = <String>[]; // Populate if needed

    final matchSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .get();

    List<DocumentSnapshot> items = [];

    for (var matchDoc in matchSnapshot.docs) {
      final users = List<String>.from(matchDoc['users']);
      final itemA = matchDoc['itemA'];
      final itemB = matchDoc['itemB'];

      final isCurrentUserFirst = users[0] == currentUserId;
      final otherUserId = isCurrentUserFirst ? users[1] : users[0];
      if (blockedUserIds.contains(otherUserId)) continue;

      final otherItemId = isCurrentUserFirst ? itemA : itemB;

      final itemSnapshot = await FirebaseFirestore.instance
          .collection('items')
          .doc(otherItemId)
          .get();

      if (itemSnapshot.exists) {
        items.add(itemSnapshot);
      }
    }

    setState(() {
      matchedItems = items;
      isLoading = false;
    });
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF4F1E3),
    appBar: AppBar(
      backgroundColor: const Color(0xFFF4F1E3),
      title: const Text('Match History',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : matchedItems.isEmpty
            ? const Center(child: Text("No matched items yet."))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Text('Sort by: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
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
                  Expanded(child: buildItemGrid()),
                ],
              ),
  );
}


  Widget buildItemGrid() {
    Map<String, List<DocumentSnapshot>> groupedItems = {};

    for (var item in matchedItems) {
      String key = item[sortBy] ?? 'Unknown';
      groupedItems.putIfAbsent(key, () => []).add(item);
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
              Text(key,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: groupedItems[key]!.map((item) {
                    return GestureDetector(
                      onTap: () => _showItemDetails(context, item),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Image.network(item['imageUrl'],
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
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
  }

  void _showItemDetails(BuildContext context, DocumentSnapshot item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item['category'] ?? 'Unknown Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(item['imageUrl'],
                  width: 200, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 10),
              Text("Brand: ${item['brand'] ?? 'N/A'}"),
              Text("Size: ${item['size'] ?? 'N/A'}"),
              Text("Color: ${item['color'] ?? 'N/A'}"),
              Text("Condition: ${item['condition'] ?? 'N/A'}"),
              Text("Status: ${item['status'] ?? 'N/A'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
