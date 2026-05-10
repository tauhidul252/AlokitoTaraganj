import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Screens import (আপনার ফাইলের নাম অনুযায়ী)
import 'tourist_spots_screen.dart';
import 'education_screen.dart';
import 'transport_screen.dart';
import 'blood_bank_screen.dart';
import 'job_board_screen.dart';
import 'government_services_screen.dart';
import 'find_doctor_screen.dart';
import 'professional_services_screen.dart';
import 'complaint_box_screen.dart';
import 'settings_screen.dart';
import '../widgets/news_card.dart';
import '../utils/translations.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    // সার্ভিস ডেটা লিস্ট
    final List<Map<String, dynamic>> services = [
      {
        'title': 'E-Services',
        'icon': LucideIcons.globe,
        'color': Colors.blue,
        'action': () => _navigateTo(context, const GovernmentServicesScreen()),
      },
      {
        'title': 'Blood Bank',
        'icon': LucideIcons.droplet,
        'color': Colors.red,
        'action': () => _navigateTo(context, const BloodBankScreen()),
      },
      {
        'title': 'Find Doctor',
        'icon': LucideIcons.userPlus,
        'color': Colors.cyan,
        'action': () => _navigateTo(context, const FindDoctorScreen()),
      },
      {
        'title': 'Emergency',
        'icon': LucideIcons.phoneCall,
        'color': Colors.redAccent,
        'action': () => onTabChange(2),
      },
      {
        'title': 'Expert Svc',
        'icon': LucideIcons.hammer,
        'color': Colors.amber[800],
        'action': () =>
            _navigateTo(context, const ProfessionalServicesScreen()),
      },
      {
        'title': 'Job Board',
        'icon': LucideIcons.briefcase,
        'color': Colors.indigo,
        'action': () => _navigateTo(context, const JobBoardScreen()),
      },
      {
        'title': 'Complaint',
        'icon': LucideIcons.messageSquare,
        'color': Colors.deepOrange,
        'action': () => _navigateTo(context, const ComplaintBoxScreen()),
      },
      {
        'title': 'News',
        'icon': LucideIcons.newspaper,
        'color': Colors.lightBlue,
        'action': () {},
      },
      {
        'title': 'Hospitals',
        'icon': LucideIcons.stethoscope,
        'color': Colors.teal,
        'action': () => onTabChange(1),
      },
      {
        'title': 'Police',
        'icon': LucideIcons.shieldAlert,
        'color': Colors.indigoAccent,
        'action': () => onTabChange(2),
      },
      {
        'title': 'Fire Svc',
        'icon': LucideIcons.flame,
        'color': Colors.orange,
        'action': () => onTabChange(2),
      },
      {
        'title': 'Directory',
        'icon': LucideIcons.bookOpen,
        'color': Colors.purple,
        'action': () => onTabChange(1),
      },
      {
        'title': 'Transport',
        'icon': LucideIcons.bus,
        'color': Colors.green,
        'action': () => _navigateTo(context, const TransportScreen()),
      },
      {
        'title': 'Tourism',
        'icon': LucideIcons.camera,
        'color': Colors.pink,
        'action': () => _navigateTo(context, const TouristSpotsScreen()),
      },
      {
        'title': lang.t('Education', 'শিক্ষা'),
        'icon': LucideIcons.graduationCap,
        'color': Colors.brown,
        'action': () => _navigateTo(context, const EducationScreen()),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Carousel Slider
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildCarousel(context),
              ),

              const SizedBox(height: 16),

              // 3. Category Grid (The Core UI)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.t('All Services', 'সকল সেবা'),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    Icon(Icons.grid_view_rounded, color: Colors.grey[400]),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // এক লাইনে ৪টা আইকন (Modern Look)
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.8, // লম্বাটে শেপ
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return _buildModernServiceItem(services[index]);
                },
              ),

              const SizedBox(height: 25),

              // 4. News Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.t('Recent Updates', 'সাম্প্রতিক আপডেট'),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onTabChange(1), // সংবাদ ট্যাব (index 1)
                      child: Text(
                        lang.t('See All', 'সব দেখুন'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1D4ED8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NewsCard(
                  title: lang.t("New Park Opening in Taraganj", "তারগঞ্জ উপজেলায় নতুন পার্কের উদ্বোধন"),
                  source: lang.t("Admin", "প্রশাসন"),
                  date: lang.t("Just Now", "এইমাত্র"),
                  imageUrl: "",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildCarousel(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160.0,
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 0.9,
        padEnds: false,
      ),
      items: [1, 2, 3].map((i) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative Circle
              Positioned(
                right: -30,
                top: -30,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NOTICE',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alokito Taraganj Portal',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernServiceItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: item['action'],
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(item['icon'], color: item['color'], size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            item['title'],
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A4E69),
            ),
          ),
        ],
      ),
    );
  }
}
