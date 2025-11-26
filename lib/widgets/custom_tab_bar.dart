import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const CustomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 80,
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              Image.asset(
                _getTabImage(currentIndex),
                width: screenWidth,
                fit: BoxFit.fitWidth,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTabChanged(0),
                      child: Container(
                        height: 80,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTabChanged(1),
                      child: Container(
                        height: 80,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTabChanged(2),
                      child: Container(
                        height: 80,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTabImage(int index) {
    switch (index) {
      case 0:
        return 'assets/pippr_tab_one.webp';
      case 1:
        return 'assets/pippr_tab_two.webp';
      case 2:
        return 'assets/pippr_tab_three.webp';
      default:
        return 'assets/pippr_tab_one.webp';
    }
  }
}

