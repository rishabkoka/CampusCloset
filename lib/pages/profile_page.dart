import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'category_selection.dart'; // Import category selection screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Page',
      theme: ThemeData(
        primaryColor: const Color(0xFFF4F1E3),
        scaffoldBackgroundColor: const Color(0xFFF4F1E3),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 14), // Smaller font size
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 12), // Adjusted smaller font
        ),
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> selectedCategories = [];

  void updateCategories(List<String> categories) {
    setState(() {
      selectedCategories = categories;
    });

    // Show confirmation pop-up
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Preferences Updated"),
          content: const Text("Your category preferences have been saved successfully."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Stubbed data for replacement with API/database calls
    final String fullName = "Loading...";
    final String email = "Loading...";
    final String phone = "Loading...";
    final String bio = "Loading...";
    final String streetAddress = "Loading...";
    final String city = "Loading...";
    final String state = "Loading...";

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Reduced title size
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(title: "Personal Info", children: [
                ProfileInfoRow(label: "Full Name", value: fullName),
                ProfileInfoRow(label: "Email", value: email),
                ProfileInfoRow(label: "Phone", value: phone),
              ]),
              ProfileCard(title: "Bio", children: [
                ProfileInfoRow(label: "Bio", value: bio),
              ]),
              ProfileCard(title: "Address", children: [
                ProfileInfoRow(label: "Street Address", value: streetAddress),
                ProfileInfoRow(label: "City", value: city),
                ProfileInfoRow(label: "State", value: state),
              ]),
              ProfileCard(title: "Preferences", children: [
                selectedCategories.isEmpty
                    ? const Text(
                        "No categories selected",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      )
                    : Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: selectedCategories
                            .map((category) => Chip(
                                  label: Text(
                                    category,
                                    style: const TextStyle(fontSize: 12), // Smaller font size
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.all(2),
                                ))
                            .toList(),
                      ),
                const SizedBox(height: 6),
                button("Select Preferences", Colors.black, Colors.white, () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategorySelectionScreen(selectedCategories),
                    ),
                  );
                  if (result != null) {
                    updateCategories(result);
                  }
                }, 36), // Further reduced button height
              ]),
              const SizedBox(height: 8),
              button("Edit Profile", Colors.black, Colors.white, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfile()),
                );
              }, 44),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced padding for compactness
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Smaller heading
            ),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Reduced padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), // Smaller font
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black54), // Smaller font
          ),
        ],
      ),
    );
  }
}

Widget button(String text, Color backgroundColor, Color textColor, VoidCallback onPressed, double height) {
  return SizedBox(
    width: double.infinity,
    height: height,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Slightly smaller text
      ),
    ),
  );
}
