import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/navbar.dart';
import 'package:wwe_universe/pages/Draft/draft_brands.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  List<Superstars> _superstars = [];
  List<Brands> _brands = [];
  final Set<int> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  List<Superstars> get _filteredSuperstars {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _superstars;
    return _superstars.where((s) => s.name.toLowerCase().contains(query)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  void _toggle(int? id) {
    if (id == null) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
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
    final filtered = _filteredSuperstars;
    final theme = Theme.of(context);
    return Scaffold(
      drawer: const Navbar(),
      appBar: AppBar(
        title: const Text('Draft'),
        actions: [IconButton(tooltip: 'Actualiser', onPressed: _loadData, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadData)
              : _superstars.isEmpty
                  ? const _EmptyView(icon: Icons.groups_outlined, title: 'Aucune Superstar', message: 'Ajoute des Superstars avant de lancer un Draft.')
                  : _brands.isEmpty
                      ? const _EmptyView(icon: Icons.flag_outlined, title: 'Aucune Brand', message: 'Crée au moins une Brand avant de lancer un Draft.')
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                              child: Row(children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Sélection des Superstars', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('${_selectedIds.length} sélectionnée(s) sur ${_superstars.length}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60)),
                                ])),
                                TextButton(onPressed: () => setState(() => _selectedIds.addAll(_superstars.where((s) => s.id != null).map((s) => s.id!))), child: const Text('Tout')),
                                TextButton(onPressed: () => setState(_selectedIds.clear), child: const Text('Aucun')),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Rechercher une Superstar', suffixIcon: _searchController.text.isEmpty ? null : IconButton(onPressed: _searchController.clear, icon: const Icon(Icons.close))),
                              ),
                            ),
                            Expanded(
                              child: filtered.isEmpty
                                  ? const Center(child: Text('Aucun résultat'))
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final superstar = filtered[index];
                                        final selected = superstar.id != null && _selectedIds.contains(superstar.id);
                                        final brand = superstar.brand;
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          child: ListTile(
                                            onTap: () => _toggle(superstar.id),
                                            leading: SuperstarAvatar(superstar: superstar, size: 48, radius: 12),
                                            title: Text(superstar.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                            subtitle: brand == null ? const Text('Sans Brand') : Text(brand.name),
                                            trailing: Checkbox(value: selected, onChanged: (_) => _toggle(superstar.id)),
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
                OutlinedButton.icon(onPressed: _randomSelection, icon: const Icon(Icons.shuffle), label: const Text('Aléatoire')),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  onPressed: _selectedIds.isEmpty ? null : _continue,
                  icon: const Icon(Icons.arrow_forward), label: Text('Choisir les Brands (${_selectedIds.length})'),
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
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12), const Text('Impossible de charger le Draft'), Text(message, textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton(onPressed: onRetry, child: const Text('Réessayer'))])));
}
