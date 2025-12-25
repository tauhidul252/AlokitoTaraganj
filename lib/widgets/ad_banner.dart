import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Mock Ad Widget
class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ad_units, color: Colors.grey[500]),
          Text(
            'Advertisement Area',
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 10),
          ),
        ],
      ),
    );
  }
}
