import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/news_card.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'সব সংবাদ (All News)',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'তারাগঞ্জ এবং আশেপাশের সাম্প্রতিক ঘটনাবলী',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            // এখানে খবরের তালিকা থাকবে
            const NewsCard(
              title: "তারগঞ্জ উপজেলায় নতুন পার্কের উদ্বোধন",
              source: "উপজেলা প্রশাসন",
              date: "আজ",
              imageUrl: "",
            ),
            const SizedBox(height: 15),
            const NewsCard(
              title: "কৃষকদের জন্য বিশেষ কৃষি ঋণের ঘোষণা",
              source: "কৃষি অফিস",
              date: "গতকাল",
              imageUrl: "",
            ),
            const SizedBox(height: 15),
            const NewsCard(
              title: "আগামীকাল বিদ্যুৎ বিভ্রাটের নোটিশ",
              source: "পল্লী বিদ্যুৎ",
              date: "২ ঘণ্টা আগে",
              imageUrl: "",
            ),
            const SizedBox(height: 15),
            const NewsCard(
              title: "স্থানীয় ক্রীড়া প্রতিযোগিতার ফলাফল",
              source: "ক্রীড়া সংস্থা",
              date: "৩ দিন আগে",
              imageUrl: "",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
