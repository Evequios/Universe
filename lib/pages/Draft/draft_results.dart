import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/pages/Superstars/superstars_page.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';

class DraftResults extends StatefulWidget {
  final List<Superstars> selectedSuperstars;
  final List<Brands> selectedBrands;
  const DraftResults({super.key, required this.selectedSuperstars, required this.selectedBrands});

  @override
  State<DraftResults> createState() => _DraftResultsState();
}

class _DraftResultsState extends State<DraftResults> {
  late Map<int, int> _assignments;
  bool _saving = false;

  @override
  void initState() { super.initState(); _reroll(); }

  void _reroll() {
    final wrestlers = List<Superstars>.from(widget.selectedSuperstars)..shuffle(Random());
    final brands = widget.selectedBrands.where((b) => b.id != null).toList();
    final counts = <int, int>{for (final b in brands) b.id!: 0};
    final result = <int, int>{};
    final random = Random();
    for (final superstar in wrestlers) {
      if (superstar.id == null || brands.isEmpty) continue;
      final minimum = counts.values.reduce(min);
      final leastUsed = brands.where((b) => counts[b.id] == minimum).toList()..shuffle(random);
      final chosen = leastUsed.first;
      result[superstar.id!] = chosen.id!;
      counts[chosen.id!] = counts[chosen.id!]! + 1;
    }
    setState(() => _assignments = result);
  }

  Future<void> _confirm() async {
    if (_saving || _assignments.isEmpty) return;
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Confirm Draft ?'),
      content: Text('${_assignments.length} Superstar(s) will be assigned to their new Brand. Existing teams will keep their members; their Brand will follow their Superstars.'),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Confirmer'))],
    ));
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await SuperstarsDatabaseHelper.draft(_assignments);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved successfully.')));
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SuperstarsPage()), (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Widget _brandMark(Brands brand) {
    final key = brand.name.toLowerCase();
    if (const ['raw', 'smackdown', 'nxt'].contains(key)) {
      return Image.asset('assets/$key.png', width: 76, height: 48, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Text(brand.name, style: const TextStyle(fontWeight: FontWeight.w800)));
    }
    return Text(brand.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16));
  }

  @override
  Widget build(BuildContext context) {
    final brandsById = {for (final brand in widget.selectedBrands) if (brand.id != null) brand.id!: brand};
    final counts = <int, int>{for (final brand in widget.selectedBrands) if (brand.id != null) brand.id!: 0};
    for (final id in _assignments.values) { counts[id] = (counts[id] ?? 0) + 1; }
    return Scaffold(
      appBar: AppBar(title: const Text('Draft Results'), actions: [
        IconButton(tooltip: 'Reroll Draft', onPressed: _saving ? null : _reroll, icon: const Icon(Icons.shuffle)),
      ]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final brand in widget.selectedBrands) Chip(avatar: const Icon(Icons.flag, size: 16), label: Text('${brand.name} · ${counts[brand.id] ?? 0}')),
        ])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.fromLTRB(12, 4, 12, 12), itemCount: widget.selectedSuperstars.length, itemBuilder: (_, index) {
          final superstar = widget.selectedSuperstars[index];
          final brand = brandsById[_assignments[superstar.id]];
          return Card(child: ListTile(
            leading: SuperstarAvatar(superstar: superstar, size: 48, radius: 12),
            title: Text(superstar.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.arrow_forward, color: Colors.white54), const SizedBox(width: 10), if (brand != null) _brandMark(brand)]),
          ));
        })),
      ]),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: Row(children: [
        OutlinedButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Retour')),
        const SizedBox(width: 12),
        Expanded(child: FilledButton.icon(onPressed: _saving ? null : _confirm,
          icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
          label: Text(_saving ? 'Saving…' : 'Confirm Draft'))),
      ]))),
    );
  }
}
