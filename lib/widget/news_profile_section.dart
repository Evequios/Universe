import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/news.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/database/news_database_helper.dart';
import 'package:wwe_universe/pages/News/news_detail_page.dart';

/// News associées à une entité (Superstar, équipe, titre ou show).
class NewsProfileSection extends StatelessWidget {
  final String relationTable, relationColumn;
  final int entityId;
  const NewsProfileSection({super.key, required this.relationTable, required this.relationColumn, required this.entityId});

  Future<List<News>> _load() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(relationTable, columns: ['news_id'], where: '$relationColumn = ?', whereArgs: [entityId]);
    final ids = rows.map((r) => r['news_id'] as int).toSet();
    if (ids.isEmpty) return const [];
    final all = await NewsDatabaseHelper.readAllNews();
    return all.where((n) => ids.contains(n.id)).toList();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<News>>(future: _load(), builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
    final items = snapshot.data ?? const <News>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('NEWS & UPDATES', style: TextStyle(color: Color(0xFFD71920), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
      const SizedBox(height: 12),
      if (items.isEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1B1B1B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF303030))), child: const Text('No related news.', style: TextStyle(color: Color(0xFFAAAAAA)))),
      ...items.map((news) => Card(color: const Color(0xFF1B1B1B), child: ListTile(
        leading: const Icon(Icons.newspaper_outlined, color: Color(0xFFD71920)),
        title: Text(news.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text('${news.type} • ${news.year ?? '—'} • Week ${news.week ?? '—'}', style: const TextStyle(color: Color(0xFFAAAAAA))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetailPage(newsId: news.id!))),
      ))),
    ]);
  });
}
