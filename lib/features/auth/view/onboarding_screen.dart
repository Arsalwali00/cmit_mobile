import 'package:flutter/material.dart';
import 'package:cmit/config/routes.dart';

class OnboardingScreen extends StatelessWidget {
    const OnboardingScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            const SizedBox(height: 40),

                            /// ✅ Logo at Top
                            Center(
                                child: Image.asset(
                                    'assets/images/splash/logo.png',
                                    height: 80,
                                ),
                            ),

                            const SizedBox(height: 16),

                            /// ✅ Title
                            const Text(
                                "Welcome to\nCMIT Field Data App",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                ),
                            ),

                            const SizedBox(height: 40),

                            /// ✅ Illustration (Farmer / Man)
                            Expanded(
                                child: Center(
                                    child: Image.asset(
                                        'assets/images/onboarding/man.png',
                                        height: 220,
                                    ),
                                ),
                            ),

                            /// ✅ Description
                            const Text(
                                "Easily manage and report field inquiries from anywhere.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                ),
                            ),

                            const SizedBox(height: 40),

                            /// ✅ Get Started Button
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () {
                                        Navigator.pushNamed(context, Routes.login);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF014323),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 24),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                        ),
                                    ),
                                    child: const Text(
                                        "Get Started",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                        ),
                                    ),
                                ),
                            ),

                            const SizedBox(height: 40),
                        ],
                    ),
                ),
            ),
        );
    }
}