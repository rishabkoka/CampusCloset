import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'package:flutter_firebase_project/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ),
      home: const CompleteProfile(),
    );
  }
}

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  CompleteProfileState createState() => CompleteProfileState();
}

class CompleteProfileState extends State<CompleteProfile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  String? selectedCollege;
  final List<String> colleges = [
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

  void saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? userId = Auth().currentUser?.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fullName': fullNameController.text,
      'phone': phoneController.text,
      'bio': bioController.text,
      'streetAddress': streetAddressController.text,
      'city': cityController.text,
      'state': stateController.text,
      'college': selectedCollege,
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
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
          "Complete Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Complete your details to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8.0),
              const Divider(),
              UserInfoEditField(text: "Full Name", controller: fullNameController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "College",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6.0),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Select College",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: selectedCollege,
                      items: colleges.map((college) {
                        return DropdownMenuItem(
                          value: college,
                          child: Text(college),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCollege = value;
                        });
                      },
                      validator: (value) => value == null ? "Please select a college" : null,
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: .0),
              UserInfoEditField(text: "Phone", controller: phoneController),
              UserInfoEditField(text: "Bio", controller: bioController),
              UserInfoEditField(text: "Street Address", controller: streetAddressController),
              UserInfoEditField(text: "City", controller: cityController),
              UserInfoEditField(text: "State", controller: stateController),
              const SizedBox(height: 8.0),
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
