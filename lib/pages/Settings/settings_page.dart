
import 'package:wwe_universe/navbar.dart';
import 'package:flutter/material.dart';

import 'package:wwe_universe/pages/Settings/Stipulations/stipulations_page.dart';
import 'package:wwe_universe/pages/Settings/Matches/match_catalog_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(
      title: const Text('Settings'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildSettingsCard(
          title: 'Stipulations',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StipulationsPage(),
              ),
            );
          },
        ),
        _buildSettingsCard(
          title: 'Matchs',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MatchCatalogSettingsPage(),
              ),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildSettingsCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 100,
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF30303A)),
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.all(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16,
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
