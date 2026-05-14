import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/api_service.dart';
import '../widgets/ad_banner.dart';
import '../main.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  List<Map<String, dynamic>> _institutions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchEducation();
    setState(() {
      _institutions = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: Container(),
      ),
      body: Column(
        children: [
          const AdBanner(placement: 'education'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.brown,
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.brown))
                  : _institutions.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          itemCount: _institutions.length,
                          padding: const EdgeInsets.all(20),
                          itemBuilder: (context, index) {
                            final item = _institutions[index];
                            return _buildInstitutionTile(
                              item['name'] ?? '',
                              item['institution_type'] ?? '',
                              Icons.school,
                              _getColorForType(item['institution_type']),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'University': return Colors.blue;
      case 'College': return Colors.orange;
      case 'High School': return Colors.green;
      case 'Primary': return Colors.teal;
      default: return Colors.brown;
    }
  }

  Widget _buildInstitutionTile(String name, String type, IconData icon, Color color) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF2D3142),
          ),
        ),
        subtitle: Text(
          type,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey[400],
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No educational institutions found',
            style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
