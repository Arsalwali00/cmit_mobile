import 'package:flutter/material.dart';
import 'package:cmit/features/calculator/view/calculator_screen.dart';
import 'package:cmit/features/statistics/view/setting_screen.dart';
import 'package:cmit/features/profile/view/profile_screen.dart';
import 'package:cmit/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:cmit/features/home/widgets/home_top_section.dart';
import 'package:cmit/features/home/view/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          "Home",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black87),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(), // Moved drawer here
      body: SafeArea(
        child: _currentIndex == 0
            ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeTopSection(),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        )
            : _getPage(_currentIndex),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 1:
        return const CalculatorScreen();
      case 2:
        return const SettingsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}