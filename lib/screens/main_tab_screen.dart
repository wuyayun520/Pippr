import 'package:flutter/material.dart';
import '../widgets/custom_tab_bar.dart';
import 'tab_one_screen.dart';
import 'tab_two_screen.dart';
import 'tab_three_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TabOneScreen(),
    const TabTwoScreen(),
    const TabThreeScreen(),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          CustomTabBar(
            currentIndex: _currentIndex,
            onTabChanged: _onTabChanged,
          ),
        ],
      ),
    );
  }
}

