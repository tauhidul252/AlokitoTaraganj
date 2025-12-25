import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Matches Home
      // Note: If used in TabBar, Scaffold might be nested, but usually fine or we just return the body content.
      // Assuming it's used as a screen.
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Text(
            'Local Directory',
            style: GoogleFonts.outfit(
              fontSize: 24, // Matching Header size
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          _buildCategory('Pharmacy', Icons.local_pharmacy, Colors.teal),
          _buildCategory('Groceries', Icons.shopping_basket, Colors.green),
          _buildCategory('Repair Services', Icons.build, Colors.blueGrey),
          _buildCategory('Restaurants', Icons.restaurant, Colors.orangeAccent),
          _buildCategory('Transport', Icons.directions_bus, Colors.indigo),
          _buildCategory('Hotels', Icons.hotel, Colors.purple),
          _buildCategory('Banks', Icons.account_balance, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF2D3142),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () {},
      ),
    );
  }
}
