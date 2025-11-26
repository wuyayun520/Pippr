import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/background_image_wrapper.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: BackgroundImageWrapper(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
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
              '1. Acceptance of Terms',
              'By accessing and using Pippr, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily download one copy of Pippr for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n'
              '• Modify or copy the materials\n'
              '• Use the materials for any commercial purpose or for any public display\n'
              '• Attempt to decompile or reverse engineer any software contained in Pippr\n'
              '• Remove any copyright or other proprietary notations from the materials',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '3. User Content',
              'You retain all rights to any content you submit, post, or display on or through Pippr. By submitting, posting, or displaying content on or through Pippr, you grant us a worldwide, non-exclusive, royalty-free license to use, reproduce, modify, adapt, publish, translate, and distribute such content for the purpose of operating and promoting Pippr.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '4. Prohibited Uses',
              'You may use Pippr only for lawful purposes and in accordance with these Terms. You agree not to use Pippr:\n\n'
              '• In any way that violates any applicable national or international law or regulation\n'
              '• To transmit, or procure the sending of, any advertising or promotional material\n'
              '• To impersonate or attempt to impersonate the company, a company employee, another user, or any other person or entity\n'
              '• In any way that infringes upon the rights of others, or in any way is illegal, threatening, fraudulent, or harmful',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '5. Intellectual Property',
              'The Service and its original content, features, and functionality are and will remain the exclusive property of Pippr and its licensors. The Service is protected by copyright, trademark, and other laws.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '6. Termination',
              'We may terminate or suspend your account and bar access to the Service immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation, including but not limited to a breach of the Terms.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '7. Disclaimer',
              'The information on this Service is provided on an "as is" basis. To the fullest extent permitted by law, Pippr excludes all representations, warranties, conditions, and terms relating to our Service.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '8. Limitation of Liability',
              'In no event shall Pippr, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your use of the Service.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '9. Governing Law',
              'These Terms shall be interpreted and governed by the laws of the jurisdiction in which Pippr operates, without regard to its conflict of law provisions.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '10. Changes to Terms',
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days notice prior to any new terms taking effect.',
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
              'If you have any questions about these Terms of Service, please contact us at support@pippr.com',
              style: const TextStyle(
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

