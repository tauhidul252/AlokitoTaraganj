import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/api_service.dart';

class EmergencyScreen extends StatefulWidget {
  final String? category;
  final String? customTitle;

  const EmergencyScreen({super.key, this.category, this.customTitle});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchEmergencyContacts(category: widget.category);
    setState(() { _contacts = data; _loading = false; });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Color _parseColor(String? hex) {
    try {
      final h = hex?.replaceFirst('#', '') ?? '1d4ed8';
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF1D4ED8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: widget.category != null ? AppBar(
        title: Text(widget.customTitle ?? widget.category!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ) : null,
      body: RefreshIndicator(
        color: Colors.red,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.category == null) ...[
              Text('Emergency Help',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
              const SizedBox(height: 8),
              Text('Tap any card to call immediately',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 25),
            ],
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Colors.red)))
            else if (_contacts.isEmpty)
              _buildEmpty()
            else
              ..._contacts.map((c) => _buildEmergencyCard(
                title: c['title'] ?? '',
                number: c['number'] ?? '',
                subtitle: c['subtitle'] ?? '',
                color: _parseColor(c['color_hex']),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String title, required String number,
    required String subtitle, required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _makePhoneCall(number),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.phone, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF2D3142))),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500])),
                ],
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Row(children: [
                  const Icon(Icons.call, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text(number, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(children: [
      Icon(Icons.phone_disabled, size: 60, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text('No contacts found', style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 16)),
    ]),
  ));
}
