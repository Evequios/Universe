import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/superstar_picker.dart';

const List<String> listCategories = <String>['Announcement', 'Injury', 'Return', 'Other'];

class NewsFormWidget extends StatelessWidget {
  final String title, text, type;
  final int year, week, dayOfWeek;
  final int? storylineId;
  final List<Storylines> storylines;
  final List<Superstars> superstars;
  final List<Teams> teams;
  final List<Titles> titles;
  final List<Show> shows;
  final Map<String, Set<int>> selectedEntities;
  final ValueChanged<Map<String, Set<int>>> onChangedEntities;
  final ValueChanged<String> onChangedTitle;
  final ValueChanged<String> onChangedText;
  final ValueChanged<String?> onChangedType;
  final ValueChanged<int> onChangedYear, onChangedWeek, onChangedDay;
  final ValueChanged<int?> onChangedStoryline;

  const NewsFormWidget({super.key, required this.title, required this.text,
    required this.type, required this.year, required this.week,
    required this.dayOfWeek, required this.storylineId, required this.storylines,
    required this.superstars, required this.teams, required this.titles, required this.shows,
    required this.selectedEntities, required this.onChangedEntities,
    required this.onChangedTitle, required this.onChangedText,
    required this.onChangedType, required this.onChangedYear,
    required this.onChangedWeek, required this.onChangedDay,
    required this.onChangedStoryline});

  Future<void> _choose<T>({required BuildContext context, required String label,
    required List<T> items, required int? Function(T) idOf, required String Function(T) nameOf,
    required String key}) async {
    final temp = Set<int>.from(selectedEntities[key] ?? <int>{});
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(label),
          content: SizedBox(
            width: double.maxFinite,
            child: items.isEmpty
                ? const Text('Aucun élément disponible.')
                : ListView(
                    shrinkWrap: true,
                    children: items.map((item) {
                      final id = idOf(item)!;
                      return CheckboxListTile(
                        dense: true,
                        value: temp.contains(id),
                        title: Text(nameOf(item)),
                        onChanged: (checked) => setDialogState(() {
                          if (checked == true) {
                            temp.add(id);
                          } else {
                            temp.remove(id);
                          }
                        }),
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final next = Map<String, Set<int>>.from(selectedEntities);
                next[key] = temp;
                onChangedEntities(next);
                Navigator.pop(dialogContext);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseSuperstars(BuildContext context) async {
    final picked = await pickSuperstars(
      context: context,
      available: superstars,
      selectedIds: selectedEntities['superstars'] ?? <int>{},
      title: 'Select News Superstars',
    );
    final next = Map<String, Set<int>>.from(selectedEntities);
    next['superstars'] = picked.map((s) => s.id!).toSet();
    onChangedEntities(next);
  }

  Widget _associationTile(BuildContext context, String key, String label, IconData icon,
      List<int> ids, Future<void> Function() onTap) => ListTile(
    contentPadding: EdgeInsets.zero, leading: Icon(icon, color: AppFormStyles.primary),
    title: Text(label), subtitle: Text('${ids.length} selected'),
    trailing: const Icon(Icons.chevron_right), onTap: onTap);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppFormSection(title: 'Informations', children: [
        TextFormField(initialValue: title, textCapitalization: TextCapitalization.sentences,
          decoration: AppFormStyles.inputDecoration(label: 'Title', icon: Icons.newspaper_outlined),
          validator: (v) => v == null || v.trim().isEmpty ? 'Le titre est obligatoire' : null, onChanged: onChangedTitle),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(isExpanded: true, value: listCategories.contains(type) ? type : listCategories.first,
          decoration: AppFormStyles.inputDecoration(label: 'Category', icon: Icons.category_outlined),
          items: listCategories.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: onChangedType),
        const SizedBox(height: 12),
        TextFormField(initialValue: text, minLines: 6, maxLines: null,
          decoration: AppFormStyles.inputDecoration(label: 'Content', icon: Icons.notes_outlined),
          validator: (v) => v == null || v.trim().isEmpty ? 'Le contenu est obligatoire' : null, onChanged: onChangedText),
      ]), const SizedBox(height: 16),
      AppFormSection(title: 'WWE Date', children: [
        Row(children: [
          Expanded(flex: 2, child: DropdownButtonFormField<int>(isExpanded: true, value: year,
            decoration: AppFormStyles.inputDecoration(label: 'Year'),
            items: List.generate(31, (i) => year - 15 + i).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
            onChanged: (v) { if (v != null) onChangedYear(v); })),
          const SizedBox(width: 8),
          Expanded(child: DropdownButtonFormField<int>(isExpanded: true, value: week,
            decoration: AppFormStyles.inputDecoration(label: 'Week'),
            items: List.generate(48, (i) => i + 1).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
            onChanged: (v) { if (v != null) onChangedWeek(v); })),
          const SizedBox(width: 8),
          Expanded(child: DropdownButtonFormField<int>(isExpanded: true, value: dayOfWeek,
            decoration: AppFormStyles.inputDecoration(label: 'Jour'),
            items: const [DropdownMenuItem(value: 1, child: Text('Lun.')), DropdownMenuItem(value: 2, child: Text('Mar.')), DropdownMenuItem(value: 3, child: Text('Mer.')), DropdownMenuItem(value: 4, child: Text('Jeu.')), DropdownMenuItem(value: 5, child: Text('Ven.')), DropdownMenuItem(value: 6, child: Text('Sam.')), DropdownMenuItem(value: 7, child: Text('Dim.'))],
            onChanged: (v) { if (v != null) onChangedDay(v); })),
        ]),
      ]), const SizedBox(height: 16),
      AppFormSection(title: 'Storyline', child: DropdownButtonFormField<int?>(isExpanded: true, value: storylineId,
        decoration: AppFormStyles.inputDecoration(label: 'Related Storyline (optional)'),
        items: [const DropdownMenuItem<int?>(value: null, child: Text('No Storyline')), ...storylines.map((s) => DropdownMenuItem<int?>(value: s.id, child: Text(s.title, overflow: TextOverflow.ellipsis)))], onChanged: onChangedStoryline)),
      const SizedBox(height: 16),
      AppFormSection(title: 'Related Entities', children: [
        _associationTile(context, 'superstars', 'Superstars', Icons.person_outline, selectedEntities['superstars']?.toList() ?? [], () => _chooseSuperstars(context)),
        const Divider(height: 1),
        _associationTile(context, 'teams', 'Teams', Icons.groups_outlined, selectedEntities['teams']?.toList() ?? [], () => _choose(context: context, key: 'teams', label: 'Teams associées', items: teams, idOf: (v) => v.id, nameOf: (v) => v.name)),
        const Divider(height: 1),
        _associationTile(context, 'titles', 'Titles', Icons.workspace_premium_outlined, selectedEntities['titles']?.toList() ?? [], () => _choose(context: context, key: 'titles', label: 'Titles associés', items: titles, idOf: (v) => v.id, nameOf: (v) => v.name)),
        const Divider(height: 1),
        _associationTile(context, 'shows', 'Shows', Icons.event_outlined, selectedEntities['shows']?.toList() ?? [], () => _choose(context: context, key: 'shows', label: 'Related Shows', items: shows, idOf: (v) => v.id, nameOf: (v) => '${v.name} • ${v.year} S${v.week}')),
      ]),
    ]));
}
