import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/news_card.dart';
import '../widgets/breaking_news_card.dart';
import '../utils/translations.dart';
import 'news_detail_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _newsList = [];
  List<Map<String, dynamic>> _categories = [
    {'id': 0, 'name': 'All', 'bn_name': 'সব'}
  ];
  bool _isLoading = true;
  String _error = '';
  
  int _selectedCategoryIndex = 0;
  int _currentCarouselIndex = 0;
  bool _isTodayFilter = false;
  
  late PageController _pageController;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initializeData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay(int itemCount) {
    _carouselTimer?.cancel();
    if (itemCount <= 1) return;
    
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentCarouselIndex + 1) % itemCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _initializeData() async {
    await _fetchCategories();
    await _fetchNews();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.4:8000/api/v1/categories/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _categories = [
            {'id': 0, 'name': 'All', 'bn_name': 'সব'}
          ];
          for (var cat in data) {
            _categories.add({
              'id': cat['id'],
              'name': cat['name'],
              'bn_name': cat['name'],
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      final categoryId = _categories[_selectedCategoryIndex]['id'];
      String url = categoryId == 0 
          ? 'http://192.168.0.4:8000/api/v1/news/' 
          : 'http://192.168.0.4:8000/api/v1/news/?category=$categoryId';
      
      if (_isTodayFilter) {
        url += url.contains('?') ? '&today=true' : '?today=true';
      }
          
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          _newsList = json.decode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
        _startAutoPlay(_newsList.take(5).length);
      } else {
        setState(() {
          _error = 'Failed to load news';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error. Make sure Django server is running at 10.0.2.2:8000';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final carouselItems = _newsList.take(5).toList();
    final recommendations = _newsList.length > 5 ? _newsList.skip(5).toList() : [];

    return ListenableBuilder(
      listenable: lang,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          body: RefreshIndicator(
            onRefresh: _fetchNews,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.t('News & Updates', 'সংবাদ ও আপডেট'),
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang.t('Recent events in and around Taraganj', 'তারাগঞ্জ এবং আশেপাশের সাম্প্রতিক ঘটনাবলী'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category List
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () {
                            if (_selectedCategoryIndex != index) {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                              _fetchNews();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1D4ED8) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF1D4ED8) : Colors.grey[300]!,
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF1D4ED8).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                lang.t(_categories[index]['name'] ?? '', _categories[index]['bn_name'] ?? ''),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _error, 
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                    ),
                  )
                  else if (_newsList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(lang.t('No news found.', 'কোনো সংবাদ পাওয়া যায়নি।')),
                      ),
                    )
                  else ...[
                    // Breaking News Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang.t('Breaking News', 'ব্রেকিং নিউজ'),
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Breaking News Card Carousel
                    SizedBox(
                      height: 200.0,
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentCarouselIndex = index;
                          });
                        },
                        itemCount: carouselItems.length,
                        itemBuilder: (context, index) {
                          final news = carouselItems[index];
                          return BreakingNewsCard(
                            title: (news['title'] ?? '').toString(),
                            category: (news['category_name'] ?? 'News').toString(),
                            source: (news['author_name'] ?? news['source'] ?? 'Admin').toString(),
                            date: _formatDate((news['created_at'] ?? '').toString()),
                            imageUrl: (news['image'] ?? '').toString(),
                            isVerified: news['is_verified'] ?? false,
                            organizationName: news['author_organization'] ?? news['organization_name'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsDetailScreen(newsData: news),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Dot Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        carouselItems.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 6.0,
                          width: _currentCarouselIndex == index ? 24.0 : 6.0,
                          decoration: BoxDecoration(
                            color: _currentCarouselIndex == index ? const Color(0xFF1D4ED8) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Header with Filter
                    if (recommendations.isNotEmpty || _isTodayFilter) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  lang.t('Recent', 'সাম্প্রতিক'),
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E293B),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Today Filter Chip
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isTodayFilter = !_isTodayFilter;
                                    });
                                    _fetchNews();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _isTodayFilter ? const Color(0xFF1D4ED8).withOpacity(0.1) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _isTodayFilter ? const Color(0xFF1D4ED8) : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        if (_isTodayFilter) 
                                          const Icon(Icons.check, size: 12, color: Color(0xFF1D4ED8)),
                                        if (_isTodayFilter) const SizedBox(width: 4),
                                        Text(
                                          lang.t('Today', 'আজকের'),
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _isTodayFilter ? const Color(0xFF1D4ED8) : Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Recent List
                      ...recommendations.map((news) {
                        return NewsCard(
                          title: (news['title'] ?? '').toString(),
                          category: (news['category_name'] ?? 'News').toString(),
                          source: (news['author_name'] ?? news['source'] ?? 'Admin').toString(),
                          date: _formatDate((news['created_at'] ?? '').toString()),
                          imageUrl: (news['image'] ?? '').toString(),
                          isVerified: news['is_verified'] ?? false,
                          organizationName: news['author_organization'] ?? news['organization_name'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsDetailScreen(newsData: news),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ],
                  const SizedBox(height: 80), // Bottom padding for navbar
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
