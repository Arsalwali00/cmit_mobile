import 'package:flutter/material.dart';
import 'package:cmit/config/routes.dart';
import 'package:cmit/config/theme.dart';

class CmitApp extends StatelessWidget {
  const CmitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMIT',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: Routes.initial,
      routes: Routes.getRoutes(),
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(child: Text('Route not found: ${settings.name}')),
        ),
      ),
    );
  }
}