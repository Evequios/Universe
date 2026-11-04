import 'package:flutter/material.dart';
import 'package:wwe_universe/navbar.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/database/storylines_database_helper.dart';
import 'package:wwe_universe/pages/Storylines/add_edit_storylines_page.dart';
import 'package:wwe_universe/pages/Storylines/storylines_detail_page.dart';

class StorylinesPage extends StatefulWidget {
  const StorylinesPage({super.key});
  @override
  State<StorylinesPage> createState() => _StorylinesPageState();
}

class _StorylinesPageState extends State<StorylinesPage> with AutomaticKeepAliveClientMixin {
  List<Storylines> _items = [];
  bool _loading = true;
  String _search = '';
  String _status = 'all';
  String _sort = 'recent';
  bool _searching = false;
  final _searchController = TextEditingController();
  @override bool get wantKeepAlive => true;

  @override void initState() { super.initState(); _refresh(); }
  @override void dispose() { _searchController.dispose(); super.dispose(); }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try { final rows = await StorylinesDatabaseHelper.readAllStorylines(); if (mounted) setState(() { _items = rows; _loading = false; }); }
    catch (_) { if (mounted) setState(() => _loading = false); }
  }

  List<Storylines> get _visible {
    final q = _search.trim().toLowerCase();
    final rows = _items.where((s) => (_status == 'all' || s.status == _status) &&
      (q.isEmpty || s.title.toLowerCase().contains(q) || s.text.toLowerCase().contains(q))).toList();
    rows.sort((a, b) {
      switch (_sort) {
        case 'oldest': return a.yearStart != b.yearStart ? a.yearStart.compareTo(b.yearStart) : (a.start != b.start ? a.start.compareTo(b.start) : a.dayStart.compareTo(b.dayStart));
        case 'title': return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        default: return a.yearStart != b.yearStart ? b.yearStart.compareTo(a.yearStart) : (b.start != a.start ? b.start.compareTo(a.start) : b.dayStart.compareTo(a.dayStart));
      }
    });
    return rows;
  }

  @override Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(drawer: const Navbar(), appBar: AppBar(title: _searching ? TextField(controller: _searchController, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Rechercher une storyline…', border: InputBorder.none), onChanged: (v) => setState(() => _search = v)) : const Text('Storylines'), centerTitle: true, actions: [IconButton(icon: Icon(_searching ? Icons.close : Icons.search), onPressed: () { setState(() { _searching = !_searching; if (!_searching) { _search = ''; _searchController.clear(); } }); _refresh(); })]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0), child: Row(children: [const Text('Trier :'), const SizedBox(width: 8), Expanded(child: DropdownButton<String>(isExpanded: true, value: _sort, items: const [DropdownMenuItem(value: 'recent', child: Text('Plus récentes')), DropdownMenuItem(value: 'oldest', child: Text('Plus anciennes')), DropdownMenuItem(value: 'title', child: Text('Titre A → Z'))], onChanged: (v) => setState(() => _sort = v ?? 'recent')))])),
        SizedBox(height: 54, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), children: [
          _filter('Toutes', 'all'), ...StorylineStatus.values.map((s) => _filter(StorylineStatus.label(s), s)),
        ])),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _visible.isEmpty ? const Center(child: Text('Aucune storyline pour ce filtre.')) : RefreshIndicator(onRefresh: _refresh, child: ListView.builder(padding: const EdgeInsets.fromLTRB(12, 4, 12, 88), itemCount: _visible.length, itemBuilder: (context, index) {
          final item = _visible[index];
          return Card(child: ListTile(onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => StorylinesDetailPage(storylineId: item.id!))); _refresh(); }, title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Début : ${item.yearStart} · S${item.start} · J${item.dayStart}${item.end == 0 ? '' : '   •   Fin : ${item.yearEnd} · S${item.end} · J${item.dayEnd}'}'), trailing: _statusChip(item.status)));
        }))),
      ]), floatingActionButton: FloatingActionButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditStorylinesPage())); _refresh(); }, child: const Icon(Icons.add)));
  }

  Widget _filter(String label, String value) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(label: Text(label), selected: _status == value, onSelected: (_) => setState(() => _status = value)));
  Widget _statusChip(String value) => Chip(label: Text(StorylineStatus.label(value), style: const TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero);
}
