import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/superstar_relationships_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/pages/Superstars/select_superstars_page.dart';
import 'package:wwe_universe/pages/Superstars/superstars_detail_page.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';

class SuperstarRelationshipsPage extends StatefulWidget {
  final Superstars superstar;
  const SuperstarRelationshipsPage({super.key, required this.superstar});
  @override
  State<SuperstarRelationshipsPage> createState() => _SuperstarRelationshipsPageState();
}

class _SuperstarRelationshipsPageState extends State<SuperstarRelationshipsPage> with SingleTickerProviderStateMixin {
  static const Color bg = Color(0xFF101010);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color red = Color(0xFFD71920);
  late final TabController tabs;
  final Map<String, Set<int>> selected = {'manager': <int>{}, 'ally': <int>{}, 'rival': <int>{}};
  List<Superstars> roster = [];
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() { tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final values = await Future.wait([
        SuperstarsDatabaseHelper.readAllSuperstars(),
        SuperstarRelationshipsDatabaseHelper.readRelatedIds(widget.superstar.id!, 'manager'),
        SuperstarRelationshipsDatabaseHelper.readRelatedIds(widget.superstar.id!, 'ally'),
        SuperstarRelationshipsDatabaseHelper.readRelatedIds(widget.superstar.id!, 'rival'),
      ]);
      if (!mounted) return;
      setState(() {
        roster = (values[0] as List).cast<Superstars>().where((s) => s.id != widget.superstar.id).toList();
        selected['manager']!.addAll((values[1] as List).cast<int>());
        selected['ally']!.addAll((values[2] as List).cast<int>());
        selected['rival']!.addAll((values[3] as List).cast<int>());
        loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _choose(String type, String title) async {
    final ids = await Navigator.push<List<int>>(context, MaterialPageRoute(builder: (_) => SelectSuperstarsPage(
      title: title,
      initiallySelected: Set<int>.from(selected[type]!),
      excludedIds: {widget.superstar.id!},
    )));
    if (ids != null && mounted) setState(() { selected[type]!..clear()..addAll(ids); });
  }

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      for (final entry in selected.entries) {
        await SuperstarRelationshipsDatabaseHelper.replaceRelations(widget.superstar.id!, entry.key, entry.value.toList());
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to save relationships: $e')));
    } finally { if (mounted) setState(() => saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bg,
    appBar: AppBar(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      title: const Text('RELATIONSHIPS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      actions: [TextButton(onPressed: saving ? null : _save, child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: red)) : const Text('SAVE', style: TextStyle(color: red, fontWeight: FontWeight.bold)))],
    ),
    body: loading ? const Center(child: CircularProgressIndicator(color: red)) : Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Text('Manage ${widget.superstar.name}’s permanent managers, allies and rivals.', style: const TextStyle(color: Colors.white70))),
      TabBar(controller: tabs, indicatorColor: red, labelColor: Colors.white, unselectedLabelColor: Colors.white54, tabs: const [Tab(text: 'MANAGERS'), Tab(text: 'ALLIES'), Tab(text: 'RIVALS')]),
      Expanded(child: TabBarView(controller: tabs, children: [
        _relationshipList('manager', 'Select managers'),
        _relationshipList('ally', 'Select allies'),
        _relationshipList('rival', 'Select rivals'),
      ])),
    ]),
  );

  Widget _relationshipList(String type, String title) {
    final people = roster.where((s) => selected[type]!.contains(s.id)).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => _choose(type, title),
        icon: const Icon(Icons.person_search_outlined),
        label: Text('CHOOSE ${type.toUpperCase()}S (${people.length})'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: red), padding: const EdgeInsets.symmetric(vertical: 14)),
      ))),
      Expanded(child: people.isEmpty
          ? Center(child: Text(type == 'ally' ? 'No allies selected.' : type == 'rival' ? 'No rivals selected.' : 'No managers selected.', style: const TextStyle(color: Colors.white54)))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: people.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final person = people[index];
                return Container(
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF383838))),
                  child: ListTile(
                    leading: SuperstarAvatar(superstar: person, size: 48, radius: 13),
                    title: Text(person.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(person.brand?.name ?? 'No Brand', style: const TextStyle(color: Colors.white54)),
                    trailing: IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => setState(() => selected[type]!.remove(person.id))),
                    onTap: person.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuperstarsDetailPage(superstarId: person.id!))),
                  ),
                );
              },
            )),
    ]);
  }
}
