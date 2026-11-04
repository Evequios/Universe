import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/navbar.dart';
import 'package:wwe_universe/pages/Draft/draft_brands.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';
import 'package:wwe_universe/widget/superstar_picker.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  List<Superstars> _superstars = [];
  List<Brands> _brands = [];
  final Set<int> _selectedIds = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final values = await Future.wait([
        SuperstarsDatabaseHelper.readAllSuperstars(),
        BrandsDatabaseHelper.readAllBrands(),
      ]);
      if (!mounted) return;
      setState(() {
        _superstars = values[0] as List<Superstars>;
        _brands = values[1] as List<Brands>;
        _selectedIds.removeWhere((id) => !_superstars.any((s) => s.id == id));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _openSuperstarPicker() async {
    final picked = await pickSuperstars(
      context: context,
      available: _superstars,
      selectedIds: _selectedIds,
      title: 'Select Draft Superstars',
    );
    if (!mounted) return;
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(picked.where((s) => s.id != null).map((s) => s.id!));
    });
  }

  void _randomSelection() {
    final candidates = List<Superstars>.from(_superstars)..shuffle();
    final count = max(1, (candidates.length / 2).round());
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(candidates.take(count).where((s) => s.id != null).map((s) => s.id!));
    });
  }

  Future<void> _continue() async {
    final selected = _superstars.where((s) => s.id != null && _selectedIds.contains(s.id)).toList();
    if (selected.isEmpty || _brands.isEmpty) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DraftBrands(selectedSuperstars: selected),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _superstars.where((s) => s.id != null && _selectedIds.contains(s.id)).toList();
    final theme = Theme.of(context);
    return Scaffold(
      drawer: const Navbar(),
      appBar: AppBar(
        title: const Text('Draft'),
        actions: [IconButton(tooltip: 'Refresh', onPressed: _loadData, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadData)
              : _superstars.isEmpty
                  ? const _EmptyView(icon: Icons.groups_outlined, title: 'No Superstars', message: 'Add Superstars before starting a Draft.')
                  : _brands.isEmpty
                      ? const _EmptyView(icon: Icons.flag_outlined, title: 'No Brands', message: 'Create at least one Brand before starting a Draft.')
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                              child: Row(children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Select Superstars', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('${_selectedIds.length} selected out of ${_superstars.length}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60)),
                                ])),
                                TextButton(onPressed: () => setState(() => _selectedIds.addAll(_superstars.where((s) => s.id != null).map((s) => s.id!))), child: const Text('All')),
                                TextButton(onPressed: () => setState(_selectedIds.clear), child: const Text('None')),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Card(
                                child: ListTile(
                                  leading: const Icon(Icons.person_search_outlined),
                                  title: const Text('Open Superstar Selector'),
                                  subtitle: const Text('Search, filter by Brand and select multiple Superstars'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: _openSuperstarPicker,
                                ),
                              ),
                            ),
                            Expanded(
                              child: selected.isEmpty
                                  ? const Center(child: Text('No Superstars selected yet.'))
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                                      itemCount: selected.length,
                                      itemBuilder: (context, index) {
                                        final superstar = selected[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          child: ListTile(
                                            leading: SuperstarAvatar(superstar: superstar, size: 44, radius: 12),
                                            title: Text(superstar.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                            subtitle: Text(superstar.brand?.name ?? 'No Brand'),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
      bottomNavigationBar: !_isLoading && _error == null && _superstars.isNotEmpty && _brands.isNotEmpty
          ? SafeArea(child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(children: [
                OutlinedButton.icon(onPressed: _randomSelection, icon: const Icon(Icons.shuffle), label: const Text('Random')),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  onPressed: _selectedIds.isEmpty ? null : _continue,
                  icon: const Icon(Icons.arrow_forward), label: Text('Select Brands (${_selectedIds.length})'),
                )),
              ]),
            ))
          : null,
    );
  }
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyView({required this.icon, required this.title, required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 52, color: Colors.white38), const SizedBox(height: 16), Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60))])));
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12), const Text('Unable to load the Draft'), Text(message, textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton(onPressed: onRetry, child: const Text('Retry'))])));
}
