import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/pages/Draft/draft_results.dart';

class DraftBrands extends StatefulWidget {
  final List<Superstars> selectedSuperstars;
  const DraftBrands({super.key, required this.selectedSuperstars});

  @override
  State<DraftBrands> createState() => _DraftBrandsState();
}

class _DraftBrandsState extends State<DraftBrands> {
  List<Brands> _brands = [];
  final Set<int> _selectedIds = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadBrands(); }

  Future<void> _loadBrands() async {
    setState(() { _loading = true; _error = null; });
    try {
      final brands = await BrandsDatabaseHelper.readAllBrands();
      if (!mounted) return;
      setState(() { _brands = brands; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _startDraft() async {
    final selected = _brands.where((b) => b.id != null && _selectedIds.contains(b.id)).toList();
    if (selected.isEmpty) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DraftResults(selectedSuperstars: widget.selectedSuperstars, selectedBrands: selected),
    ));
  }

  Widget _brandLogo(Brands brand) {
    final key = brand.name.toLowerCase();
    if (const ['raw', 'smackdown', 'nxt'].contains(key)) {
      return Image.asset('assets/$key.png', width: 64, height: 42, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Text(brand.name, style: const TextStyle(fontWeight: FontWeight.bold)));
    }
    return Text(brand.name, style: const TextStyle(fontWeight: FontWeight.w800));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Select Brands'), centerTitle: false),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _error != null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!), const SizedBox(height: 12), FilledButton(onPressed: _loadBrands, child: const Text('Retry'))]))
      : _brands.isEmpty ? const Center(child: Text('No Brands available.'))
      : Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Brands participantes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              Text('${widget.selectedSuperstars.length} Superstars to assign', style: const TextStyle(color: Colors.white60)),
            ])),
            TextButton(onPressed: () => setState(() => _selectedIds.addAll(_brands.where((b) => b.id != null).map((b) => b.id!))), child: const Text('All')),
            TextButton(onPressed: () => setState(_selectedIds.clear), child: const Text('None')),
          ])),
          Expanded(child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _brands.length, itemBuilder: (_, i) {
            final brand = _brands[i];
            final selected = brand.id != null && _selectedIds.contains(brand.id);
            return Card(child: CheckboxListTile(
              value: selected,
              onChanged: (_) => setState(() {
                if (selected) {
                  _selectedIds.remove(brand.id);
                } else if (brand.id != null) {
                  _selectedIds.add(brand.id!);
                }
              }),
              title: _brandLogo(brand),
              subtitle: Text(selected ? 'Included in the draft' : 'Not selected', style: const TextStyle(color: Colors.white54)),
              controlAffinity: ListTileControlAffinity.trailing,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ));
          })),
        ]),
    bottomNavigationBar: !_loading && _error == null && _brands.isNotEmpty ? SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: FilledButton.icon(onPressed: _selectedIds.isEmpty ? null : _startDraft,
        icon: const Icon(Icons.shuffle), label: Text('Start Draft (${_selectedIds.length} Brands)')),
    )) : null,
  );
}
