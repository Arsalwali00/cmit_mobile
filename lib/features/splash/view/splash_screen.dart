import 'package:flutter/material.dart';
import '../presenter/splash_presenter.dart';
import 'package:cmit/config/routes.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashPresenter _presenter = SplashPresenter();

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  /// ✅ **Splash Timer Before Navigation**
  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      _navigate();
    });
  }

  /// ✅ **Handle Navigation Based on Authentication Status**
  void _navigate() {
    _presenter.checkAuthentication().then((isAuthenticated) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          isAuthenticated ? Routes.home : Routes.welcome,
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // ✅ Prevents back navigation
      child: Scaffold(
        backgroundColor: Colors.white, // ✅ White Background
        body: Stack(
          children: [
            /// ✅ Top Left Decorative Image
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                'assets/images/splash/Top_Left.png',
                width: 100,
              ),
            ),

            /// ✅ Top Right Decorative Image
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                'assets/images/splash/Top_Right.png',
                width: 100,
              ),
            ),

            /// ✅ Center Logo
            Center(
              child: Image.asset(
                'assets/images/splash/logo.png',
                width: 150,
                height: 150,
              ),
            ),

            /// ✅ Bottom Mountain Image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/splash/mountain.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
