import 'package:flutter/material.dart';
import 'package:wwe_universe/navbar.dart';
import 'package:wwe_universe/classes/news.dart';
import 'package:wwe_universe/database/news_database_helper.dart';
import 'package:wwe_universe/pages/news/add_edit_news_page.dart';
import 'package:wwe_universe/pages/news/news_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});
  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with AutomaticKeepAliveClientMixin {
  List<News> _all = [];
  bool _loading = true, _searching = false;
  String _query = '', _category = 'Toutes', _sort = 'newest';
  final _searchController = TextEditingController();
  @override bool get wantKeepAlive => true;

  @override void initState() { super.initState(); _refresh(); }
  @override void dispose() { _searchController.dispose(); super.dispose(); }

  Future<void> _refresh() async {
    if (mounted) setState(() => _loading = true);
    try {
      final rows = await NewsDatabaseHelper.readAllNews();
      if (mounted) setState(() { _all = rows; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de charger les actualités : $e')));
    }
  }

  List<String> get _categories => ['Toutes', ..._all.map((n) => n.type).where((v) => v.trim().isNotEmpty).toSet().toList()..sort()];
  List<News> get _visible {
    final q = _query.trim().toLowerCase();
    final rows = _all.where((n) => (_category == 'Toutes' || n.type == _category) &&
      (q.isEmpty || n.title.toLowerCase().contains(q) || n.text.toLowerCase().contains(q))).toList();
    int compareDate(News a, News b) {
      final ay = a.year ?? -1, by = b.year ?? -1;
      final aw = a.week ?? -1, bw = b.week ?? -1;
      final ad = a.dayOfWeek ?? -1, bd = b.dayOfWeek ?? -1;
      final result = ay != by ? ay.compareTo(by) : aw != bw ? aw.compareTo(bw) : ad != bd ? ad.compareTo(bd) : a.createdTime.compareTo(b.createdTime);
      return _sort == 'oldest' ? result : -result;
    }
    rows.sort(compareDate);
    return rows;
  }

  @override Widget build(BuildContext context) {
    super.build(context);
    final categories = _categories;
    return Scaffold(
      drawer: const Navbar(),
      appBar: AppBar(centerTitle: true,
        title: _searching ? TextField(controller: _searchController, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Rechercher une actualité…', border: InputBorder.none), onChanged: (v) => setState(() => _query = v)) : const Text('News'),
        actions: [IconButton(icon: Icon(_searching ? Icons.close : Icons.search), onPressed: () { setState(() { _searching = !_searching; if (!_searching) { _query = ''; _searchController.clear(); } }); _refresh(); })]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0), child: Row(children: [const Text('Trier :'), const SizedBox(width: 8), Expanded(child: DropdownButton<String>(isExpanded: true, value: _sort, items: const [DropdownMenuItem(value: 'newest', child: Text('Plus récentes')), DropdownMenuItem(value: 'oldest', child: Text('Plus anciennes'))], onChanged: (v) => setState(() => _sort = v ?? 'newest')))])),
        if (categories.length > 1)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                );
              }).toList(),
            ),
          ),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _visible.isEmpty ? const Center(child: Text('Aucune actualité pour ces critères.')) : RefreshIndicator(onRefresh: _refresh, child: ListView.builder(padding: const EdgeInsets.all(8), itemCount: _visible.length, itemBuilder: (context, index) {
          final news = _visible[index];
          final date = news.year == null ? 'Date WWE non renseignée' : '${news.year} · S${news.week ?? '?'} · J${news.dayOfWeek ?? '?'}';
          return Card(shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFF30303A)), borderRadius: BorderRadius.circular(16)), child: ListTile(
            onTap: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewsDetailPage(newsId: news.id!))); _refresh(); },
            title: Text(news.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Row(children: [Expanded(child: Text(date, style: const TextStyle(color: Colors.blueGrey))), Text(news.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey))])),
          ));
        }))),
      ]),
      floatingActionButton: FloatingActionButton(backgroundColor: Theme.of(context).colorScheme.primary, onPressed: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditNewsPage())); _refresh(); }, child: const Icon(Icons.add)),
    );
  }
}
