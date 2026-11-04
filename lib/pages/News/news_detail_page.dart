import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/news.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/news_database_helper.dart';
import 'package:wwe_universe/database/news_associations_database_helper.dart';
import 'package:wwe_universe/database/storylines_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/pages/News/add_edit_news_page.dart';
import 'package:wwe_universe/pages/Storylines/storylines_detail_page.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/pages/Superstars/superstars_detail_page.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';

class NewsDetailPage extends StatefulWidget {
  final int newsId;
  const NewsDetailPage({super.key, required this.newsId});
  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  News? news;
  Map<String, List<int>> associations = {};
  Map<String, List<String>> associationNames = {};
  Storylines? storyline;
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() => loading = true);
    try {
      final value = await NewsDatabaseHelper.readNews(widget.newsId);
      final ids = await NewsAssociationsDatabaseHelper.read(widget.newsId);
      final linkedStorylineId = await NewsDatabaseHelper.readLinkedStorylineId(widget.newsId);
      final all = await Future.wait([
        SuperstarsDatabaseHelper.readAllSuperstars(), TeamsDatabaseHelper.readAllTeams(),
        TitlesDatabaseHelper.readAllTitles(), ShowsDatabaseHelper.readAllShows(),
      ]);
      final names = <String, List<String>>{
        'superstars': (all[0] as List<Superstars>).where((e) => ids['superstars']!.contains(e.id)).map((e) => e.name).toList(),
        'teams': (all[1] as List<Teams>).where((e) => ids['teams']!.contains(e.id)).map((e) => e.name).toList(),
        'titles': (all[2] as List<Titles>).where((e) => ids['titles']!.contains(e.id)).map((e) => e.name).toList(),
        'shows': (all[3] as List<Show>).where((e) => ids['shows']!.contains(e.id)).map((e) => '${e.name} • ${e.year} S${e.week}').toList(),
      };
      final story = linkedStorylineId == null ? null : await StorylinesDatabaseHelper.readStoryline(linkedStorylineId);
      if (!mounted) return;
      setState(() { news = value; associations = ids; associationNames = names; storyline = story; loading = false; });
    } catch (e) {
      if (mounted) { setState(() => loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to load news: $e'))); }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101010),
    appBar: AppBar(title: const Text('News Details'), actions: [
      IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined), onPressed: news == null ? null : _edit),
      IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: news == null ? null : _confirmDelete),
    ]),
    body: loading ? const Center(child: CircularProgressIndicator(color: AppFormStyles.primary))
      : news == null ? const Center(child: Text('News not found.'))
      : ListView(padding: const EdgeInsets.all(16), children: [
        Text(news!.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('${news!.type}  •  ${news!.year ?? news!.createdTime.year}  •  S${news!.week ?? '—'}  •  J${news!.dayOfWeek ?? '—'}', style: const TextStyle(color: AppFormStyles.secondaryText)),
        const SizedBox(height: 20),
        AppDetailSection(title: 'Content', icon: Icons.article_outlined, child: SelectableText(news!.text, style: const TextStyle(color: Colors.white, height: 1.55, fontSize: 15))),
        const SizedBox(height: 14),
        AppDetailSection(title: 'Storyline', icon: Icons.auto_stories_outlined, child: storyline == null
          ? const Text('Aucune storyline associée.', style: TextStyle(color: AppFormStyles.secondaryText))
          : ListTile(contentPadding: EdgeInsets.zero, title: Text(storyline!.title, style: const TextStyle(color: Colors.white)), subtitle: const Text('Ouvrir la storyline', style: TextStyle(color: AppFormStyles.secondaryText)), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StorylinesDetailPage(storylineId: storyline!.id!)))),),
        const SizedBox(height: 14),
        AppDetailSection(title: 'Related Entities', icon: Icons.link, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _superstarLinks(),
          _entityGroup('Équipes', associationNames['teams'] ?? []),
          _entityGroup('Titres', associationNames['titles'] ?? []),
          _entityGroup('Shows', associationNames['shows'] ?? []),
        ])),
      ]),
  );

  Widget _superstarLinks() {
    final ids = associations['superstars'] ?? const <int>[];
    final values = <Superstars>[];
    // Names are already loaded for display; fetch the linked records for their portraits.
    return FutureBuilder<List<Superstars>>(
      future: SuperstarsDatabaseHelper.readAllSuperstars(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        values.addAll(snapshot.data!.where((s) => ids.contains(s.id)));
        return Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Superstars', style: TextStyle(color: AppFormStyles.secondaryText, fontWeight: FontWeight.bold)),
          if (values.isEmpty) const Text('None', style: TextStyle(color: Colors.white)),
          ...values.map((s) => ListTile(contentPadding: EdgeInsets.zero, leading: SuperstarAvatar(superstar: s, size: 44), title: Text(s.name, style: const TextStyle(color: Colors.white)), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuperstarsDetailPage(superstarId: s.id!))))),
        ]));
      },
    );
  }

  Widget _entityGroup(String label, List<String> values) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: AppFormStyles.secondaryText, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4), Text(values.isEmpty ? 'Aucun' : values.join(' • '), style: const TextStyle(color: Colors.white)),
  ]));

  Future<void> _edit() async { await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditNewsPage(news: news))); await _load(); }
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete cette actualité ?'), content: const Text('Ses associations seront supprimées, mais les storylines, matchs et autres entités resteront intactes.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))]));
    if (confirmed == true) { await NewsDatabaseHelper.deleteNews(widget.newsId); if (mounted) Navigator.pop(context, true); }
  }
}
