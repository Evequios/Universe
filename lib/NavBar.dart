import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Brands/brands_page.dart';
import 'package:wwe_universe/pages/Draft/draft_page.dart';
import 'package:wwe_universe/pages/News/news_page.dart';
import 'package:wwe_universe/pages/Settings/settings_page.dart';
import 'package:wwe_universe/pages/Shows/shows_page.dart';
import 'package:wwe_universe/pages/Storylines/storylines_page.dart';
import 'package:wwe_universe/pages/Superstars/superstars_page.dart';
import 'package:wwe_universe/pages/Teams/teams_page.dart';
import 'package:wwe_universe/pages/Titles/titles_page.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;

    Widget sectionLabel(String label) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF8E8E9A),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );

    Widget destination({
      required IconData icon,
      required String label,
      required Widget page,
      bool selected = false,
    }) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: selected ? const Color(0xFFFF6672) : null),
        title: Text(label, style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.white : const Color(0xFFD0D0D8),
        )),
        selected: selected,
        selectedTileColor: const Color(0xFF35171D),
        onTap: () => _navigate(context, page),
      ),
    );

    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D2E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WWE UNIVERSE', style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 0.5,
                        )),
                        SizedBox(height: 3),
                        Text('YOUR SHOW. YOUR UNIVERSE.', style: TextStyle(
                          color: Color(0xFF9696A2), fontSize: 9, letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  sectionLabel('Universe'),
                  destination(icon: Icons.dynamic_feed_rounded, label: 'News', page: const NewsPage()),
                  destination(icon: Icons.event_note_rounded, label: 'Shows & results', page: const ShowsPage()),
                  destination(icon: Icons.account_tree_rounded, label: 'Storylines', page: const StorylinesPage()),
                  destination(icon: Icons.groups_rounded, label: 'Superstars', page: const SuperstarsPage()),
                  destination(icon: Icons.flag_rounded, label: 'Brands', page: const BrandsPage()),
                  destination(icon: Icons.workspace_premium_rounded, label: 'Titles', page: const TitlesPage()),
                  destination(icon: Icons.diversity_3_rounded, label: 'Teams', page: const TeamsPage()),
                  sectionLabel('Tools'),
                  destination(icon: Icons.swap_horiz_rounded, label: 'Draft', page: const DraftPage()),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: destination(
                icon: Icons.settings_rounded,
                label: 'Settings',
                page: const SettingsPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
