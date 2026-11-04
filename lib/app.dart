
import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'constants/app_theme.dart';

class ApoTechApp extends StatelessWidget {
  const ApoTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text(
            'ApoTech',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
