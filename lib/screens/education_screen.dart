import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Education',
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
          _buildInstitutionTile(
            'Dhaka University',
            'Public University',
            Icons.school,
            Colors.blue,
          ),
          _buildInstitutionTile(
            'Dhaka City College',
            'College',
            Icons.school_outlined,
            Colors.orange,
          ),
          _buildInstitutionTile(
            'Viqarunnisa Noon School',
            'School',
            Icons.backpack,
            Colors.green,
          ),
          _buildInstitutionTile(
            'Notre Dame College',
            'College',
            Icons.school_outlined,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionTile(
    String name,
    String type,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF2D3142),
          ),
        ),
        subtitle: Text(
          type,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey[400],
          ),
        ),
        onTap: () {
          // Open details
        },
      ),
    );
  }
}
