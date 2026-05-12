import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/api_service.dart';

class ProfessionalServicesScreen extends StatefulWidget {
  final String? initialCategory;
  const ProfessionalServicesScreen({super.key, this.initialCategory});

  @override
  State<ProfessionalServicesScreen> createState() => _ProfessionalServicesScreenState();
}

class _ProfessionalServicesScreenState extends State<ProfessionalServicesScreen> {
  List<Map<String, dynamic>> _experts = [];
  bool _loading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchExpertServices(category: _selectedCategory);
    setState(() {
      _experts = data;
      _loading = false;
    });
  }

  List<String> get _categories {
    final cats = _experts.map((e) => e['category'].toString()).toSet().toList();
    if (_selectedCategory != null && !cats.contains(_selectedCategory)) {
      cats.add(_selectedCategory!);
    }
    cats.sort();
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          _selectedCategory ?? 'Expert Services',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.amber,
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : _experts.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _experts.length,
                          itemBuilder: (context, index) {
                            final expert = _experts[index];
                            return _buildExpertTile(expert);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final cats = _categories;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: cats.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final cat = isAll ? null : cats[index - 1];
          final isSelected = _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(isAll ? 'All' : cat!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = cat);
                _loadData();
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.amber.shade100,
              checkmarkColor: Colors.amber.shade900,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.amber.shade900 : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpertTile(Map<String, dynamic> expert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(_getIconForCategory(expert['category']), color: Colors.amber),
        ),
        title: Text(
          expert['name'] ?? '',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expert['category'] ?? '', style: GoogleFonts.inter(color: Colors.amber.shade700, fontSize: 12)),
            const SizedBox(height: 2),
            Text(expert['location'] ?? '', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13)),
          ],
        ),
        trailing: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: const Icon(Icons.call, color: Colors.green, size: 20),
          ),
          onPressed: () => _callExpert(expert['phone']),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String? cat) {
    switch (cat) {
      case 'Electrician': return Icons.electrical_services;
      case 'Plumber': return Icons.plumbing;
      case 'Mason': return Icons.construction;
      case 'TV/AC Repair': return Icons.tv;
      case 'Truck Rental': return Icons.local_shipping;
      case 'Cleaner': return Icons.cleaning_services;
      default: return Icons.handyman;
    }
  }

  Future<void> _callExpert(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No experts found in this category',
            style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
