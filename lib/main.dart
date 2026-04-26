import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'screens/home_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/directory_screen.dart';
import 'widgets/ad_banner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alokito Taraganj',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const MainLayout(),
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
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              LucideIcons.mapPin,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Alokito Taraganj',
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _screens[_selectedIndex]),
          const AdBanner(), // Persistent Ad Banner at bottom
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.white,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.newspaper),
              selectedIcon: Icon(
                LucideIcons.newspaper,
                color: Color(0xFF2563EB),
              ),
              label: 'News',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.book),
              selectedIcon: Icon(LucideIcons.book, color: Color(0xFF2563EB)),
              label: 'Directory',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.alertCircle),
              selectedIcon: Icon(LucideIcons.alertCircle, color: Colors.red),
              label: 'Emergency',
            ),
          ],
        ),
      ),
    );
  }
}
