import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class GovernmentServicesScreen extends StatelessWidget {
  const GovernmentServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'E-Services',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
        children: [
          _buildInfos(
            context,
            'NID Service',
            Icons.credit_card,
            Colors.green,
            'https://services.nidw.gov.bd/',
          ),
          _buildInfos(
            context,
            'Birth Certificate',
            Icons.child_friendly,
            Colors.pink,
            'https://bdris.gov.bd/',
          ),
          _buildInfos(
            context,
            'Passport',
            Icons.book,
            Colors.blue,
            'https://www.epassport.gov.bd/',
          ),
          _buildInfos(
            context,
            'Land Map',
            Icons.map,
            Colors.brown,
            'https://land.gov.bd/',
          ),
          _buildInfos(
            context,
            'Police Clearance',
            Icons.verified_user,
            Colors.indigo,
            'https://pcc.police.gov.bd/',
          ),
          _buildInfos(
            context,
            'Exam Results',
            Icons.sticky_note_2,
            Colors.orange,
            'http://www.educationboardresults.gov.bd/',
          ),
        ],
      ),
    );
  }

  Widget _buildInfos(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String url,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final Uri uri = Uri.parse(url);
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
