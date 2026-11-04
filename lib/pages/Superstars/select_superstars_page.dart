import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';

/// Reusable searchable Superstar picker. Returns the selected Superstar IDs.
class SelectSuperstarsPage extends StatefulWidget {
  final Set<int> initiallySelected;
  final Set<int> excludedIds;
  final Set<int>? allowedIds;
  final int? maximumSelection;
  final String title;

  const SelectSuperstarsPage({
    super.key,
    this.initiallySelected = const {},
    this.excludedIds = const {},
    this.allowedIds,
    this.maximumSelection,
    this.title = 'Select Superstars',
  });

  @override
  State<SelectSuperstarsPage> createState() => _SelectSuperstarsPageState();
}

class _SelectSuperstarsPageState extends State<SelectSuperstarsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Superstars> _all = [];
  List<Brands> _brands = [];
  final Set<int> _selected = {};
  int? _brandFilter;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.initiallySelected.where((id) =>
        widget.allowedIds == null || widget.allowedIds!.contains(id)));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait([
        SuperstarsDatabaseHelper.readAllSuperstars(),
        BrandsDatabaseHelper.readAllBrands(),
      ]);
      if (!mounted) return;
      setState(() {
        _all = (values[0] as List).cast<Superstars>();
        _brands = (values[1] as List).cast<Brands>();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() { _loadError = error.toString(); _loading = false; });
    }
  }

  List<Superstars> get _visible {
    final query = _searchController.text.trim().toLowerCase();
    return _all.where((s) {
      if (s.id == null || widget.excludedIds.contains(s.id)) return false;
      if (widget.allowedIds != null && !widget.allowedIds!.contains(s.id)) return false;
      if (_brandFilter != null && s.brand?.id != _brandFilter) return false;
      return query.isEmpty || s.name.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  void _toggle(Superstars superstar, bool? checked) {
    final id = superstar.id;
    if (id == null) return;
    setState(() {
      if (checked == true) {
        if (widget.maximumSelection == null || _selected.length < widget.maximumSelection!) {
          _selected.add(id);
        }
      } else {
        _selected.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selected.toList()),
            child: Text('DONE (${_selected.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
                  const SizedBox(height: 12), const Text('Unable to load Superstars'),
                  const SizedBox(height: 6), Text(_loadError!, textAlign: TextAlign.center),
                  const SizedBox(height: 12), FilledButton(onPressed: () { setState(() { _loading = true; _loadError = null; }); _load(); }, child: const Text('RETRY')),
                ])))
              : Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 0), child: Row(children: [
                Text('${visible.length} Superstars', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppFormStyles.secondaryText)),
                const Spacer(), Text('${_selected.length} selected', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppFormStyles.primary, fontWeight: FontWeight.bold)),
              ])),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search Superstars',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() {}); }),
                    filled: true,
                    fillColor: AppFormStyles.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<int?>(
                  value: _brandFilter,
                  isExpanded: true,
                  dropdownColor: AppFormStyles.surface,
                  decoration: const InputDecoration(labelText: 'Filter by Brand'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('All Brands')),
                    ..._brands.where((b) => b.id != null).map((b) => DropdownMenuItem<int?>(value: b.id, child: Text(b.name))),
                  ],
                  onChanged: (value) => setState(() => _brandFilter = value),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('No Superstars match your search or filters.'))
                    : ListView.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final superstar = visible[index];
                          final id = superstar.id!;
                          final selected = _selected.contains(id);
                          final atLimit = widget.maximumSelection != null && _selected.length >= widget.maximumSelection!;
                          return Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), child: Material(
                            color: selected ? AppFormStyles.primary.withOpacity(.13) : AppFormStyles.surface,
                            borderRadius: BorderRadius.circular(12),
                            child: CheckboxListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              value: selected,
                              onChanged: !selected && atLimit ? null : (value) => _toggle(superstar, value),
                              secondary: SuperstarAvatar(superstar: superstar, size: 50, radius: 14),
                              title: Text(superstar.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              subtitle: Text([superstar.brand?.name ?? 'No Brand', superstar.orientation].join(' • '), style: const TextStyle(color: AppFormStyles.secondaryText)),
                              activeColor: AppFormStyles.primary,
                              controlAffinity: ListTileControlAffinity.trailing,
                              dense: false,
                            ),
                          ));
                        },
                      ),
              ),
            ]),
    );
  }
}
