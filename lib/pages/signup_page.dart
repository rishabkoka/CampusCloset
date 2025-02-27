import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth.dart';
import './login_page.dart';
import './verification.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  bool isLogin = true;
  String? errorMessage = '';

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerPasswordConfirm = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();

  Future<void> createUserWithEmailAndPassword() async {
    if (_controllerPassword.text != _controllerPasswordConfirm.text) {
      setState(() {
        errorMessage = "Passwords do not match";
      });
      return;
    }
    try {
      UserCredential userCredential = await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        //store user in firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': _controllerUsername.text,
          'email': _controllerEmail.text,
          'uid': user.uid
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Verification()),
        );
      } 
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Function to handle Google Sign-Up and prompt for a username
  Future<void> _handleGoogleSignUp() async {
    User? user = await Auth().signInWithGoogle();

    if (user != null) {
      // Check if user already exists in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Ask for a username if user is new
        String? username = await _askForUsername();
        
        if (username != null && username.isNotEmpty) {
          // Save username to Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'username': username,
          });
        }
      }

      // Navigate to verification page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Verification()),
      );
    }
  }

  // Function to prompt the user for a username
  Future<String?> _askForUsername() async {
    TextEditingController usernameController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog without input
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter a Username'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              hintText: 'Username',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(usernameController.text),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E3), // Light Beige Background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Create Account,",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              "to get started now!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),

            // Username Input Field
            TextField(
              controller: _controllerUsername,
              decoration: InputDecoration(
                hintText: "Username",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Email Input Field
            TextField(
              controller: _controllerEmail,
              decoration: InputDecoration(
                hintText: "Email Address",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Password Input Field
            TextField(
              controller: _controllerPassword,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _controllerPasswordConfirm,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Confirm Password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Error message display
            if (errorMessage != null && errorMessage! .isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),

            

            // Signup Button
            ElevatedButton(
              onPressed: createUserWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
                // Login Function
              child: const Text(
                "Sign Up",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // OR Divider
            Row(
              children: const [
                Expanded(child: Divider(thickness: 1, color: Colors.black54)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Or Sign Up With",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Divider(thickness: 1, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 15),

            // Social Login Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialLoginButton("assets/images/google_logo.png", () => _handleGoogleSignUp()),
                    
                  
                 // Google Logo
                const SizedBox(width: 20),
                _socialLoginButton("assets/images/facebook_logo.png", () {

                }) // Facebook Logo
              ],
            ),
            const SizedBox(height: 30),

            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                    // Navigate to Sign Up Page
                  },
                  child: const Text(
                    "Login Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialLoginButton(String imagePath, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: 50,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Image.asset(imagePath, height: 30), // Social Icon
        ),
      ),
    );
  }
}