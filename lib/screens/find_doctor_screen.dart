import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/api_service.dart';

class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({super.key});
  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchDoctors();
    setState(() {
      _doctors = data;
      _filtered = data;
      _loading = false;
    });
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _doctors.where((d) {
        return (d['name'] ?? '').toLowerCase().contains(q) ||
            (d['specialty'] ?? '').toLowerCase().contains(q);
      }).toList();
    });
  }

  Map<String, List<Map<String, dynamic>>> get _grouped {
    final Map<String, List<Map<String, dynamic>>> map = {};
    for (final d in _filtered) {
      final s = d['specialty'] as String? ?? 'General';
      map.putIfAbsent(s, () => []).add(d);
    }
    return map;
  }

  Future<void> _callDoctor(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: Container(),
      ),
      body: RefreshIndicator(
        color: Colors.cyan,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Search Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search by name or specialty...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); _filter(); })
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 25),

            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Colors.cyan)))
            else if (_filtered.isEmpty)
              _buildEmpty()
            else
              ..._grouped.entries.map((e) => _buildSpecialtySection(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtySection(String specialty, List<Map<String, dynamic>> docs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 15, top: 5),
        child: Text(specialty,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D3142))),
      ),
      ...docs.map((doc) => Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(children: [
            Container(
              width: 55, height: 55,
              decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.person, color: Colors.cyan, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doc['name'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2D3142))),
              const SizedBox(height: 3),
              Text(doc['degree'] ?? '', style: GoogleFonts.inter(color: Colors.cyan[700], fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(doc['location'] ?? '', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13)),
            ])),
            if ((doc['phone'] ?? '').toString().isNotEmpty)
              IconButton(
                onPressed: () => _callDoctor(doc['phone']),
                icon: CircleAvatar(backgroundColor: Colors.cyan.shade50, radius: 20,
                    child: Icon(Icons.call, color: Colors.cyan[700], size: 18)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.cyan.shade50, borderRadius: BorderRadius.circular(10)),
                child: Text('Book', style: GoogleFonts.inter(color: Colors.cyan[700], fontWeight: FontWeight.w600, fontSize: 13)),
              ),
          ]),
        ),
      )),
      const SizedBox(height: 5),
    ]);
  }

  Widget _buildEmpty() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(children: [
      Icon(Icons.local_hospital_outlined, size: 60, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text(_searchCtrl.text.isEmpty ? 'No doctors available' : 'No results found',
          style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 16)),
    ]),
  ));
}
