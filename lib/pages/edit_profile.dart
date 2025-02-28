import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/auth.dart';
import 'profile_page.dart';

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
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    String? userId = Auth().currentUser?.uid;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        fullNameController.text = data['fullName'] ?? '';
        phoneController.text = data['phone'] ?? '';
        bioController.text = data['bio'] ?? '';
        streetController.text = data['streetAddress'] ?? '';
        cityController.text = data['city'] ?? '';
        stateController.text = data['state'] ?? '';
      });
    }
  }

  void saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? userId = Auth().currentUser?.uid;

    await _firestore.collection('users').doc(userId).update({
      'fullName': fullNameController.text,
      'phone': phoneController.text,
      'bio': bioController.text,
      'streetAddress': streetController.text,
      'city': cityController.text,
      'state': stateController.text,
    });

    Navigator.pop(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Update your profile information",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8.0),
              const Divider(),
              UserInfoEditField(text: "Full Name", controller: fullNameController),
              UserInfoEditField(text: "Phone", controller: phoneController),
              UserInfoEditField(text: "Bio", controller: bioController),
              UserInfoEditField(text: "Street Address", controller: streetController),
              UserInfoEditField(text: "City", controller: cityController),
              UserInfoEditField(text: "State", controller: stateController),
              const SizedBox(height: 16.0),
              button("Save Profile", Colors.black, Colors.white, saveProfile, 50),
            ],
          ),
        ),
      ),
    );
  }
}

class UserInfoEditField extends StatelessWidget {
  final String text;
  final TextEditingController controller;

  const UserInfoEditField({super.key, required this.text, required this.controller});

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
            controller: controller,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "$text is required";
              }
              return null;
            },
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
