import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class AdHelper {
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Use test ID if YOUR_ID is not replaced
      const id = 'YOUR_ANDROID_BANNER_UNIT_ID';
      return (id == 'YOUR_ANDROID_BANNER_UNIT_ID' || kDebugMode) 
          ? 'ca-app-pub-3940256099942544/6300978111' 
          : id;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      const id = 'YOUR_IOS_BANNER_UNIT_ID';
      return (id == 'YOUR_IOS_BANNER_UNIT_ID' || kDebugMode) 
          ? 'ca-app-pub-3940256099942544/2934735716' 
          : id;
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      const id = 'YOUR_ANDROID_INTERSTITIAL_UNIT_ID';
      return (id == 'YOUR_ANDROID_INTERSTITIAL_UNIT_ID' || kDebugMode) 
          ? 'ca-app-pub-3940256099942544/1033173712' 
          : id;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      const id = 'YOUR_IOS_INTERSTITIAL_UNIT_ID';
      return (id == 'YOUR_IOS_INTERSTITIAL_UNIT_ID' || kDebugMode) 
          ? 'ca-app-pub-3940256099942544/4411468910' 
          : id;
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      const id = 'YOUR_ANDROID_REWARDED_UNIT_ID';
      return (id == 'YOUR_ANDROID_REWARDED_UNIT_ID' || kDebugMode) 
          ? 'ca-app-pub-3940256099942544/5224354917' 
          : id;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      const id = 'YOUR_IOS_REWARDED_UNIT_ID';
      return (id == 'YOUR_IOS_REWARDED_UNIT_ID' || kDebugMode) 
          ? 'ca-app-pub-3940256099942544/1712485313' 
          : id;
    }
    return '';
  }

  static InterstitialAd? _interstitialAd;
  static int _interstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;
  
  static int _newsClickCount = 0;
  static int _nextAdClickThreshold = 3; // Initial threshold (minimum 3 news)
  static final Random _random = Random();

  // Fraud Protection Logic
  static Future<bool> isAdBlocked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get dynamic settings (fallback to defaults if not set)
      final limit1 = prefs.getInt('fraud_20m_limit') ?? 5;
      final window1 = prefs.getInt('fraud_20m_window') ?? 20;
      final limit2 = prefs.getInt('fraud_2h_limit') ?? 10;
      final window2 = prefs.getInt('fraud_2h_window') ?? 120;
      final blockHours = prefs.getInt('fraud_block_hours') ?? 2;

      // Check for active block
      final blockTimeStr = prefs.getString('ad_block_until');
      if (blockTimeStr != null) {
        final blockTime = DateTime.parse(blockTimeStr);
        if (DateTime.now().isBefore(blockTime)) {
          print('ADMOB_DEBUG: Ads are still blocked until $blockTime');
          return true;
        }
      }

      // Check click thresholds
      final clickTimes = prefs.getStringList('ad_clicks') ?? [];
      final now = DateTime.now();
      final clicks = clickTimes.map((t) => DateTime.parse(t)).toList();

      // Rule 1: Custom limit in custom window 1
      final clicksW1 = clicks.where((t) => now.difference(t).inMinutes <= window1).length;
      if (clicksW1 >= limit1) return await _applyBlock(prefs, blockHours);

      // Rule 2: Custom limit in custom window 2
      final clicksW2 = clicks.where((t) => now.difference(t).inMinutes <= window2).length;
      if (clicksW2 >= limit2) return await _applyBlock(prefs, blockHours);

    } catch (e) {
      debugPrint('Fraud Protection Error: $e');
    }
    return false;
  }

  static Future<void> updateFraudSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (settings.containsKey('fraud_20m_limit')) await prefs.setInt('fraud_20m_limit', settings['fraud_20m_limit']);
      if (settings.containsKey('fraud_20m_window')) await prefs.setInt('fraud_20m_window', settings['fraud_20m_window']);
      if (settings.containsKey('fraud_2h_limit')) await prefs.setInt('fraud_2h_limit', settings['fraud_2h_limit']);
      if (settings.containsKey('fraud_2h_window')) await prefs.setInt('fraud_2h_window', settings['fraud_2h_window']);
      if (settings.containsKey('fraud_block_hours')) await prefs.setInt('fraud_block_hours', settings['fraud_block_hours']);
      print('ADMOB_DEBUG: Fraud settings updated from API');
    } catch (e) {
      debugPrint('Error updating fraud settings: $e');
    }
  }

  static Future<bool> _applyBlock(SharedPreferences prefs, int hours) async {
    final until = DateTime.now().add(Duration(hours: hours));
    await prefs.setString('ad_block_until', until.toIso8601String());
    print('ADMOB_DEBUG: Ads blocked for $hours hours.');
    return true;
  }

  static Future<void> recordClick() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clickTimes = prefs.getStringList('ad_clicks') ?? [];
      clickTimes.add(DateTime.now().toIso8601String());
      
      // Keep only last 15 clicks to save space
      if (clickTimes.length > 15) {
        clickTimes.removeAt(0);
      }
      
      await prefs.setStringList('ad_clicks', clickTimes);
      print('ADMOB_DEBUG: Ad click recorded. Total clicks tracked: ${clickTimes.length}');
    } catch (e) {
      debugPrint('Error recording ad click: $e');
    }
  }

  static Future<void> loadInterstitialAd() async {
    if (await isAdBlocked()) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('ADMOB_DEBUG: Interstitial Ad Loaded');
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          print('ADMOB_DEBUG: Interstitial Ad Failed to Load: ${error.message}');
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          if (_interstitialLoadAttempts <= maxFailedLoadAttempts) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  static void showInterstitialAd(VoidCallback onComplete) {
    if (_interstitialAd == null) {
      onComplete();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdClicked: (ad) => recordClick(),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
        onComplete();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  /// Shows interstitial ad based on random frequency (1-3 clicks)
  static void showInterstitialAdWithFrequency(VoidCallback onComplete) {
    _newsClickCount++;
    
    print('ADMOB_DEBUG: News click count: $_newsClickCount, Threshold: $_nextAdClickThreshold');

    if (_newsClickCount >= _nextAdClickThreshold) {
      // Show Ad
      if (_interstitialAd != null) {
        showInterstitialAd(() {
          _resetThreshold();
          onComplete();
        });
      } else {
        // If ad is not ready, just proceed and try to load for next time
        _resetThreshold();
        loadInterstitialAd();
        onComplete();
      }
    } else {
      // Just proceed without ad
      onComplete();
    }
  }

  static void _resetThreshold() {
    _newsClickCount = 0;
    _nextAdClickThreshold = _random.nextInt(3) + 3; // Random number between 3 and 5
    print('ADMOB_DEBUG: Resetting Ad Threshold to: $_nextAdClickThreshold');
  }
}
