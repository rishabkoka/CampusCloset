import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widget_tree.dart';
import './pages/home_page.dart';
import './pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

// await Firebase.initializeApp(
//   options: FirebaseOptions(
//     apiKey: 'key',
//     appId: 'id',
//     messagingSenderId: 'sendid',
//     projectId: 'myapp',
//     storageBucket: 'myapp-b9yt18.appspot.com',
//   )
// );

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key : key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const WidgetTree(),

      // Set up the routes
      routes: {
        '/login': (context) => LoginPage(),
        '/home:': (context) => HomePage(),
      },
    );
  }
}
