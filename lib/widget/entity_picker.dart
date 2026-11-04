import 'package:flutter/material.dart';

/// Shared searchable picker used for Brands, Titles and Teams.
/// Returns IDs so callers remain independent from navigation and storage.
class EntityPickerPage<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final int? Function(T) idOf;
  final String Function(T) nameOf;
  final String? Function(T)? subtitleOf;
  final Set<int> initiallySelected;
  final bool multiSelect;
  final int? maximumSelection;

  const EntityPickerPage({super.key, required this.title, required this.items,
    required this.idOf, required this.nameOf, this.subtitleOf,
    this.initiallySelected = const {}, this.multiSelect = false,
    this.maximumSelection});

  @override
  State<EntityPickerPage<T>> createState() => _EntityPickerPageState<T>();
}

class _EntityPickerPageState<T> extends State<EntityPickerPage<T>> {
  final _search = TextEditingController();
  late final Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initiallySelected};
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final visible = widget.items.where((item) =>
      widget.idOf(item) != null && widget.nameOf(item).toLowerCase().contains(query)).toList()
      ..sort((a, b) => widget.nameOf(a).toLowerCase().compareTo(widget.nameOf(b).toLowerCase()));
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [TextButton(
        onPressed: () => Navigator.pop(context, _selected.toList()),
        child: Text(widget.multiSelect ? 'DONE (${_selected.length})' : 'SELECT'),
      )]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          controller: _search, onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: 'Search...',
            prefixIcon: const Icon(Icons.search), suffixIcon: _search.text.isEmpty ? null : IconButton(
              onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.clear)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        )),
        Expanded(child: visible.isEmpty ? const Center(child: Text('No results found')) : ListView.separated(
          itemCount: visible.length, separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = visible[index]; final id = widget.idOf(item)!;
            final selected = _selected.contains(id);
            return ListTile(leading: Icon(widget.multiSelect ? (selected ? Icons.check_circle : Icons.circle_outlined) : Icons.label_outline),
              title: Text(widget.nameOf(item)),
              subtitle: widget.subtitleOf?.call(item) == null ? null : Text(widget.subtitleOf!(item)!),
              trailing: selected ? const Icon(Icons.check, color: Colors.redAccent) : null,
              selected: selected,
              onTap: () {
                if (!widget.multiSelect) { Navigator.pop(context, <int>[id]); return; }
                setState(() {
                  if (selected) { _selected.remove(id); }
                  else if (widget.maximumSelection == null || _selected.length < widget.maximumSelection!) { _selected.add(id); }
                });
              });
          },
        )),
      ]),
    );
  }
}

Future<List<T>> pickEntities<T>({required BuildContext context, required List<T> available,
  required int? Function(T) idOf, required String Function(T) nameOf,
  String? Function(T)? subtitleOf, Set<int> selectedIds = const {},
  required String title, bool multiSelect = false, int? maximumSelection}) async {
  final ids = await Navigator.of(context).push<List<int>>(MaterialPageRoute(builder: (_) =>
    EntityPickerPage<T>(title: title, items: available, idOf: idOf, nameOf: nameOf,
      subtitleOf: subtitleOf, initiallySelected: selectedIds, multiSelect: multiSelect,
      maximumSelection: maximumSelection)));
  if (ids == null) return available.where((item) => idOf(item) != null && selectedIds.contains(idOf(item))).toList();
  final byId = {for (final item in available) if (idOf(item) != null) idOf(item)!: item};
  return ids.where(byId.containsKey).map((id) => byId[id]!).toList();
}

Future<T?> pickOneEntity<T>({required BuildContext context, required List<T> available,
  required int? Function(T) idOf, required String Function(T) nameOf,
  String? Function(T)? subtitleOf, int? selectedId, required String title}) async {
  final result = await pickEntities<T>(context: context, available: available,
    idOf: idOf, nameOf: nameOf, subtitleOf: subtitleOf,
    selectedIds: selectedId == null ? {} : {selectedId}, title: title);
  return result.isEmpty ? null : result.first;
}
