import 'package:flutter/material.dart';

class BackgroundImageWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundImageWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/pippr_allBGView.webp',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Background Image Not Found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          child,
        ],
      ),
    );
  }
}

