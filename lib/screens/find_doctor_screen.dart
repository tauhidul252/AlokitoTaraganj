import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FindDoctorScreen extends StatelessWidget {
  const FindDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Find a Doctor',
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
          // Search Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  'Search by name or specialty...',
                  style: GoogleFonts.inter(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          _buildSpecialtySection('Medicine Specialist', [
            {
              'name': 'Dr. Abdul Malek',
              'deg': 'MBBS, FCPS',
              'loc': 'Sadar Hospital',
            },
            {
              'name': 'Dr. Salma Begum',
              'deg': 'MBBS, MD',
              'loc': 'City Clinic',
            },
          ]),
          _buildSpecialtySection('Cardiologist', [
            {
              'name': 'Dr. Harun Ur Rashid',
              'deg': 'MBBS, D-Card',
              'loc': 'Heart Inst.',
            },
          ]),
          _buildSpecialtySection('Pediatrician', [
            {
              'name': 'Dr. Farhana',
              'deg': 'MBBS, DCH',
              'loc': 'Shisu Hospital',
            },
          ]),
          _buildSpecialtySection('Dentist', [
            {'name': 'Dr. Kamal Hossain', 'deg': 'BDS', 'loc': 'Smile Care'},
          ]),
        ],
      ),
    );
  }

  Widget _buildSpecialtySection(
    String specialty,
    List<Map<String, String>> doctors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 15),
          child: Text(
            specialty,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142),
            ),
          ),
        ),
        ...doctors.map(
          (doc) => Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://placeholder.com/doctor.jpg',
                        ), // Placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.cyan,
                    ), // Fallback
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['name']!,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doc['deg']!,
                          style: GoogleFonts.inter(
                            color: Colors.cyan[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doc['loc']!,
                          style: GoogleFonts.inter(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 0,
                      ),
                      backgroundColor: Colors.cyan[50],
                      foregroundColor: Colors.cyan[700],
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text('Book'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
