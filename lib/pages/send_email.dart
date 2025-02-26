import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

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

