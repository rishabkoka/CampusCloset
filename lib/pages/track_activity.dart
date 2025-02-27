import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrackActivity extends StatefulWidget {
  final Widget child;

  const TrackActivity({Key? key, required this.child}) : super(key: key);

  @override
  TrackActivityState createState() => TrackActivityState();
}

class TrackActivityState extends State<TrackActivity> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  BuildContext? _currentContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentContext = context;
      checkLastActiveTime(context);
  });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //print("STATE: ${state}");
    if (state != AppLifecycleState.resumed) {
      updateLastActiveTime();
    } else {
      if (_currentContext != null) {
        checkLastActiveTime(_currentContext!);
      }
    }
  }

  Future<void> updateLastActiveTime() async {
  final User? user = _auth.currentUser;
  if (user != null) {
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        await userDoc.update({
          'lastActiveTime': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.set({
          'lastActiveTime': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error updating last active time: $e");
    }
  }
}


  Future<void> checkLastActiveTime(BuildContext context) async {
  final User? user = _auth.currentUser;
  if (user != null) {
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final Timestamp? lastActiveTime = data['lastActiveTime'] as Timestamp?;

        if (lastActiveTime != null) {
          final DateTime lastActive = lastActiveTime.toDate();
          final DateTime now = DateTime.now();
          final Duration difference = now.difference(lastActive);
          //print(difference.inSeconds);
          if (difference.inHours >= 12) {
            await _auth.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        print('User document not found.');
      }
    } catch (e) {
      print("Error checking last active time: $e");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
