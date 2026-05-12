import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'tourist_spots_screen.dart';
import 'education_screen.dart';
import 'transport_screen.dart';
import 'blood_bank_screen.dart';
import 'job_board_screen.dart';
import 'government_services_screen.dart';
import 'find_doctor_screen.dart';
import 'professional_services_screen.dart';
import 'complaint_box_screen.dart';
import 'emergency_screen.dart';
import '../widgets/news_card.dart';
import '../utils/translations.dart';
import '../utils/api_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _ads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    await Future.wait([
      _fetchServices(),
      _fetchAds(),
    ]);
    setState(() => _loading = false);
  }

  Future<void> _fetchServices() async {
    final data = await ApiService.fetchHomeServices();
    if (data.isNotEmpty) {
      _services = data;
    } else {
      _setFallbackServices();
    }
  }

  Future<void> _fetchAds() async {
    final data = await ApiService.fetchAds();
    if (data.isNotEmpty) {
      _ads = data;
    }
  }

  void _setFallbackServices() {
    setState(() {
      _services = [
        {'title': 'E-Services', 'icon': 'globe', 'color_hex': '#3b82f6', 'route_type': 'screen', 'target': 'GovernmentServicesScreen'},
        {'title': 'Blood Bank', 'icon': 'droplet', 'color_hex': '#ef4444', 'route_type': 'screen', 'target': 'BloodBankScreen'},
        {'title': 'Find Doctor', 'icon': 'user-plus', 'color_hex': '#06b6d4', 'route_type': 'screen', 'target': 'FindDoctorScreen'},
        {'title': 'Emergency', 'icon': 'phone-call', 'color_hex': '#f87171', 'route_type': 'tab', 'target': '3'},
        {'title': 'Expert Svc', 'icon': 'hammer', 'color_hex': '#92400e', 'route_type': 'screen', 'target': 'ProfessionalServicesScreen'},
        {'title': 'Job Board', 'icon': 'briefcase', 'color_hex': '#3f51b5', 'route_type': 'screen', 'target': 'JobBoardScreen'},
        {'title': 'Complaint', 'icon': 'message-square', 'color_hex': '#f97316', 'route_type': 'screen', 'target': 'ComplaintBoxScreen'},
        {'title': 'News', 'icon': 'newspaper', 'color_hex': '#03a9f4', 'route_type': 'tab', 'target': '1'},
        {'title': 'Hospitals', 'icon': 'stethoscope', 'color_hex': '#009688', 'route_type': 'tab', 'target': '2'},
        {'title': 'Police', 'icon': 'shield-alert', 'color_hex': '#3f51b5', 'route_type': 'tab', 'target': '3'},
        {'title': 'Fire Svc', 'icon': 'flame', 'color_hex': '#f59e0b', 'route_type': 'tab', 'target': '3'},
        {'title': 'Directory', 'icon': 'book-open', 'color_hex': '#9c27b0', 'route_type': 'tab', 'target': '2'},
        {'title': 'Transport', 'icon': 'bus', 'color_hex': '#4caf50', 'route_type': 'screen', 'target': 'TransportScreen'},
        {'title': 'Tourism', 'icon': 'camera', 'color_hex': '#e91e63', 'route_type': 'screen', 'target': 'TouristSpotsScreen'},
        {'title': 'Education', 'icon': 'graduation-cap', 'color_hex': '#795548', 'route_type': 'screen', 'target': 'EducationScreen'},
      ];
      _loading = false;
    });
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'globe': return LucideIcons.globe;
      case 'droplet': return LucideIcons.droplet;
      case 'user-plus': return LucideIcons.userPlus;
      case 'phone-call': return LucideIcons.phoneCall;
      case 'hammer': return LucideIcons.hammer;
      case 'briefcase': return LucideIcons.briefcase;
      case 'message-square': return LucideIcons.messageSquare;
      case 'newspaper': return LucideIcons.newspaper;
      case 'stethoscope': return LucideIcons.stethoscope;
      case 'shield-alert': return LucideIcons.shieldAlert;
      case 'flame': return LucideIcons.flame;
      case 'book-open': return LucideIcons.bookOpen;
      case 'bus': return LucideIcons.bus;
      case 'camera': return LucideIcons.camera;
      case 'graduation-cap': return LucideIcons.graduationCap;
      default: return LucideIcons.helpCircle;
    }
  }

  Color _getColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }

  void _handleAction(Map<String, dynamic> service) {
    final routeType = service['route_type'];
    final target = service['target'].toString();

    if (routeType == 'tab') {
      final index = int.tryParse(target) ?? 0;
      widget.onTabChange(index);
    } else if (routeType == 'screen') {
      Widget? screen;
      switch (target) {
        case 'GovernmentServicesScreen': screen = const GovernmentServicesScreen(); break;
        case 'BloodBankScreen': screen = const BloodBankScreen(); break;
        case 'FindDoctorScreen': screen = const FindDoctorScreen(); break;
        case 'ProfessionalServicesScreen': screen = const ProfessionalServicesScreen(); break;
        case 'JobBoardScreen': screen = const JobBoardScreen(); break;
        case 'ComplaintBoxScreen': screen = const ComplaintBoxScreen(); break;
        case 'TransportScreen': screen = const TransportScreen(); break;
        case 'TouristSpotsScreen': screen = const TouristSpotsScreen(); break;
        case 'EducationScreen': screen = const EducationScreen(); break;
        case 'PoliceScreen': screen = const EmergencyScreen(category: 'Police', customTitle: 'Police Station'); break;
        case 'FireServiceScreen': screen = const EmergencyScreen(category: 'Fire', customTitle: 'Fire Service'); break;
        case 'HospitalScreen': screen = const EmergencyScreen(category: 'Hospital', customTitle: 'Hospitals'); break;
      }
      if (screen != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        top: true,
        child: RefreshIndicator(
          onRefresh: _fetchServices,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildCarousel(context),
                ),
                const SizedBox(height: 16),
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
                _loading 
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        return _buildModernServiceItem(_services[index]);
                      },
                    ),
                const SizedBox(height: 25),
                // News Section remains same...
                _buildNewsSection(),
                if (_ads.isNotEmpty) _buildAdArea(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            lang.t('Advertisements', 'বিজ্ঞাপন'),
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(height: 10),
        CarouselSlider(
          options: CarouselOptions(
            height: 100.0,
            autoPlay: true,
            enlargeCenterPage: false,
            viewportFraction: 0.9,
            padEnds: false,
          ),
          items: _ads.map((ad) {
            return GestureDetector(
              onTap: () {
                if (ad['link'] != null && ad['link'].toString().isNotEmpty) {
                  // Link opening logic if needed
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(ad['image']),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey[200]!),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNewsSection() {
    return Column(
      children: [
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
                onPressed: () => widget.onTabChange(1),
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
            onTap: () => widget.onTabChange(1),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

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
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('NOTICE', style: TextStyle(color: Colors.white, fontSize: 10)),
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
      onTap: () => _handleAction(item),
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
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(_getIcon(item['icon']), color: _getColor(item['color_hex']), size: 26),
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
