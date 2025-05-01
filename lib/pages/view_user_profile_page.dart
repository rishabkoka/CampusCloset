import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewUserProfilePage extends StatefulWidget {
  final String otherUserId;

  const ViewUserProfilePage({Key? key, required this.otherUserId}) : super(key: key);

  @override
  State<ViewUserProfilePage> createState() => _ViewUserProfilePageState();
}

class _ViewUserProfilePageState extends State<ViewUserProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.otherUserId).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("User not found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${userData!['fullName']}'s Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: userData!['profilePicURL'] != null
                    ? NetworkImage(userData!['profilePicURL'])
                    : const AssetImage('assets/images/defaultprofilepic.jpg') as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userData!['fullName'] ?? "No Name",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "@${userData!['username'] ?? 'username'}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Personal Info Card
            ProfileCard(title: "Personal Info", children: [
              ProfileInfoRow(label: "Full Name", value: userData!['fullName'] ?? "N/A"),
              ProfileInfoRow(label: "College", value: userData!['college'] ?? "N/A"),
              ProfileInfoRow(label: "Email", value: userData!['email'] ?? "N/A"),
              ProfileInfoRow(label: "Phone", value: userData!['phone'] ?? "N/A"),
            ]),

            const SizedBox(height: 12),

            // Bio
            if (userData!['bio'] != null)
              ProfileCard(
                title: "About Me", children: [
                  ProfileInfoRow(label: "Bio", value: userData!['bio'] ?? "N/A")
                ],
              ),

            const SizedBox(height: 12),


            // Address
            if (userData!['streetAddress'] != null || userData!['city'] != null || userData!['state'] != null)
              ProfileCard(
                title: "Address",
                children: [
                  ProfileInfoRow(label: "Street Address", value: userData!['streetAddress'] ?? "N/A"),
                  ProfileInfoRow(label: "City", value: userData!['city'] ?? "N/A"),
                  ProfileInfoRow(label: "State", value: userData!['state'] ?? "N/A"),
                ],
              ),

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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
