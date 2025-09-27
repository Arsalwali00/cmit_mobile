import 'package:flutter/material.dart';
import 'package:cmit/config/routes.dart';

class CmitApp extends StatelessWidget {
  const CmitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMIT',
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
