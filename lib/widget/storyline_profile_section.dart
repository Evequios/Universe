import 'package:flutter/material.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/database/storylines_database_helper.dart';
import 'package:wwe_universe/pages/Storylines/storylines_detail_page.dart';

/// Section réutilisable pour retrouver les storylines depuis une fiche d'entité.
class StorylineProfileSection extends StatelessWidget {
  final String relationTable;
  final String relationColumn;
  final int entityId;
  final String title;
  const StorylineProfileSection({super.key, required this.relationTable,
    required this.relationColumn, required this.entityId, this.title = 'STORYLINE HISTORY'});

  Future<List<int>> _ids() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(relationTable, columns: ['storyline_id'],
      where: '$relationColumn = ?', whereArgs: [entityId], orderBy: 'storyline_id DESC');
    return rows.map((row) => row['storyline_id'] as int).toList();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<int>>(
    future: _ids(), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
      final ids = snapshot.data ?? const <int>[];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Color(0xFFD71920), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        const SizedBox(height: 12),
        if (ids.isEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1B1B1B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF303030))), child: const Text('Aucune storyline associée.', style: TextStyle(color: Color(0xFFAAAAAA)))),
        ...ids.map((id) => FutureBuilder(future: StorylinesDatabaseHelper.readStoryline(id), builder: (context, item) {
          if (!item.hasData) return const SizedBox.shrink();
          final value = item.data!;
          return Card(color: const Color(0xFF1B1B1B), child: ListTile(
            leading: const Icon(Icons.auto_stories_outlined, color: Color(0xFFD71920)),
            title: Text(value.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            subtitle: Text(value.status, style: const TextStyle(color: Color(0xFFAAAAAA))),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StorylinesDetailPage(storylineId: id))),
          ));
        })),
      ]);
    });
}
