import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TouristSpotsScreen extends StatelessWidget {
  const TouristSpotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Tourist Spots',
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
          _buildSpotCard(
            'Lalbagh Fort',
            'Historical Mughal fort complex.',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Lalbagh_Kella_%28Lalbagh_Fort%29_Dhaka_Bangladesh_2017.jpg/800px-Lalbagh_Kella_%28Lalbagh_Fort%29_Dhaka_Bangladesh_2017.jpg',
          ),
          _buildSpotCard(
            'Ahsan Manzil',
            'Official residential palace and seat of the Nawab of Dhaka.',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Ahsan_Manzil_Front_View.jpg/800px-Ahsan_Manzil_Front_View.jpg',
          ),
          _buildSpotCard(
            'National Parliament House',
            'Jatiya Sangsad Bhaban, designed by Louis Kahn.',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Jatiya_Sangsad_Bhaban_3.jpg/800px-Jatiya_Sangsad_Bhaban_3.jpg',
          ),
        ],
      ),
    );
  }

  Widget _buildSpotCard(String title, String description, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image.network would go here
                  const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 15,
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Navigate to details or map
                    },
                    child: Text(
                      'Get Directions',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
