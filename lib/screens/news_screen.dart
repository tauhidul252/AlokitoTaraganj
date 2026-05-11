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
  bool _isLoading = true;
  String _error = '';
  
  final List<String> _categories = ['All', 'Politics', 'Sports', 'Education', 'Local'];
  int _selectedCategoryIndex = 0;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      // API call to Django backend
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/v1/news/'));
      if (response.statusCode == 200) {
        setState(() {
          // Decoding utf8 to properly show Bengali characters
          _newsList = json.decode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load news';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error. Make sure Django server is running.';
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
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
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
                                        color: const Color(0xFF1D4ED8).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                _categories[index],
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
                      )
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
                          Row(
                            children: [
                              Text(
                                lang.t('View all', 'সব দেখুন'),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1D4ED8),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(LucideIcons.arrowRight, size: 16, color: Color(0xFF1D4ED8)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Breaking News Card Carousel
                    SizedBox(
                      height: 200.0,
                      child: PageView.builder(
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
                            source: (news['source'] ?? 'Admin').toString(),
                            date: _formatDate((news['created_at'] ?? '').toString()),
                            imageUrl: (news['image'] ?? '').toString(),
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
                    
                    // Recommendation Header
                    if (recommendations.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang.t('Recommendation', 'আপনার জন্য'),
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  lang.t('View all', 'সব দেখুন'),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(LucideIcons.arrowRight, size: 16, color: Color(0xFF1D4ED8)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Recommendation List
                      ...recommendations.map((news) {
                        return NewsCard(
                          title: (news['title'] ?? '').toString(),
                          source: (news['source'] ?? 'Admin').toString(),
                          date: _formatDate((news['created_at'] ?? '').toString()),
                          imageUrl: (news['image'] ?? '').toString(),
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
      }
    );
  }
}
