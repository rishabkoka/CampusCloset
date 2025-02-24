import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edit Profile',
      theme: ThemeData(
        primaryColor: const Color(0xFFF4F1E3),
        scaffoldBackgroundColor: const Color(0xFFF4F1E3),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ),
      home: const EditProfile(),
    );
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  String fullName = "";
  String email = "";
  String phone = "";
  String bio = "";
  String streetAddress = "";
  String city = "";
  String state = "";

  void saveProfile() {
    print("Profile Saved: ");
    print("Full Name: $fullName");
    print("Email: $email");
    print("Phone: $phone");
    print("Bio: $bio");
    print("Street Address: $streetAddress");
    print("City: $city");
    print("State: $state");
  }

  void cancelEdit() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Update your profile information",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            Form(
              child: Column(
                children: [
                  UserInfoEditField(
                    text: "Full Name",
                    onChanged: (value) => setState(() => fullName = value),
                  ),
                  UserInfoEditField(
                    text: "Email",
                    onChanged: (value) => setState(() => email = value),
                  ),
                  UserInfoEditField(
                    text: "Phone",
                    onChanged: (value) => setState(() => phone = value),
                  ),
                  UserInfoEditField(
                    text: "Bio",
                    onChanged: (value) => setState(() => bio = value),
                  ),
                  UserInfoEditField(
                    text: "Street Address",
                    onChanged: (value) => setState(() => streetAddress = value),
                  ),
                  UserInfoEditField(
                    text: "City",
                    onChanged: (value) => setState(() => city = value),
                  ),
                  UserInfoEditField(
                    text: "State",
                    onChanged: (value) => setState(() => state = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: button("Cancel", Colors.grey, Colors.black, cancelEdit, 50),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: button("Save", Colors.black, Colors.white, saveProfile, 50),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoEditField extends StatelessWidget {
  final String text;
  final Function(String) onChanged;

  const UserInfoEditField({super.key, required this.text, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Enter $text",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: onChanged,
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
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
