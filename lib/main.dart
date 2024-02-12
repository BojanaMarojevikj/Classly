import 'package:classly/screens/splashscreen.dart';
import 'package:classly/service/FirestoreService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final firestoreService = FirestoreService();

  runApp(MyApp(firestoreService: firestoreService));
}

class MyApp extends StatelessWidget {
  final FirestoreService firestoreService;

  MyApp({required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splashscreen(),
    );
  }
}
