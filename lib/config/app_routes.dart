import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/main_tab_screen.dart';
import '../screens/dynamic_list_screen.dart';
import '../screens/talent_list_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/pippr_wallet_screen.dart';
import '../screens/pippr_vip_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
  static const String dynamicList = '/dynamic-list';
  static const String talentList = '/talent-list';
  static const String aboutUs = '/about-us';
  static const String wallet = '/wallet';
  static const String vip = '/vip';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      home: (context) => const MainTabScreen(),
      termsOfService: (context) => const TermsOfServiceScreen(),
      privacyPolicy: (context) => const PrivacyPolicyScreen(),
      dynamicList: (context) => const DynamicListScreen(),
      talentList: (context) => const TalentListScreen(),
      aboutUs: (context) => const AboutUsScreen(),
      wallet: (context) => const WalletScreen(),
      vip: (context) => const PipprVipScreen(),
    };
  }
}

