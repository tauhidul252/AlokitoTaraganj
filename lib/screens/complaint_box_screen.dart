import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintBoxScreen extends StatelessWidget {
  const ComplaintBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Complaint Box',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepOrange.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: Colors.deepOrange, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'We respect your privacy. Your identity will be kept confidential if requested.',
                      style: GoogleFonts.inter(
                        color: Colors.deepOrange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'Submit your complaint',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Fill out the form below to reach District Admin directly.',
              style: GoogleFonts.inter(color: Colors.grey[500]),
            ),

            const SizedBox(height: 25),

            _buildTextField(label: 'Your Name', icon: Icons.person),
            const SizedBox(height: 15),
            _buildTextField(
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            // Custom Dropdown UI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.category, color: Colors.grey),
                  labelText: 'Complaint Type',
                  labelStyle: GoogleFonts.inter(color: Colors.grey[500]),
                ),
                dropdownColor: Colors.white,
                items: ['Road', 'Water', 'Electricity', 'Corruption', 'Other']
                    .map((String val) {
                      return DropdownMenuItem(
                        value: val,
                        child: Text(val, style: GoogleFonts.inter()),
                      );
                    })
                    .toList(),
                onChanged: (_) {},
              ),
            ),

            const SizedBox(height: 15),
            _buildTextField(label: 'Description', maxLines: 5),

            const SizedBox(height: 15),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: false,
                    onChanged: (v) {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    activeColor: Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Keep me anonymous',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: Colors.deepOrange.withOpacity(0.4),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complaint Submitted Successfully'),
                    ),
                  );
                },
                child: Text(
                  'Submit Complaint',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
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
      child: TextField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
