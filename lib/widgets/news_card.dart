import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String source;
  final String date;
  final String imageUrl;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.title,
    required this.source,
    required this.date,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Left Side
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: _buildImage(),
            ),
            const SizedBox(width: 16.0),
            // Content Right Side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // Category (Top)
                  Text(
                    'News',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Bottom Row: Avatar + Source + Date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10.0,
                        backgroundColor: Colors.blue[50],
                        child: Icon(Icons.person, size: 12.0, color: Colors.blue[300]),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          '$source • $date',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl.startsWith('http') ? imageUrl : 'http://127.0.0.1:8000$imageUrl',
        width: 100.0,
        height: 100.0,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100.0,
      height: 100.0,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 32.0,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
