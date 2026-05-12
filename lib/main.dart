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
import 'utils/translations.dart';

void main() {
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

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(onTabChange: _onItemTapped),
    const NewsScreen(),
    const DirectoryScreen(),
    const EmergencyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.mapPin,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Alokito Taraganj',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      lang.t('Taraganj, Rangpur', 'তারাগঞ্জ, রংপুর'),
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.search, color: Colors.white, size: 22),
                onPressed: () {},
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.settings, color: Colors.white, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _screens[_selectedIndex]),
          const AdBanner(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
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
          indicatorColor: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
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
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
