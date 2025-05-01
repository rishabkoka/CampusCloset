import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendInviteEmail(String recipientEmail) async {
  String username = "closetcampus01@gmail.com";  // Your Gmail
  String password = "rhbk relj axqc kjrl";  // App Password (Replace with secure storage)

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, "Campus Closet")
    ..recipients.add(recipientEmail)
    ..subject = "You're Invited to Campus Closet! 🎉"
    ..text = "Hey there! Join us on Campus Closet. Click the link below to sign up:\n\nhttps://campuscloset.com/signup";

  try {
    await send(message, smtpServer);
    print("✅ Invitation email sent successfully to $recipientEmail");
  } catch (e) {
    print("❌ Failed to send invite email: $e");
  }
}

Future<void> sendIssueReport(String issueText) async {
  if (issueText.isEmpty) {
    Fluttertoast.showToast(msg: "⚠️ Please enter an issue before submitting.");
    return;
  }

  String username = "closetcampus01@gmail.com";  // Your new admin email
  String password = "rhbk relj axqc kjrl";  // Your 16-character app password

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, "Campus Closet Support")
    ..recipients.add("closetcampus01@gmail.com")  // Ensure this is a valid admin email
    ..subject = "🚨 User Issue Report"
    ..text = """
A user has reported an issue:

------------------------
$issueText
------------------------

This message was sent automatically from Campus Closet.
""";

  try {
    final sendReport = await send(message, smtpServer);
    print("✅ Issue report sent successfully: ${sendReport.toString()}");
    Fluttertoast.showToast(msg: "✅ Issue report sent successfully!");
  } catch (e) {
    print("❌ Failed to send issue report: $e");
    Fluttertoast.showToast(msg: "❌ Failed to send report: $e");
  }
}

Future<void> sendConfirmationEmail(String recipientEmail) async {
  String username = "closetcampus01@gmail.com";  // Your Gmail
  String password = "rhbk relj axqc kjrl";  // App Password (Replace with secure storage)

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, "Campus Closet")
    ..recipients.add(recipientEmail)
    ..subject = "Welcome to Campus Closet! 🎉"
    ..text = "Hi, \n\nYou've signed up for Campus Closet! We are so happy to have you. Enjoy!";

  try {
    await send(message, smtpServer);
    print("✅ Confirmation email sent successfully to $recipientEmail");
  } catch (e) {
    print("❌ Failed to send invite email: $e");
  }
}

Future<void> sendPingEmail(String recipientEmail) async {
  String username = "closetcampus01@gmail.com";  // Your Gmail
  String password = "rhbk relj axqc kjrl";  // App Password (Replace with secure storage)

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, "Campus Closet")
    ..recipients.add(recipientEmail)
    ..subject = "We've missed you!"
    ..text = "Visit your closet and check out the new listings!";

  try {
    await send(message, smtpServer);
    print("✅ Invitation email sent successfully to $recipientEmail");
  } catch (e) {
    print("❌ Failed to send invite email: $e");
  }
}

Future<void> sendMessageEmail(String recipientId) async {
  String username = "closetcampus01@gmail.com";  // Your Gmail
  String password = "rhbk relj axqc kjrl";  // App Password (Replace with secure storage)

  final smtpServer = gmail(username, password);

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(recipientId).get();
  final recipientEmail = userDoc['email'] ?? 'Unknown';


    final message = Message()
    ..from = Address(username, "Campus Closet")
    ..recipients.add(recipientEmail)
    ..subject = "You received a message"
    ..text = "1 new message on Campus Closet, check it out!";

    try {
      await send(message, smtpServer);
      print("✅ Invitation email sent successfully to $recipientEmail");
    } catch (e) {
      print("❌ Failed to send invite email: $e");
    }




}