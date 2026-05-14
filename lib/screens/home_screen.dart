import 'dart:math';
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
import 'hospital_screen.dart';
import 'professional_services_screen.dart';
import 'complaint_box_screen.dart';
import 'news_detail_screen.dart';
import '../widgets/news_card.dart';
import '../widgets/ad_banner.dart';
import '../widgets/breaking_news_ticker.dart';
import '../utils/ad_helper.dart';
import '../utils/translations.dart';
import '../utils/api_service.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _services = [];
  List<dynamic> _newsList = [];
  List<int> _adPositions = [];
  static bool _isExpanded = false;
  bool _isLoadingNews = true;
  bool _isFetchingMoreNews = false;
  int _currentNewsPage = 1;
  bool _hasMoreNews = true;
  List<dynamic> _breakingNews = [];

  @override
  void initState() {
    _adPositions = [];
    super.initState();
    _services = _getFallbackServices();
    _fetchData();
  }

  void _generateAdPositions(int startIndex, int count) {
    if (count < 2) return;
    final random = Random();
    Set<int> positions = {};
    // Ensure we don't pick the same position
    while (positions.length < 2) {
      // Pick random index between startIndex and startIndex + count - 2
      int pos = startIndex + random.nextInt(count - 1);
      positions.add(pos);
    }
    setState(() {
      _adPositions.addAll(positions.toList()..sort());
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoadingNews = true;
      _currentNewsPage = 1;
      _hasMoreNews = true;
      _adPositions = []; // Reset ad positions
    });
    try {
      // Fetch Services
      final services = await ApiService.fetchHomeServices().timeout(const Duration(seconds: 5));
      if (mounted && services.isNotEmpty) {
        // Ensure Hospitals and Complaint are swapped as requested
        int hospitalIndex = services.indexWhere((s) => (s['title'] ?? s['name']) == 'Hospitals' || s['target'] == 'HospitalScreen');
        int complaintIndex = services.indexWhere((s) => (s['title'] ?? s['name']) == 'Complaint' || s['target'] == 'ComplaintBoxScreen');
        
        if (hospitalIndex != -1 && complaintIndex != -1) {
          final temp = services[hospitalIndex];
          services[hospitalIndex] = services[complaintIndex];
          services[complaintIndex] = temp;
        }

        setState(() {
          _services = services;
        });
      }

      // Fetch News (Initial 10)
      final news = await ApiService.fetchNews();
      if (mounted) {
        final initialNews = news.take(10).toList();
        setState(() {
          _newsList = initialNews;
          _hasMoreNews = news.length > 10;
          _isLoadingNews = false;
        });
        _generateAdPositions(0, initialNews.length);
      }

      // Fetch Breaking News
      final breaking = await ApiService.fetchNews(breaking: true);
      if (mounted) {
        setState(() {
          _breakingNews = breaking;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingNews = false);
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isFetchingMoreNews || !_hasMoreNews) return;
    
    setState(() => _isFetchingMoreNews = true);
    try {
      final news = await ApiService.fetchNews();
      final startIndex = _newsList.length;
      final moreNews = news.skip(startIndex).take(10).toList();
      
      if (mounted) {
        setState(() {
          _newsList.addAll(moreNews);
          _hasMoreNews = news.length > _newsList.length;
          _isFetchingMoreNews = false;
        });
        _generateAdPositions(startIndex, moreNews.length);
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingMoreNews = false);
    }
  }

  void _navigateTo(BuildContext context, Widget screen, {String? title}) {
    final mainState = MainLayout.of(context);
    if (mainState != null) {
      mainState.pushSubPage(screen, title: title);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    }
  }

  void _handleAction(Map<String, dynamic> item) {
    final routeType = item['route_type'];
    final target = item['target']?.toString() ?? '';
    final title = item['title'] ?? item['name'] ?? '';

    if (routeType == 'tab') {
      final index = int.tryParse(target);
      if (index != null) widget.onTabChange(index);
    } else if (routeType == 'screen') {
      Widget? screen;
      switch (target) {
        case 'GovernmentServicesScreen': screen = const GovernmentServicesScreen(); break;
        case 'BloodBankScreen': screen = const BloodBankScreen(); break;
        case 'FindDoctorScreen': screen = const FindDoctorScreen(); break;
        case 'HospitalScreen': screen = const HospitalScreen(); break;
        case 'ProfessionalServicesScreen': screen = const ProfessionalServicesScreen(); break;
        case 'JobBoardScreen': screen = const JobBoardScreen(); break;
        case 'ComplaintBoxScreen': screen = const ComplaintBoxScreen(); break;
        case 'TransportScreen': screen = const TransportScreen(); break;
        case 'TouristSpotsScreen': screen = const TouristSpotsScreen(); break;
        case 'EducationScreen': screen = const EducationScreen(); break;
      }
      if (screen != null) _navigateTo(context, screen, title: title);
    }
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
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

  Color _getColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildNoticeCarousel(), // Changed back to Notice Carousel
              if (_breakingNews.isNotEmpty) ...[
                const SizedBox(height: 16),
                BreakingNewsTicker(
                  text: _breakingNews.map((n) => n['title']).join(' • '),
                  label: (_breakingNews.first['breaking_type']?.toString().trim().isNotEmpty == true)
                      ? _breakingNews.first['breaking_type']
                      : 'BREAKING',
                  onTap: () {
                    // Navigate to details of the first breaking news or a special screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailScreen(newsData: _breakingNews.first),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width < 300 ? 3 : 4;
                  final childAspectRatio = width < 300 ? 0.95 : 0.85; // Adjusted aspect ratio for better fit
                  
                  final displayCount = _isExpanded ? _services.length : (_services.length > 8 ? 8 : _services.length);

                  return Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 15,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: displayCount,
                        itemBuilder: (context, index) => _buildServiceItem(_services[index], width / crossAxisCount),
                      ),
                      if (_services.length > 8) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            icon: Icon(
                              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: const Color(0xFF1D4ED8),
                            ),
                            label: Text(
                              _isExpanded ? lang.t('See Less', 'কমান') : lang.t('See More', 'আরো দেখুন'),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF1D4ED8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF1D4ED8).withOpacity(0.08),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
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
                  ],
                ),
              ),
              if (_isLoadingNews)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_newsList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(lang.t('No recent updates', 'সাম্প্রতিক কোনো আপডেট নেই')),
                )
              else
                ..._buildNewsWithAds(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNewsWithAds() {
    List<Widget> widgets = [];
    int adCount = 0;
    for (int i = 0; i < _newsList.length; i++) {
      final news = _newsList[i];
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: NewsCard(
            title: news['title']?.toString() ?? '',
            source: (news['author_name'] ?? news['source'] ?? 'Admin').toString(),
            date: _formatDate(news['created_at']?.toString() ?? ''),
            imageUrl: news['image']?.toString() ?? '',
            onTap: () {
               AdHelper.showInterstitialAdWithFrequency(() {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => NewsDetailScreen(newsData: news),
                   ),
                 );
               });
            },
          ),
        ),
      );

      // Add AdBanner at random positions
      if (_adPositions.isNotEmpty && _adPositions.contains(i)) {
        // Alternate between Local and AdMob
        final mode = (adCount % 2 == 0) ? AdMode.local : AdMode.admob;
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: AdBanner(mode: mode, placement: 'home'),
        ));
        adCount++;
      }
    }

    // Add a "More News" button at the bottom
    if (_hasMoreNews) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: _isFetchingMoreNews 
              ? const CircularProgressIndicator(color: Color(0xFF1D4ED8))
              : OutlinedButton(
                  onPressed: _loadMoreNews,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1D4ED8)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    lang.t('Show More News', 'আরো খবর দেখুন'),
                    style: GoogleFonts.inter(color: const Color(0xFF1D4ED8), fontWeight: FontWeight.w600),
                  ),
                ),
          ),
        ),
      );
    }

    return widgets;
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return isoString;
    }
  }

  Widget _buildNoticeCarousel() {
    final List<Map<String, dynamic>> notices = [
      {
        'title': 'Alokito Taraganj Portal',
        'subtitle': lang.t('Your community guide', 'আপনার কমিউনিটি গাইড'),
        'colors': [const Color(0xFF1D4ED8), const Color(0xFF0EA5E9)],
      },
      {
        'title': lang.t('Stay Updated', 'আপডেট থাকুন'),
        'subtitle': lang.t('Get latest news and alerts', 'সবশেষ সংবাদ ও নোটিশ পান'),
        'colors': [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
      },
      {
        'title': lang.t('Emergency Services', 'জরুরি সেবা'),
        'subtitle': lang.t('Quick access to emergency help', 'জরুরি সহায়তা দ্রুত পান'),
        'colors': [const Color(0xFFDC2626), const Color(0xFFEF4444)],
      },
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 150.0,
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 0.9,
        padEnds: false,
      ),
      items: notices.map((notice) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: notice['colors'],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (notice['colors'] as List<Color>)[0].withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notice['title'],
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notice['subtitle'],
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
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

  Widget _buildServiceItem(Map<String, dynamic> item, double cellWidth) {
    final title = item['title'] ?? item['name'] ?? '';
    final icon = _getIcon(item['icon']);
    final color = _getColor(item['color_hex']);
    
    // Scale icon and container based on available width
    final iconSize = cellWidth < 80 ? 24.0 : 28.0;
    final containerSize = cellWidth < 80 ? 50.0 : 60.0;

    return InkWell(
      onTap: () => _handleAction(item),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: containerSize,
            width: containerSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(containerSize / 3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFallbackServices() {
    return [
      {'title': 'E-Services', 'icon': 'globe', 'color_hex': '#3b82f6', 'route_type': 'screen', 'target': 'GovernmentServicesScreen'},
      {'title': 'Blood Bank', 'icon': 'droplet', 'color_hex': '#ef4444', 'route_type': 'screen', 'target': 'BloodBankScreen'},
      {'title': 'Find Doctor', 'icon': 'user-plus', 'color_hex': '#06b6d4', 'route_type': 'screen', 'target': 'FindDoctorScreen'},
      {'title': 'Emergency', 'icon': 'phone-call', 'color_hex': '#f87171', 'route_type': 'tab', 'target': '3'},
      {'title': 'Expert Svc', 'icon': 'hammer', 'color_hex': '#92400e', 'route_type': 'screen', 'target': 'ProfessionalServicesScreen'},
      {'title': 'Job Board', 'icon': 'briefcase', 'color_hex': '#3f51b5', 'route_type': 'screen', 'target': 'JobBoardScreen'},
      {'title': 'Hospitals', 'icon': 'stethoscope', 'color_hex': '#10b981', 'route_type': 'screen', 'target': 'HospitalScreen'},
      {'title': 'News', 'icon': 'newspaper', 'color_hex': '#03a9f4', 'route_type': 'tab', 'target': '1'},
      {'title': 'Complaint', 'icon': 'message-square', 'color_hex': '#f97316', 'route_type': 'screen', 'target': 'ComplaintBoxScreen'},
      {'title': 'Police', 'icon': 'shield-alert', 'color_hex': '#3f51b5', 'route_type': 'screen', 'target': 'EmergencyScreen'},
      {'title': 'Fire Svc', 'icon': 'flame', 'color_hex': '#f59e0b', 'route_type': 'screen', 'target': 'EmergencyScreen'},
      {'title': 'Directory', 'icon': 'book-open', 'color_hex': '#8b5cf6', 'route_type': 'screen', 'target': 'DirectoryScreen'},
    ];
  }
}
