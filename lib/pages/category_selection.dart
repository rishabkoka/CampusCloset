import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatefulWidget {
  final List<String> selectedCategories;

  const CategorySelectionScreen(this.selectedCategories, {super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final List<Map<String, dynamic>> allCategories = [
    {"name": "Clothes", "icon": Icons.checkroom},
    {"name": "Merchandise", "icon": Icons.shopping_bag},
    {"name": "Furniture", "icon": Icons.chair},
  ];
  late List<String> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = List.from(widget.selectedCategories);
  }

  void toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Preferences"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Choose the categories you are interested in:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Column(
              children: allCategories.map((category) {
                return GestureDetector(
                  onTap: () => toggleCategory(category["name"]),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedCategories.contains(category["name"])
                          ? Colors.black
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(
                        category["icon"],
                        color: selectedCategories.contains(category["name"])
                            ? Colors.white
                            : Colors.black,
                      ),
                      title: Text(
                        category["name"],
                        style: TextStyle(
                          color: selectedCategories.contains(category["name"])
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedCategories);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Save Preferences"),
            ),
          ],
        ),
      ),
    );
  }
}
