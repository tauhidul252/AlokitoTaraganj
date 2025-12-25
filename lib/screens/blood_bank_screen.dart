import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBankScreen extends StatelessWidget {
  const BloodBankScreen({super.key});

  Future<void> _callDonor(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not call $number');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Blood Bank',
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade700],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donate Blood',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your blood can save a life. Calls connect directly to donors.',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _buildBloodGroupSection('A+', [
            {'name': 'Rahim Uddin', 'phone': '01700000000', 'loc': 'Sadar'},
            {'name': 'Karim Mia', 'phone': '01800000000', 'loc': 'Upozila'},
          ]),
          _buildBloodGroupSection('O+', [
            {'name': 'Suman Ahmed', 'phone': '01900000000', 'loc': 'Ward 2'},
            {
              'name': 'Lita Akter',
              'phone': '01600000000',
              'loc': 'College Road',
            },
          ]),
          _buildBloodGroupSection('B-', [
            {
              'name': 'Kamal Hasan',
              'phone': '01500000000',
              'loc': 'Hospital Rd',
            },
          ]),
        ],
      ),
    );
  }

  Widget _buildBloodGroupSection(
    String group,
    List<Map<String, String>> donors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  group,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Donors',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        ...donors.map(
          (donor) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: Icon(Icons.person, color: Colors.red.shade400),
              ),
              title: Text(
                donor['name']!,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                donor['loc']!,
                style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13),
              ),
              trailing: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 18,
                  child: Icon(Icons.call, color: Colors.white, size: 18),
                ),
                onPressed: () => _callDonor(donor['phone']!),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
