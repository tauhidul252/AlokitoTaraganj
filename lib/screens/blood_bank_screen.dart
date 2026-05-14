import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/api_service.dart';
import '../widgets/ad_banner.dart';
import '../main.dart';

class BloodBankScreen extends StatefulWidget {
  const BloodBankScreen({super.key});
  @override
  State<BloodBankScreen> createState() => _BloodBankScreenState();
}

class _BloodBankScreenState extends State<BloodBankScreen> {
  List<Map<String, dynamic>> _donors = [];
  bool _loading = true;
  String _selectedGroup = '';

  final List<String> _bloodGroups = [
    '',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchBloodDonors(
      group: _selectedGroup.isEmpty ? null : _selectedGroup,
    );
    setState(() {
      _donors = data;
      _loading = false;
    });
  }

  Future<void> _callDonor(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Map<String, List<Map<String, dynamic>>> get _grouped {
    final Map<String, List<Map<String, dynamic>>> map = {};
    for (final d in _donors) {
      final g = d['blood_group'] as String? ?? '?';
      map.putIfAbsent(g, () => []).add(d);
    }
    return map;
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
        color: Colors.red,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AdBanner(placement: 'blood'),
            const SizedBox(height: 10),
            // Header banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donate Blood',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your blood can save a life.',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Blood group filter
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _bloodGroups.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final g = _bloodGroups[i];
                  final selected = _selectedGroup == g;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedGroup = g);
                      _load();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? Colors.red : Colors.grey.shade300,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        g.isEmpty ? 'All' : g,
                        style: GoogleFonts.outfit(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Colors.red),
                ),
              )
            else if (_donors.isEmpty)
              _buildEmpty('No blood donors found', Icons.water_drop)
            else
              ..._grouped.entries.map(
                (entry) => _buildGroupSection(entry.key, entry.value),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSection(String group, List<Map<String, dynamic>> donors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  group,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Donors',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        ...donors.map(
          (donor) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: Icon(Icons.person, color: Colors.red.shade400),
              ),
              title: Text(
                donor['name'] ?? '',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                donor['location'] ?? '',
                style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13),
              ),
              trailing:
                  donor['phone'] != null && donor['phone'].toString().isNotEmpty
                  ? IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 18,
                        child: Icon(Icons.call, color: Colors.white, size: 18),
                      ),
                      onPressed: () => _callDonor(donor['phone']),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildEmpty(String msg, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              msg,
              style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
