import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/background_image_wrapper.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: BackgroundImageWrapper(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: 2025',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              '1. Introduction',
              'Pippr ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '2. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
              '• Account information (name, email address, profile picture)\n'
              '• Content you create, upload, or share on Pippr\n'
              '• Communications with us (support requests, feedback)\n'
              '• Device information (device type, operating system, unique device identifiers)\n'
              '• Usage data (how you interact with the app, features you use)\n'
              '• Location data (if you grant permission)',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '3. How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Provide, maintain, and improve our services\n'
              '• Process transactions and send related information\n'
              '• Send technical notices, updates, and support messages\n'
              '• Respond to your comments, questions, and requests\n'
              '• Monitor and analyze trends, usage, and activities\n'
              '• Personalize and improve your experience\n'
              '• Detect, prevent, and address technical issues',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '4. Information Sharing and Disclosure',
              'We do not sell your personal information. We may share your information in the following circumstances:\n\n'
              '• With your consent\n'
              '• To comply with legal obligations\n'
              '• To protect our rights and safety\n'
              '• With service providers who assist us in operating our app\n'
              '• In connection with a business transfer (merger, acquisition, etc.)',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '5. Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the Internet or electronic storage is 100% secure.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '6. Your Rights and Choices',
              'You have the right to:\n\n'
              '• Access and receive a copy of your personal data\n'
              '• Rectify inaccurate or incomplete data\n'
              '• Request deletion of your personal data\n'
              '• Object to processing of your personal data\n'
              '• Request restriction of processing\n'
              '• Data portability\n'
              '• Withdraw consent at any time',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '7. Children\'s Privacy',
              'Pippr is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '8. Cookies and Tracking Technologies',
              'We use cookies and similar tracking technologies to track activity on our app and hold certain information. You can instruct your device to refuse all cookies or to indicate when a cookie is being sent.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '9. Third-Party Links',
              'Our Service may contain links to third-party websites or services that are not owned or controlled by Pippr. We have no control over, and assume no responsibility for, the privacy practices of these third-party sites.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '10. International Data Transfers',
              'Your information may be transferred to and maintained on computers located outside of your state, province, country, or other governmental jurisdiction where data protection laws may differ.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '11. Changes to This Privacy Policy',
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '12. Data Retention',
              'We will retain your personal information only for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'If you have any questions about this Privacy Policy, please contact us at:\n\n'
              'Email: privacy@pippr.com\n'
              'Support: support@pippr.com',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            height: 1.6,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

