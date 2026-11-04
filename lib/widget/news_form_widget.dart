import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/superstar_picker.dart';
import 'package:wwe_universe/widget/entity_picker.dart';
import 'package:wwe_universe/widget/wwe_show_picker.dart';
import 'package:wwe_universe/widget/wwe_date_dialog.dart';

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
  final ValueChanged<Map<String, int>> onChangedDate;
  final ValueChanged<int?> onChangedStoryline;

  const NewsFormWidget({super.key, required this.title, required this.text,
    required this.type, required this.year, required this.week,
    required this.dayOfWeek, required this.storylineId, required this.storylines,
    required this.superstars, required this.teams, required this.titles, required this.shows,
    required this.selectedEntities, required this.onChangedEntities,
    required this.onChangedTitle, required this.onChangedText,
    required this.onChangedType, required this.onChangedDate,
    required this.onChangedStoryline});

  Future<void> _choose<T>({required BuildContext context, required String label,
    required List<T> items, required int? Function(T) idOf, required String Function(T) nameOf,
    required String key}) async {
    final picked = await pickEntities<T>(context: context, available: items,
      idOf: idOf, nameOf: nameOf, selectedIds: selectedEntities[key] ?? <int>{},
      title: label, multiSelect: true);
    final next = Map<String, Set<int>>.from(selectedEntities);
    next[key] = picked.map((item) => idOf(item)!).toSet();
    onChangedEntities(next);
  }

  Future<void> _chooseShows(BuildContext context) async {
    final picked = await showDialog<Show>(context: context,
      builder: (_) => const WweShowPicker(title: 'Select a Related Show'));
    if (picked == null || picked.id == null) return;
    final next = Map<String, Set<int>>.from(selectedEntities);
    final ids = Set<int>.from(next['shows'] ?? <int>{});
    if (!ids.add(picked.id!)) ids.remove(picked.id);
    next['shows'] = ids;
    onChangedEntities(next);
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

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDialog<Map<String, int>>(
      context: context,
      builder: (_) => WweDateDialog(
        title: 'Select news date',
        initialYear: year,
        initialWeek: week,
        initialDay: dayOfWeek,
      ),
    );
    if (date != null) onChangedDate(date);
  }

  Widget _associationTile(BuildContext context, String key, String label, IconData icon,
      List<int> ids, Future<void> Function() onTap, {List<String>? selectedNames}) => ListTile(
    contentPadding: EdgeInsets.zero, leading: Icon(icon, color: AppFormStyles.primary),
    title: Text(label),
    subtitle: Text(selectedNames != null && selectedNames.isNotEmpty
        ? selectedNames.join(' • ')
        : '${ids.length} selected', maxLines: 2, overflow: TextOverflow.ellipsis),
    trailing: const Icon(Icons.chevron_right), onTap: onTap);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppFormSection(title: 'Information', children: [
        TextFormField(initialValue: title, textCapitalization: TextCapitalization.sentences,
          decoration: AppFormStyles.inputDecoration(label: 'Title', icon: Icons.newspaper_outlined),
          validator: (v) => v == null || v.trim().isEmpty ? 'The title is required' : null, onChanged: onChangedTitle),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(isExpanded: true, value: listCategories.contains(type) ? type : listCategories.first,
          decoration: AppFormStyles.inputDecoration(label: 'Category', icon: Icons.category_outlined),
          items: listCategories.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: onChangedType),
        const SizedBox(height: 12),
        TextFormField(initialValue: text, minLines: 6, maxLines: null,
          decoration: AppFormStyles.inputDecoration(label: 'Content', icon: Icons.notes_outlined),
          validator: (v) => v == null || v.trim().isEmpty ? 'The content is required' : null, onChanged: onChangedText),
      ]), const SizedBox(height: 16),
      AppFormSection(title: 'WWE Date', child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_month, color: AppFormStyles.primary),
        title: Text('WWE Year $year • Week $week • Day $dayOfWeek'),
        subtitle: const Text('Tap to select a date in the WWE calendar'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _selectDate(context),
      )), const SizedBox(height: 16),
      AppFormSection(title: 'Storyline', child: DropdownButtonFormField<int?>(isExpanded: true, value: storylineId,
        decoration: AppFormStyles.inputDecoration(label: 'Related Storyline (optional)'),
        items: [const DropdownMenuItem<int?>(value: null, child: Text('No Storyline')), ...storylines.map((s) => DropdownMenuItem<int?>(value: s.id, child: Text(s.title, overflow: TextOverflow.ellipsis)))], onChanged: onChangedStoryline)),
      const SizedBox(height: 16),
      AppFormSection(title: 'Related Entities', children: [
        _associationTile(context, 'superstars', 'Superstars', Icons.person_outline, selectedEntities['superstars']?.toList() ?? [], () => _chooseSuperstars(context)),
        const Divider(height: 1),
        _associationTile(context, 'teams', 'Teams', Icons.groups_outlined, selectedEntities['teams']?.toList() ?? [], () => _choose(context: context, key: 'teams', label: 'Select Teams', items: teams, idOf: (v) => v.id, nameOf: (v) => v.name)),
        const Divider(height: 1),
        _associationTile(context, 'titles', 'Titles', Icons.workspace_premium_outlined, selectedEntities['titles']?.toList() ?? [], () => _choose(context: context, key: 'titles', label: 'Select Titles', items: titles, idOf: (v) => v.id, nameOf: (v) => v.name)),
        const Divider(height: 1),
        _associationTile(context, 'shows', 'Shows', Icons.event_outlined, selectedEntities['shows']?.toList() ?? [], () => _chooseShows(context), selectedNames: shows.where((show) => (selectedEntities['shows'] ?? <int>{}).contains(show.id)).map((show) => '${show.name} • Year ${show.year} • Week ${show.week}').toList()),
      ]),
    ]));
}
