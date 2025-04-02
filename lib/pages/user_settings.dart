import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_firebase_project/pages/send_email.dart'; // Update path as needed

class UserSettings extends StatefulWidget {
  const UserSettings({Key? key}) : super(key: key);

  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController inviteController = TextEditingController();
  final TextEditingController issueController = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('blocked_users')
        .where('blockedBy', isEqualTo: currentUserId)
        .get();
    setState(() {
      blockedUsers = snapshot.docs;
    });
  }

  Future<void> unblockUser(String docId) async {
    await FirebaseFirestore.instance.collection('blocked_users').doc(docId).delete();
    fetchBlockedUsers(); // refresh list
    Fluttertoast.showToast(msg: "✅ User unblocked!");
  }

  Future<void> inviteUser() async {
    String input = inviteController.text.trim();
    if (input.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter an email.");
      return;
    }

    try {
      await sendInviteEmail(input);
      Fluttertoast.showToast(msg: "✅ Invitation sent to $input!");
      inviteController.clear();
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Failed to send invitation: $e");
    }
  }

  Future<void> sendReport(String issueText) async {
    if (issueText.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter an issue before submitting.");
      return;
    }

    try {
      await sendIssueReport(issueText);
      Fluttertoast.showToast(msg: "✅ Issue reported successfully!");
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Failed to send report: $e");
    }
  }

  Future<void> logoutPopup(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                await _auth.signOut();
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email', errorText: errorMessage),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password', errorText: errorMessage),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = _auth.currentUser!;
                  final credential = EmailAuthProvider.credential(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.delete();
                  Navigator.pushReplacementNamed(context, '/login');
                } on FirebaseAuthException catch (e) {
                  setState(() => errorMessage = e.message);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> passwordPopup(BuildContext context) async {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? errorMessage;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(obscureText: true, controller: oldPassCtrl, decoration: const InputDecoration(labelText: 'Old Password')),
              TextField(obscureText: true, controller: newPassCtrl, decoration: const InputDecoration(labelText: 'New Password')),
              TextField(obscureText: true, controller: confirmCtrl, decoration: const InputDecoration(labelText: 'Confirm New Password')),
              if (errorMessage != null && errorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (newPassCtrl.text != confirmCtrl.text) {
                  setState(() => errorMessage = "Passwords do not match.");
                  return;
                }

                if (oldPassCtrl.text == newPassCtrl.text) {
                  setState(() => errorMessage = "New password can't be same as old.");
                  return;
                }

                try {
                  final user = _auth.currentUser!;
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldPassCtrl.text,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPassCtrl.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password changed successfully")),
                  );
                } catch (e) {
                  setState(() => errorMessage = "Incorrect old password or error occurred.");
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> reportIssuePopup(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Report an Issue"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Describe the issue you are facing:"),
            const SizedBox(height: 10),
            TextField(
              controller: issueController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter your issue here...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              sendReport(issueController.text);
              issueController.clear();
              Navigator.pop(context);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F1E3),
        elevation: 0,
        title: const Text("User Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: Column(
              children: [
                Icon(Icons.account_circle, size: 80, color: Colors.black54),
                SizedBox(height: 8),
                Text('User', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ),
          const SizedBox(height: 30),

          /// Invite Someone
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text("Invite Someone", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                    onPressed: inviteUser,
                    icon: const Icon(Icons.email),
                    label: const Text("Send Invite"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          /// Report Issue
          ListTile(
            leading: const Icon(Icons.report_problem, color: Colors.red, size: 30),
            title: const Text("Report an Issue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: const Text("Tell us about any issues you are facing."),
            onTap: () => reportIssuePopup(context),
          ),
          const Divider(),

          /// Blocked Users Section
          const Text("Blocked Users", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          blockedUsers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text("You haven't blocked anyone."),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: blockedUsers.length,
                  itemBuilder: (context, index) {
                    final doc = blockedUsers[index];
                    final blockedUserId = doc['blockedUserId'];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(blockedUserId).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final userData = snapshot.data!;
                        final username = userData['username'] ?? 'Unknown';
                        return ListTile(
                          title: Text(username),
                          trailing: TextButton(
                            onPressed: () => unblockUser(doc.id),
                            child: const Text("Unblock", style: TextStyle(color: Colors.red)),
                          ),
                        );
                      },
                    );
                  },
                ),
          const SizedBox(height: 30),

          /// Change Password
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
            onPressed: () => passwordPopup(context),
            icon: const Icon(Icons.password),
            label: const Text('Change Password'),
          ),
          const SizedBox(height: 15),

          /// Delete Account
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            onPressed: () => deleteAccountPopup(context),
            icon: const Icon(Icons.delete),
            label: const Text('Delete Account'),
          ),
          const SizedBox(height: 15),

          /// Log Out
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
            onPressed: () => logoutPopup(context),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
