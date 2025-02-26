import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './home_page.dart';

class Verification extends StatefulWidget {
  @override
  VerificationState createState() => VerificationState();
}

class VerificationState extends State<Verification> {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool isVerificationEmailSent = false;
  bool isPhoneVerified = false;
  bool isVerificationTextSent = false;
  TextEditingController _phoneController = TextEditingController();
  String _verificationId = '';

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      isEmailVerified = _user!.emailVerified;
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (_user != null && !isEmailVerified) {
      try {
        await _user!.sendEmailVerification();
        setState(() {
          isVerificationEmailSent = true; 
        });
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Verification Email Sent"),
              content: Text("A verification email has been sent to ${_user?.email}. Please check your inbox and verify your email address."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();  // Close the dialog
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );

      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Error sending email verification: $e"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();  // Close the dialog
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _checkEmailVerification() async {
    await _user?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      setState(() {
        isEmailVerified = true;
      });
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Email Verified"),
            content: Text("Your email has been successfully verified"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Email Not Verified"),
            content: Text("Your email is not yet verified. Please check your inbox."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();  // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> sendVerificationText() async {
    String phoneNumber = _phoneController.text.trim();

    // Show loading indicator while sending the code
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically sign in the user if the phone number is verified
        await _auth.signInWithCredential(credential);
        // Dismiss the loading dialog
        Navigator.of(context).pop();
        setState(() {
          isPhoneVerified = true;
        });
        // Optionally, show success message or navigate to the next screen
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Phone number verified successfully"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          ),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        Navigator.of(context).pop(); // Dismiss the loading dialog
        // Handle verification failure (e.g., invalid phone number)
        print("Phone number verification failed: ${e.message}");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Verification failed"),
            content: Text(e.message ?? "Unknown error occurred"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.of(context).pop(); // Dismiss the loading dialog
        setState(() {
          _verificationId = verificationId;
        });
        // Show a dialog to input the OTP
        _showOtpDialog();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle auto retrieval timeout
        Navigator.of(context).pop(); // Dismiss the loading dialog
        print("Code auto retrieval timed out.");
      },
    );
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController otpController = TextEditingController();

        return AlertDialog(
          title: Text("Enter OTP"),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'OTP Code',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String otp = otpController.text.trim();

                if (otp.length == 6) {
                  // Verify OTP
                  try {
                    PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: _verificationId,
                      smsCode: otp,
                    );
                    await _auth.signInWithCredential(credential);
                    Navigator.of(context).pop(); // Close OTP dialog
                    setState(() {
                      isPhoneVerified = true;
                    });

                    // Optionally show success message
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Phone number verified successfully!"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    print("Failed to verify OTP: $e");
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Verification failed"),
                        content: Text("Invalid OTP entered"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: Text("Verify"),
            ),
          ],
        );
      },
    );
  }

  void showPhoneNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Phone Number"),
          content: TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+1 123 456 7890',
              ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close phone number input dialog
                sendVerificationText(); // Send verification code
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E3),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 60.0, 0, 0),
              child:
                Text(
                  'Account Verification',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: EdgeInsets.fromLTRB(0, 15.0, 0, 10.0),
              child:
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
            ),
            Row(
              children: [
                if (!isVerificationEmailSent)
                  SizedBox(width: 8),
                SizedBox(width: 7),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 240, 238, 227),
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _sendVerificationEmail,
                  child: Text(
                    isVerificationEmailSent ? 'Resend Verification Email' : 'Send Verification Email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 240, 238, 227),
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _checkEmailVerification,
                  child: Text(
                    'Check Verification',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              isEmailVerified ? "Email has been verified!" : "Email has not been verified",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: EdgeInsets.fromLTRB(0, 15.0, 0, 10.0),
              child:
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
            ),
            Row(
              children: [
                if (!isVerificationEmailSent)
                  SizedBox(width: 7),
                SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 240, 238, 227),
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    showPhoneNumberDialog();
                  },
                  child: Text(
                    isVerificationEmailSent ? 'Resend Verification Text' : 'Send Verification Text',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 240, 238, 227),
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {},
                  child: Text(
                    'Check Verification',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              isPhoneVerified ? "Phone number has been verified!" : "Phone number has not been verified",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 75.0,
            height: 40.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text(
                "Next",
                style: TextStyle(
                  color: Colors.black,
                )
              ),
              backgroundColor: Color.fromARGB(255, 240, 238, 227),
            ),
          )
        ),
      ),
    );
  }
}
