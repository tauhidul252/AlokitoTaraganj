import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Alokito Taraganj',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Last Updated: December 2025',
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            _buildSection(
              '1. Introduction',
              'Welcome to Alokito Taraganj. We respect your privacy and represent that we do not collect any personal data without your consent.',
            ),
            _buildSection(
              '2. Information We Collect',
              'We may collect contact information (like phone numbers) only when you voluntarily provide it for services like Complaint Box or Blood Bank.',
            ),
            _buildSection(
              '3. Use of Information',
              'The information is used solely to facilitate the specific service you requested (e.g., connecting with a blood donor or submitting a complaint).',
            ),
            _buildSection(
              '4. Third Party Services',
              'This app may contain links to third-party government websites. We are not responsible for the privacy practices of those sites.',
            ),
            _buildSection(
              '5. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us via the app\'s support section.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
