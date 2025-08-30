import 'package:flutter/material.dart';
import 'package:cmit/app.dart';
import 'package:cmit/core/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApp();

  runApp(const CmitApp());
}

Future<void> _initializeApp() async {
  try {
    await LocalStorage.init();
  } catch (e) {
    debugPrint('Failed to initialize Testify local storage: $e');
  }
}