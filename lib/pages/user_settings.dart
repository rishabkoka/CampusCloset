import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({Key? key}) : super(key: key);

  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController inviteController = TextEditingController();

  Future<void> logoutPopup(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAccountPopup(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: errorMessage,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      User user = _auth.currentUser!;
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      await user.reauthenticateWithCredential(credential);
                      await user.delete();
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login');
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        errorMessage = e.message;
                      });
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> inviteUser() async {
    String input = inviteController.text.trim();
    if (input.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter an email.");
      return;
    }

    // Simulating invite process (Replace this with actual email/SMS sending logic)
    Future.delayed(const Duration(seconds: 1), () {
      Fluttertoast.showToast(msg: "Invitation sent to $input!");
      inviteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F1E3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "User Settings",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(Icons.account_circle, size: 80, color: Colors.black54),
                  SizedBox(height: 8),
                  Text(
                    'User',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            /// **Invite Feature**
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Invite Someone",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: inviteController,
                      decoration: InputDecoration(
                        hintText: "Enter email",
                        prefixIcon: const Icon(Icons.send),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: inviteUser,
                      icon: const Icon(Icons.email),
                      label: const Text("Send Invite"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// **Delete Account Button**
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
              onPressed: () {
                deleteAccountPopup(context);
              },
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'Delete Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),

            /// **Log Out Button**
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
              onPressed: () {
                logoutPopup(context);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Log Out',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
