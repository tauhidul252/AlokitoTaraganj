import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'screens/home_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/directory_screen.dart';
import 'screens/news_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/ad_banner.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'utils/translations.dart';
import 'utils/ad_helper.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // AdMob initialization
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    await MobileAds.instance.initialize();
    AdHelper.loadInterstitialAd();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lang,
      builder: (context, child) {
        return MaterialApp(
          title: 'Alokito Taraganj',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D4ED8)),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF0F4FF),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          scrollBehavior: AppScrollBehavior(),
          home: const MainLayout(),
        );
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  static MainLayoutState? of(BuildContext context) => 
      context.findAncestorStateOfType<MainLayoutState>();

  /// Universal back navigation. Use this in ALL service screens instead of Navigator.pop().
  static void goBack(BuildContext context) {
    final mainState = MainLayout.of(context);
    if (mainState != null) {
      if (mainState._subPage != null) {
        mainState.popSubPage();
      } else if (mainState._selectedIndex != 0) {
        mainState._onItemTapped(0);
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  Widget? _subPage;

  late final List<Widget> _screens = [
    HomeScreen(onTabChange: _onItemTapped),
    const NewsScreen(),
    const DirectoryScreen(),
    const EmergencyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _subPage = null; // Clear sub-page when switching tabs
    });
  }

  String? _pageTitle;

  void pushSubPage(Widget page, {String? title}) {
    setState(() {
      _subPage = page;
      _pageTitle = title;
    });
  }

  void popSubPage() {
    setState(() {
      _subPage = null;
      _pageTitle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _subPage == null,
      onPopInvoked: (didPop) {
        if (!didPop && _subPage != null) {
          popSubPage();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x441D4ED8),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: (_subPage != null || _selectedIndex != 0) ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (_subPage != null) {
                    popSubPage();
                  } else {
                    _onItemTapped(0);
                  }
                },
              ) : null,
              title: Row(
                children: [
                  if (_subPage == null) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.mapPin,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      _pageTitle ?? (_subPage != null ? '' : 'Alokito Taraganj'),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                if (_subPage == null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(LucideIcons.settings, color: Colors.white, size: 20),
                        onPressed: () => pushSubPage(const SettingsScreen()),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(child: _subPage ?? _screens[_selectedIndex]),
            const AdBanner(placement: 'site_footer'), 
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D4ED8).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: const Color(0xFF1D4ED8).withOpacity(0.12),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: const Icon(LucideIcons.home, color: Colors.grey),
                selectedIcon: const Icon(LucideIcons.home, color: Color(0xFF1D4ED8)),
                label: lang.t('Home', 'হোম'),
              ),
              NavigationDestination(
                icon: const Icon(LucideIcons.newspaper, color: Colors.grey),
                selectedIcon: const Icon(LucideIcons.newspaper, color: Color(0xFF1D4ED8)),
                label: lang.t('News', 'সংবাদ'),
              ),
              NavigationDestination(
                icon: const Icon(LucideIcons.book, color: Colors.grey),
                selectedIcon: const Icon(LucideIcons.book, color: Color(0xFF1D4ED8)),
                label: lang.t('Directory', 'ডিরেক্টরি'),
              ),
              NavigationDestination(
                icon: const Icon(LucideIcons.alertCircle, color: Colors.grey),
                selectedIcon: const Icon(LucideIcons.alertCircle, color: Colors.red),
                label: lang.t('Emergency', 'জরুরি'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
