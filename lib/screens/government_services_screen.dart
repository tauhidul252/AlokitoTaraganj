import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/api_service.dart';

class GovernmentServicesScreen extends StatefulWidget {
  const GovernmentServicesScreen({super.key});

  @override
  State<GovernmentServicesScreen> createState() => _GovernmentServicesScreenState();
}

class _GovernmentServicesScreenState extends State<GovernmentServicesScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchGovtServices();
    setState(() {
      _services = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'E-Services',
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.blue,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : _services.isEmpty
                ? _buildEmpty()
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final s = _services[index];
                      return _buildInfos(
                        context,
                        s['title'] ?? '',
                        _getIconData(s['icon']),
                        Colors.blue,
                        s['url'] ?? '',
                      );
                    },
                  ),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'credit_card': return Icons.credit_card;
      case 'child_friendly': return Icons.child_friendly;
      case 'book': return Icons.book;
      case 'map': return Icons.map;
      case 'verified_user': return Icons.verified_user;
      case 'sticky_note_2': return Icons.sticky_note_2;
      default: return Icons.language;
    }
  }

  Widget _buildInfos(BuildContext context, String title, IconData icon, Color color, String url) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (url.isEmpty) return;
            final Uri uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No government services linked yet',
            style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
