// lib/app.dart
import 'package:flutter/material.dart';
import 'presentation/pages/auth/login_page.dart';

class NoSheetApp extends StatelessWidget {
  const NoSheetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoSheet CRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}