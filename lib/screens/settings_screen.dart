import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'about_screen.dart';
import '../utils/translations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lang,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              lang.t('Settings', 'সেটিংস'),
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSettingsGroup(lang.t('Preferences', 'পছন্দসমূহ'), [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.languages,
                        size: 20, color: Colors.orange),
                  ),
                  title: Text(
                    lang.t('App Language', 'অ্যাপের ভাষা'),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lang.isBengali ? 'বাংলা' : 'English',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1D4ED8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => lang.toggleLanguage(),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSettingsGroup(lang.t('About', 'সম্পর্কে'), [
                _buildSettingsItem(
                  lang.t('About App', 'অ্যাপ সম্পর্কে'),
                  LucideIcons.info,
                  () => _navigateTo(context, const AboutScreen()),
                ),
                _buildSettingsItem(
                  lang.t('Privacy Policy', 'গোপনীয়তা নীতি'),
                  LucideIcons.lock,
                  () => _navigateTo(context, const PrivacyPolicyScreen()),
                ),
                _buildSettingsItem(
                  lang.t('Terms of Service', 'ব্যবহারের শর্তাবলী'),
                  LucideIcons.fileText,
                  () => _navigateTo(context, const TermsScreen()),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSettingsGroup(lang.t('Support', 'সহায়তা'), [
                _buildSettingsItem(
                    lang.t('Contact Support', 'যোগাযোগ করুন'), LucideIcons.mail,
                    () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.t(
                          'Support: support@alokitotaraganj.com',
                          'সহায়তা: support@alokitotaraganj.com')),
                    ),
                  );
                }),
                _buildSettingsItem(
                    lang.t('Share App', 'অ্যাপটি শেয়ার করুন'),
                    LucideIcons.share2, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(lang.t('Share feature coming soon!',
                            'শেয়ার ফিচার শীঘ্রই আসছে!'))),
                  );
                }),
              ]),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  '${lang.t('App Version', 'অ্যাপ সংস্করণ')} 1.0.0',
                  style: GoogleFonts.inter(color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
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
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.blue),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
