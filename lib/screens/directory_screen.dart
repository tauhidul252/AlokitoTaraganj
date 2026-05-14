import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ad_banner.dart';
import '../utils/api_service.dart';
import 'professional_services_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  List<Map<String, dynamic>> _allServices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchExpertServices();
    setState(() {
      _allServices = data;
      _loading = false;
    });
  }

  List<String> get _categories {
    final cats = _allServices.map((s) => s['category'].toString()).toSet().toList();
    cats.sort();
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AdBanner(placement: 'directory'),
            const SizedBox(height: 10),
            Text(
              'Local Directory',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find experts and services in Taraganj',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 25),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            else if (_categories.isEmpty)
              _buildEmpty()
            else
              ..._categories.map((cat) => _buildCategoryCard(cat)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    // Determine icon and color based on category name for some variety
    IconData icon = Icons.business_center;
    Color color = Colors.blue;

    if (category.contains('Electric')) { icon = Icons.electrical_services; color = Colors.amber; }
    else if (category.contains('Plumb')) { icon = Icons.plumbing; color = Colors.blue; }
    else if (category.contains('Shop') || category.contains('Market')) { icon = Icons.shopping_bag; color = Colors.green; }
    else if (category.contains('Repair')) { icon = Icons.build; color = Colors.orange; }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          category,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF2D3142),
          ),
        ),
        subtitle: Text(
          '${_allServices.where((s) => s['category'] == category).length} listings',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfessionalServicesScreen(initialCategory: category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(children: [
      Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text('No categories found', style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 16)),
    ]),
  ));
}
