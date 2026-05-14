import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  static int _nextAdClickThreshold = 2; // Initial threshold (random between 1-3)
  static final Random _random = Random();

  static void loadInterstitialAd() {
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
    _nextAdClickThreshold = _random.nextInt(3) + 1; // Random number between 1 and 3
    print('ADMOB_DEBUG: Resetting Ad Threshold to: $_nextAdClickThreshold');
  }
}
