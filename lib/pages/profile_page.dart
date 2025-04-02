import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Import for sharing feature
import 'package:url_launcher/url_launcher.dart'; // Import for deep linking
import 'edit_profile.dart';
import 'category_selection.dart'; // Import category selection screen
import 'package:flutter_firebase_project/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


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
          bodyLarge: TextStyle(color: Colors.black, fontSize: 14),
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 12),
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

  Future<void> uploadProfilePic(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String filePath = 'profile_pictures/$userId.jpg';

    try {
      TaskSnapshot uploadTask =
          await FirebaseStorage.instance.ref(filePath).putFile(imageFile);

      String downloadURL = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePicURL': downloadURL,
      });

      print('Profile picture uploaded successfully!');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

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

  // Function to open social media apps
  void openSocialMedia(String platform) async {
    String url = "";

    if (platform == "whatsapp") {
      url = "https://wa.me/?text=Check+out+my+profile!+https://yourapp.com/user/profile";
    } else if (platform == "twitter") {
      url = "twitter://post?message=Check+out+my+profile!+https://yourapp.com/user/profile";
    } else if (platform == "facebook") {
      url = "https://www.facebook.com/sharer/sharer.php?u=https://yourapp.com/user/profile";
    } else if (platform == "instagram") {
      url = "https://www.instagram.com/"; // Instagram does not support direct link sharing
    }

    Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(Uri.parse("https://yourapp.com/user/profile"));
    }
  }

  // Function to share profile
  void shareProfile() async {
    final String profileLink = "https://yourapp.com/user/profile";
    final String message = "Check out my profile on this awesome app! \n$profileLink";

    if (Platform.isAndroid || Platform.isIOS) {
      await Share.share(message);
    }
  }

  // Bottom Sheet for Sharing Options
  void showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Share Your Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  socialIcon(context, "WhatsApp", Icons.message, "whatsapp"),
                  socialIcon(context, "Twitter", Icons.alternate_email, "twitter"),
                  socialIcon(context, "Instagram", Icons.camera_alt, "instagram"),
                  socialIcon(context, "Facebook", Icons.facebook, "facebook"),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => shareProfile(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text("Other Apps"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget socialIcon(BuildContext context, String label, IconData icon, String platform) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 40),
          onPressed: () => openSocialMedia(platform),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

    String fullName = "Loading...";
    String email = "Loading...";
    String phone = "Loading...";
    String bio = "Loading...";
    String streetAddress = "Loading...";
    String city = "Loading...";
    String state = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    String? userId = Auth().currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          fullName = userDoc["fullName"] ?? "No Name";
          email = userDoc["email"] ?? "No Email";
          phone = userDoc["phone"] ?? "No Phone";
          bio = userDoc["bio"] ?? "No Bio";
          streetAddress = userDoc["streetAddress"] ?? "No Address";
          city = userDoc["city"] ?? "No City";
          state = userDoc["state"] ?? "No State";
          // selectedCategories = List<String>.from(userDoc['categories'] ?? []);
        });
      }
    }
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
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => showShareOptions(context),
            tooltip: "Share Profile",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                          return ClipOval(
                            child: Image.asset(
                              'assets/images/defaultprofilepic.jpg',
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          );
                        }
                        var data = snapshot.data!.data() as Map<String, dynamic>;
                        var profilePicURL = data.containsKey('profilePicURL') ? data['profilePicURL'] : null;
                        return ClipOval(
                          child: profilePicURL != null
                              ? Image.network(
                                  profilePicURL,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return ClipOval(
                                      child: Image.asset(
                                        'assets/images/defaultprofilepic.jpg',
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    );
                                  },
                                )
                              : ClipOval(
                                  child: Image.asset(
                                    'assets/images/defaultprofilepic.jpg',
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          uploadProfilePic(ImageSource.camera);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: Size(30, 30),
                        ),
                        child: Text(
                          'Take with Camera',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 0),
                      ElevatedButton(
                        onPressed: () {
                          uploadProfilePic(ImageSource.gallery);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: Size(30, 30),
                        ),
                        child: Text(
                          'Choose from Library',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]
                  ),
                ]
              ),
              SizedBox(height: 8),
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
                                    style: const TextStyle(fontSize: 12),
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
                }, 36),
              ]),
              const SizedBox(height: 8),
              button("Edit Profile", Colors.black, Colors.white, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfile()),
                ).then((_) {
                  fetchUserProfile(); // Refresh profile after returning
                });
              }, 44),
            ],
          ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }
}
