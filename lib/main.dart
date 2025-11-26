import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'config/app_routes.dart';
import 'constants/app_constants.dart';

void main() {
  runApp(const PipprApp());
}

class PipprApp extends StatelessWidget {
  const PipprApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routes: AppRoutes.getRoutes(),
      initialRoute: AppRoutes.login,
      debugShowCheckedModeBanner: false,
    );
  }
}
