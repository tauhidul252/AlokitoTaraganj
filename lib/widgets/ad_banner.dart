import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/api_service.dart';
import '../utils/ad_helper.dart';

enum AdMode { local, admob, auto }

class AdBanner extends StatefulWidget {
  final AdMode mode;
  final String placement;
  const AdBanner({
    super.key, 
    this.mode = AdMode.auto,
    required this.placement,
  });

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  List<Map<String, dynamic>> _ads = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  bool _isAdmobEnabled = false; 
  bool _isLocalEnabled = false;
  bool _showAdmobCurrent = true;
  int _carouselInterval = 5;
  BannerAd? _bannerAd;
  bool _isAdmobLoaded = false;
  bool _admobInitiated = false; 

  final Set<int> _viewedAds = {};

  Timer? _refreshTimer;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _loadAds();
    // Start AdMob early if it's enabled by default
    if (_isAdmobEnabled) {
      _admobInitiated = true;
      _loadAdmobBanner();
    }
    // Refresh settings every 60 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) _loadAds();
    });
  }

  Future<void> _loadAds() async {
    try {
      final ads = await ApiService.fetchAds(placement: widget.placement);
      final settings = await ApiService.fetchSettings();

      if (mounted) {
        setState(() {
          var filteredAds = ads.where((ad) => ad['is_active'] == true).toList();
          filteredAds.shuffle(); // Shuffle for variety
          _ads = filteredAds;
          if (settings != null) {
            AdHelper.updateFraudSettings(settings); // Sync fraud settings
            final wasEnabled = _isAdmobEnabled;
            
            // Per-page settings check
            final p = widget.placement;
            _isAdmobEnabled = settings['is_admob_enabled_global'] == true && 
                             settings['show_admob_$p'] == true;
            
            // Fraud protection
            if (_isAdmobEnabled && await AdHelper.isAdBlocked()) {
              _isAdmobEnabled = false;
            }

            _isLocalEnabled = settings['is_local_ads_enabled_global'] == true && 
                             settings['show_local_$p'] == true;

            _carouselInterval = settings['ad_carousel_interval'] ?? 5;

            // Only load AdMob banner if newly enabled or not yet initiated
            if (_isAdmobEnabled && !_admobInitiated) {
              _admobInitiated = true;
              _loadAdmobBanner();
            } else if (!_isAdmobEnabled && wasEnabled) {
              // Dispose if turned off
              _bannerAd?.dispose();
              _bannerAd = null;
              _isAdmobLoaded = false;
              _admobInitiated = false;
            }
          }
          _isLoading = false;
          _startRotationTimer();

          if (_ads.isNotEmpty) {
            _onAdViewed(0);
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading ads: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startRotationTimer() {
    _rotationTimer?.cancel();
    if (_ads.isNotEmpty || _isAdmobEnabled) {
      int nextInterval;
      
      if (_showAdmobCurrent && _isAdmobEnabled && _isAdmobLoaded) {
        // AdMob phase: 30 to 60 seconds random
        nextInterval = Random().nextInt(31) + 30;
      } else {
        // Local phase: carousel interval
        nextInterval = _carouselInterval;
      }
      
      _rotationTimer = Timer(Duration(seconds: nextInterval), () {
        if (mounted) {
          _nextAd();
          _startRotationTimer(); // Schedule next tick
        }
      });
    }
  }

  void _nextAd() {
    setState(() {
      if (_showAdmobCurrent) {
        // We were in AdMob phase
        if (_isLocalEnabled && _ads.isNotEmpty) {
          _showAdmobCurrent = false;
          _currentIndex = 0;
          _onAdViewed(_currentIndex);
        } else {
          // If no local ads, just refresh AdMob unit
          _loadAdmobBanner();
        }
      } else {
        // We were in Local phase
        _currentIndex++;
        if (_currentIndex >= _ads.length) {
          // Finished a full rotation of local ads
          if (_isAdmobEnabled && _isAdmobLoaded) {
            _showAdmobCurrent = true;
            _loadAdmobBanner(); // Refresh AdMob unit for the new phase
          } else {
            _currentIndex = 0;
            _onAdViewed(_currentIndex);
          }
        } else {
          _onAdViewed(_currentIndex);
        }
      }
    });
  }

  void _onAdViewed(int index) {
    if (_ads.isEmpty || index >= _ads.length) return;
    final dynamic rawId = _ads[index]['id'];
    if (rawId == null) return;

    final int adId = (rawId is int) ? rawId : int.tryParse(rawId.toString()) ?? 0;
    if (adId != 0 && !_viewedAds.contains(adId)) {
      _viewedAds.add(adId);
      ApiService.trackAdView(adId);
    }
  }

  void _onAdClicked(int index, String? urlString) {
    if (_ads.isEmpty || index >= _ads.length) return;
    final dynamic rawId = _ads[index]['id'];
    if (rawId != null) {
      final int adId = (rawId is int) ? rawId : int.tryParse(rawId.toString()) ?? 0;
      if (adId != 0) ApiService.trackAdClick(adId);
    }
    _launchUrl(urlString);
  }

  void _loadAdmobBanner() {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    // Dispose any existing banner first
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdmobLoaded = false;

    String adUnitId = AdHelper.bannerAdUnitId;
    debugPrint('Loading AdMob banner with unit: $adUnitId');

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('ADMOB_DEBUG: AdMob banner loaded successfully');
          if (mounted) setState(() => _isAdmobLoaded = true);
        },
        onAdClicked: (ad) => AdHelper.recordClick(),
        onAdFailedToLoad: (ad, err) {
          print('ADMOB_DEBUG: AdMob banner failed to load: ${err.message} (Code: ${err.code})');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdmobLoaded = false;
              _admobInitiated = false; // Allow retry
            });
          }
        },
      ),
    )..load();
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _rotationTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  bool get _shouldShowAdmob {
    if (widget.mode == AdMode.admob) {
      return _isAdmobLoaded && _bannerAd != null;
    }
    if (widget.mode == AdMode.local) {
      return false;
    }

    if (!_isAdmobEnabled || !_isAdmobLoaded || _bannerAd == null) return false;
    if (!_isLocalEnabled || _ads.isEmpty) return true;
    
    return _showAdmobCurrent;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    // Nothing to show (Local disabled or empty AND Admob disabled or empty)
    bool showLocal = _isLocalEnabled && _ads.isNotEmpty;
    bool showAdmob = _shouldShowAdmob;

    if (!showLocal && !showAdmob) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: showAdmob
            ? SizedBox(key: const ValueKey('admob'), width: double.infinity, height: 60, child: AdWidget(ad: _bannerAd!))
            : SizedBox(height: 60, child: _buildLocalAd(_currentIndex)),
      ),
    );
  }

  Widget _buildLocalAd(int index) {
    if (_ads.isEmpty) return const SizedBox.shrink();
    if (index >= _ads.length) index = 0;
    final ad = _ads[index];
    final imageUrl = (ad['image'] ?? '').toString();
    return GestureDetector(
      key: ValueKey('ad_${ad['id']}_$index'),
      onTap: () => _onAdClicked(index, ad['link']),
      child: Image.network(
        imageUrl.startsWith('http') ? imageUrl : '${ApiService.baseUrl}$imageUrl',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 60,
        errorBuilder: (_, __, ___) => _buildFallback(ad['title'] ?? 'Advertisement'),
      ),
    );
  }

  Widget _buildFallback(String title) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
