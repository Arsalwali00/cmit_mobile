import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String label;

  const DetailScreen({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$label Details'),
      ),
      body: Center(
        child: Text(
          'Welcome to the $label Detail Screen!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}