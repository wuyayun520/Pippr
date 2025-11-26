import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAgreed = true;

  void _handleEnterApp() {
    if (_isAgreed) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/pippr_allBGView.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/pippr_login_shadow.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.4, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        
                        SizedBox(
                          width: double.infinity,
                          height: 86,
                          child: ElevatedButton(
                            onPressed: _handleEnterApp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                            ),
                            child: SizedBox.expand(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF46FB6D),
                                      Color(0xFF3CFFEF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(36),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Enter Pippr',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAgreed = !_isAgreed;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isAgreed
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _isAgreed
                                        ? AppTheme.primaryColor
                                        : Colors.white70,
                                    width: 2,
                                  ),
                                ),
                                child: _isAgreed
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.black87,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'I have read and agree ',
                                        ),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                AppRoutes.termsOfService,
                                              );
                                            },
                                            child: const Text(
                                              'Terms of Service',
                                              style: TextStyle(
                                                color: Colors.white,
                                                decoration: TextDecoration.underline,
                                                decorationColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ' and',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.privacyPolicy,
                                      );
                                    },
                                    child: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

