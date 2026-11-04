
import 'package:flutter/material.dart';

import 'constants/app_constants.dart';
import 'constants/app_theme.dart';
import 'screens/main_navigation_screen.dart';

class ApoTechApp extends StatelessWidget {
  const ApoTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
