import 'dart:async';
import 'package:classly/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 5),
          () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigation()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Classly",
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 36.0,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
            fontFamily: "Zen Kaku Gothic New",
          ),
        ),
      ),
    );
  }
}
