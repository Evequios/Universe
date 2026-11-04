
import 'package:flutter/material.dart';

import 'package:wwe_universe/classes/match_types.dart';
import 'package:wwe_universe/classes/match_formats.dart';
import 'package:wwe_universe/database/match_types_database_helper.dart';
import 'package:wwe_universe/database/match_formats_database_helper.dart';
import 'package:wwe_universe/database/match_type_formats_database_helper.dart';

class MatchCatalogSettingsPage extends StatelessWidget {
  const MatchCatalogSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Matches'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Types'),
              Tab(text: 'Formats'),
              Tab(text: 'Compatibility'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MatchTypesTab(),
            _MatchFormatsTab(),
            _MatchCompatibilityTab(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TYPES DE COMBAT
// -----------------------------------------------------------------------------

class _MatchTypesTab extends StatefulWidget {
  const _MatchTypesTab();

  @override
  State<_MatchTypesTab> createState() => _MatchTypesTabState();
}

class _MatchTypesTabState extends State<_MatchTypesTab> {
  List<MatchTypes> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() => loading = true);
    final result = await MatchTypesDatabaseHelper.readAll(activeOnly: false);
    if (!mounted) return;
    setState(() {
      items = result;
      loading = false;
    });
  }

  Future<void> edit([MatchTypes? item]) async {
    final result = await showDialog<MatchTypes>(
      context: context,
      builder: (_) => _MatchTypeDialog(item: item),
    );

    if (result == null) return;

    if (item == null) {
      await MatchTypesDatabaseHelper.create(result);
    } else {
      await MatchTypesDatabaseHelper.update(result);
    }

    await refresh();
  }

  Future<void> delete(MatchTypes item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this type?'),
        content: Text(
          'The type "${item.name}" will be removed from the catalog. '
          'Existing matches will retain their history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || item.id == null) return;

    await MatchTypesDatabaseHelper.delete(item.id!);
    await refresh();
  }

  Future<void> toggleActive(MatchTypes item, bool value) async {
    await MatchTypesDatabaseHelper.update(item.copy(isActive: value));
    await refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text('No match types'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item.category}'
                      '${item.isActive ? '' : ' • Inactive'}',
                    ),
                    leading: Icon(
                      item.isActive ? Icons.sports_mma : Icons.pause_circle,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') edit(item);
                        if (value == 'delete') delete(item);
                        if (value == 'toggle') {
                          toggleActive(item, !item.isActive);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            item.isActive ? 'Deactivate' : 'Activate',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => edit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MatchTypeDialog extends StatefulWidget {
  final MatchTypes? item;

  const _MatchTypeDialog({this.item});

  @override
  State<_MatchTypeDialog> createState() => _MatchTypeDialogState();
}

class _MatchTypeDialogState extends State<_MatchTypeDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late String category;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.item?.description ?? '');
    category = widget.item?.category ?? 'standard';
    isActive = widget.item?.isActive ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'New Type' : 'Edit Type'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'The name is required'
                        : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(
                    value: 'standard',
                    child: Text('Standard'),
                  ),
                  DropdownMenuItem(
                    value: 'special',
                    child: Text('Special'),
                  ),
                  DropdownMenuItem(
                    value: 'tournament',
                    child: Text('Tournament'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => category = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Actif'),
                value: isActive,
                onChanged: (value) => setState(() => isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;

            Navigator.pop(
              context,
              MatchTypes(
                id: widget.item?.id,
                name: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
                category: category,
                isActive: isActive,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// FORMATS DE COMBAT
// -----------------------------------------------------------------------------

class _MatchFormatsTab extends StatefulWidget {
  const _MatchFormatsTab();

  @override
  State<_MatchFormatsTab> createState() => _MatchFormatsTabState();
}

class _MatchFormatsTabState extends State<_MatchFormatsTab> {
  List<MatchFormats> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() => loading = true);
    final result = await MatchFormatsDatabaseHelper.readAllFormats();
    if (!mounted) return;
    setState(() {
      items = result;
      loading = false;
    });
  }

  Future<void> edit([MatchFormats? item]) async {
    final result = await showDialog<MatchFormats>(
      context: context,
      builder: (_) => _MatchFormatDialog(item: item),
    );

    if (result == null) return;

    if (item == null) {
      await MatchFormatsDatabaseHelper.createFormat(result);
    } else {
      await MatchFormatsDatabaseHelper.updateFormat(result);
    }

    await refresh();
  }

  Future<void> delete(MatchFormats item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this format?'),
        content: Text(
          'The format "${item.name}" will be removed from the catalog. '
          'Existing matches will retain their history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || item.id == null) return;

    await MatchFormatsDatabaseHelper.deleteFormat(item.id!);
    await refresh();
  }

  Future<void> toggleActive(MatchFormats item, bool value) async {
    await MatchFormatsDatabaseHelper.updateFormat(
      item.copy(isActive: value),
    );
    await refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text('No match formats'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                final details = item.isSpecial
                    ? '${item.participantCount} participants • Special'
                    : '${item.participantCount} participants • '
                        '${item.sideCount} sides';

                return Card(
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '$details${item.isActive ? '' : ' • Inactive'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') edit(item);
                        if (value == 'delete') delete(item);
                        if (value == 'toggle') {
                          toggleActive(item, !item.isActive);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            item.isActive ? 'Deactivate' : 'Activate',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => edit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MatchFormatDialog extends StatefulWidget {
  final MatchFormats? item;

  const _MatchFormatDialog({this.item});

  @override
  State<_MatchFormatDialog> createState() => _MatchFormatDialogState();
}

class _MatchFormatDialogState extends State<_MatchFormatDialog> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController participantCountController;
  late final TextEditingController sideCountController;
  late final TextEditingController participantsPerSideController;

  late String category;
  late bool isActive;
  late bool special;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    nameController = TextEditingController(text: item?.name ?? '');
    descriptionController =
        TextEditingController(text: item?.description ?? '');
    participantCountController = TextEditingController(
      text: (item?.participantCount ?? 2).toString(),
    );
    sideCountController = TextEditingController(
      text: (item?.sideCount ?? 2).toString(),
    );
    participantsPerSideController = TextEditingController(
      text: (item?.participantsPerSide ?? [1, 1]).join(', '),
    );

    category = item?.category ?? 'individual';
    isActive = item?.isActive ?? true;
    special = item?.isSpecial ?? false;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    participantCountController.dispose();
    sideCountController.dispose();
    participantsPerSideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'New Format' : 'Edit Format'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'The name is required'
                        : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  const DropdownMenuItem(
                    value: 'individual',
                    child: Text('Singles'),
                  ),
                  const DropdownMenuItem(
                    value: 'tag',
                    child: Text('Tag Team'),
                  ),
                  const DropdownMenuItem(
                    value: 'special',
                    child: Text('Special'),
                  ),
                  if (!['individual', 'tag', 'special'].contains(category))
                    DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => category = value);
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Special format without sides'),
                value: special,
                onChanged: (value) {
                  setState(() {
                    special = value;
                    if (value) {
                      sideCountController.text = '0';
                      participantsPerSideController.text = '';
                    } else {
                      if (sideCountController.text == '0') {
                        sideCountController.text = '2';
                      }
                      if (participantsPerSideController.text.isEmpty) {
                        participantsPerSideController.text = '1, 1';
                      }
                    }
                  });
                },
              ),
              TextFormField(
                controller: participantCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total participant count',
                ),
                validator: _positiveIntegerValidator,
              ),
              if (!special) ...[
                TextFormField(
                  controller: sideCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of sides',
                  ),
                  validator: _positiveIntegerValidator,
                ),
                TextFormField(
                  controller: participantsPerSideController,
                  decoration: const InputDecoration(
                    labelText: 'Participants per side',
                    hintText: 'Example: 1, 1 or 2, 2',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Allocation is required';
                    }

                    final values = value.split(',');
                    final parsed = values
                        .map((e) => int.tryParse(e.trim()))
                        .toList();

                    if (parsed.any((e) => e == null || e <= 0)) {
                      return 'Use positive numbers separated by commas';
                    }

                    if (parsed.length !=
                        int.tryParse(sideCountController.text)) {
                      return 'The number of values must match the number of sides';
                    }

                    final total = parsed.fold<int>(
                      0,
                      (sum, value) => sum + value!,
                    );

                    if (total !=
                        int.tryParse(participantCountController.text)) {
                      return 'The sum must match the total number of participants';
                    }

                    return null;
                  },
                ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Actif'),
                value: isActive,
                onChanged: (value) => setState(() => isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  String? _positiveIntegerValidator(String? value) {
    final number = int.tryParse(value ?? '');
    if (number == null || number <= 0) {
      return 'Enter a positive number';
    }
    return null;
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    final participantCount = int.parse(participantCountController.text);
    final sideCount = special ? 0 : int.parse(sideCountController.text);

    final participantsPerSide = special
        ? <int>[]
        : participantsPerSideController.text
            .split(',')
            .map((value) => int.parse(value.trim()))
            .toList();

    Navigator.pop(
      context,
      MatchFormats(
        id: widget.item?.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        category: category,
        participantCount: participantCount,
        sideCount: sideCount,
        participantsPerSide: participantsPerSide,
        isActive: isActive,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// COMPATIBILITES TYPES / FORMATS
// -----------------------------------------------------------------------------

class _MatchCompatibilityTab extends StatefulWidget {
  const _MatchCompatibilityTab();

  @override
  State<_MatchCompatibilityTab> createState() =>
      _MatchCompatibilityTabState();
}

class _MatchCompatibilityTabState extends State<_MatchCompatibilityTab> {
  List<MatchTypes> types = [];
  List<MatchFormats> formats = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() => loading = true);

    final loadedTypes =
        await MatchTypesDatabaseHelper.readAll(activeOnly: false);
    final loadedFormats = await MatchFormatsDatabaseHelper.readAllFormats();

    if (!mounted) return;

    setState(() {
      types = loadedTypes;
      formats = loadedFormats;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (types.isEmpty || formats.isEmpty) {
      return Center(
        child: Text(
          types.isEmpty
              ? 'Create a match type first.'
              : 'Create a match format first.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: types.map((type) {
        return _MatchTypeCompatibilityTile(
          type: type,
          formats: formats,
        );
      }).toList(),
    );
  }
}

class _MatchTypeCompatibilityTile extends StatefulWidget {
  final MatchTypes type;
  final List<MatchFormats> formats;

  const _MatchTypeCompatibilityTile({
    required this.type,
    required this.formats,
  });

  @override
  State<_MatchTypeCompatibilityTile> createState() =>
      _MatchTypeCompatibilityTileState();
}

class _MatchTypeCompatibilityTileState
    extends State<_MatchTypeCompatibilityTile> {
  Set<int> selectedIds = {};
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (widget.type.id == null) return;

    final ids = await MatchTypeFormatsDatabaseHelper.readFormatIdsForType(
      widget.type.id!,
    );

    if (!mounted) return;

    setState(() {
      selectedIds = ids.toSet();
      loading = false;
    });
  }

  Future<void> toggle(int formatId, bool selected) async {
    if (saving || widget.type.id == null) return;

    setState(() {
      if (selected) {
        selectedIds.add(formatId);
      } else {
        selectedIds.remove(formatId);
      }
      saving = true;
    });

    try {
      await MatchTypeFormatsDatabaseHelper.setCompatibility(
        widget.type.id!,
        selectedIds.toList(),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(
          widget.type.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${selectedIds.length} format(s) compatible'
          '${widget.type.isActive ? '' : ' • Inactive type'}',
        ),
        children: [
          if (loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else
            ...widget.formats.map((format) {
              if (format.id == null) return const SizedBox.shrink();

              return CheckboxListTile(
                dense: true,
                title: Text(format.name),
                subtitle: format.isActive ? null : const Text('Inactive format'),
                value: selectedIds.contains(format.id),
                onChanged: saving
                    ? null
                    : (value) => toggle(format.id!, value ?? false),
              );
            }),
          if (saving)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
