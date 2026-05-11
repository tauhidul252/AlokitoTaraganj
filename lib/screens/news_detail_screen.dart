import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/translations.dart';

class NewsDetailScreen extends StatelessWidget {
  final dynamic newsData;

  const NewsDetailScreen({super.key, required this.newsData});

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return isoString;
    }
  }

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : 'http://127.0.0.1:8000$path';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getFullImageUrl(newsData['image']?.toString());
    final date = _formatDate(newsData['created_at']?.toString());
    final content = newsData['content']?.toString() ?? lang.t('No details available.', 'কোনো বিস্তারিত তথ্য নেই।');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildGlassButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildGlassButton(
                  icon: LucideIcons.bookmark,
                  onTap: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
                child: _buildGlassButton(
                  icon: LucideIcons.share2,
                  onTap: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image, size: 50.0, color: Colors.grey[400]),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image, size: 80.0, color: Colors.grey[400]),
                        ),
                  // Gradient for better text/button visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.0),
                  topRight: Radius.circular(32.0),
                ),
              ),
              transform: Matrix4.translationValues(0.0, -32.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Date Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          'News',
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(LucideIcons.clock, size: 14.0, color: Colors.grey[500]),
                      const SizedBox(width: 6.0),
                      Text(
                        '3 min read',
                        style: GoogleFonts.inter(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  
                  // Title
                  Text(
                    newsData['title']?.toString() ?? '',
                    style: GoogleFonts.outfit(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  
                  // Author Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20.0,
                        backgroundColor: Colors.blue[50],
                        child: Icon(Icons.person, color: Colors.blue[300]),
                      ),
                      const SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            newsData['source']?.toString() ?? 'Admin',
                            style: GoogleFonts.inter(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            date,
                            style: GoogleFonts.inter(
                              fontSize: 13.0,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, size: 16.0, color: Colors.blue),
                            const SizedBox(width: 4.0),
                            Text(
                              lang.t('Verified', 'যাচাইকৃত'),
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32.0),
                  const Divider(color: Color(0xFFE2E8F0), thickness: 1.0),
                  const SizedBox(height: 24.0),
                  
                  // Content
                  Text(
                    content,
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      color: const Color(0xFF334155),
                      height: 1.8,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 80.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
        ),
        child: Icon(icon, color: Colors.white, size: 20.0),
      ),
    );
  }
}
