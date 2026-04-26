import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfessionalServicesScreen extends StatelessWidget {
  const ProfessionalServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Expert Services',
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
        childAspectRatio: 0.85,
        children: [
          _buildCategory(
            Icons.electrical_services,
            'Electrician',
            Colors.amber,
          ),
          _buildCategory(Icons.plumbing, 'Plumber', Colors.blue),
          _buildCategory(Icons.construction, 'Mason / Mistri', Colors.brown),
          _buildCategory(Icons.tv, 'TV/AC Repair', Colors.purple),
          _buildCategory(Icons.local_shipping, 'Truck Rental', Colors.red),
          _buildCategory(Icons.cleaning_services, 'Cleaner', Colors.teal),
        ],
      ),
    );
  }

  Widget _buildCategory(IconData icon, String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // In a real app, go to list of providers
          },
          borderRadius: BorderRadius.circular(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '12 Experts near you',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
