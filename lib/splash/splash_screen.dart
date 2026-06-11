import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}) ;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<Timer> startTime() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed(MyHomePage.route);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_new
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset(
            'assets/images/app_icon.png',
            width: 220.0,
          ),
        ),
      ),
    );
  }
}
