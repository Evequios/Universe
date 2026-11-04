import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/storylines_database_helper.dart';
import 'package:wwe_universe/database/storyline_participants_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/superstar_picker.dart';
import 'package:wwe_universe/widget/entity_picker.dart';
import 'package:wwe_universe/widget/wwe_date_dialog.dart';

class AddEditStorylinesPage extends StatefulWidget {
  final Storylines? storyline;
  const AddEditStorylinesPage({super.key, this.storyline});
  @override
  State<AddEditStorylinesPage> createState() => _AddEditStorylinesPageState();
}

class _AddEditStorylinesPageState extends State<AddEditStorylinesPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _startYear = TextEditingController();
  final _startWeek = TextEditingController();
  final _endYear = TextEditingController();
  final _endWeek = TextEditingController();
  final _startDay = TextEditingController();
  final _endDay = TextEditingController();
  String _status = StorylineStatus.ongoing;
  List<Superstars> _allSuperstars = [];
  List<Teams> _allTeams = [];
  Set<int> _selectedSuperstars = {};
  Set<int> _selectedTeams = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.storyline;
    _title.text = s?.title ?? '';
    _description.text = s?.text ?? '';
    _startYear.text = s == null || s.yearStart == 0 ? '' : '${s.yearStart}';
    _startWeek.text = s == null || s.start == 0 ? '' : '${s.start}';
    _startDay.text = s == null ? '' : '${s.dayStart}';
    _endYear.text = s == null || s.yearEnd == 0 ? '' : '${s.yearEnd}';
    _endWeek.text = s == null || s.end == 0 ? '' : '${s.end}';
    _endDay.text = s == null || s.end == 0 ? '' : '${s.dayEnd}';
    _status = s?.status ?? StorylineStatus.ongoing;
    _load();
  }

  Future<void> _load() async {
    try {
      final superstars = await SuperstarsDatabaseHelper.readAllSuperstars();
      final teams = await TeamsDatabaseHelper.readAllTeams();
      if (widget.storyline?.id != null) {
        final participants = await StorylineParticipantsDatabaseHelper.read(widget.storyline!.id!);
        _selectedSuperstars = participants.superstars.map((e) => e.id!).toSet();
        _selectedTeams = participants.teams.map((e) => e.id!).toSet();
      }
      if (!mounted) return;
      setState(() { _allSuperstars = superstars; _allTeams = teams; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _title.dispose(); _description.dispose(); _startYear.dispose(); _startWeek.dispose(); _endYear.dispose(); _endWeek.dispose(); _startDay.dispose(); _endDay.dispose();
    super.dispose();
  }

  int? _number(TextEditingController c) => c.text.trim().isEmpty ? null : int.tryParse(c.text.trim());

  String? _validateDate(TextEditingController year, TextEditingController week, TextEditingController day, String label, {bool required = false}) {
    final y = _number(year); final w = _number(week); final d = _number(day);
    if (required && (y == null || w == null || d == null)) return 'The start date is required.';
    if ((y == null) != (w == null) || (y == null) != (d == null)) return 'Enter the year, week and day together.';
    if (y != null && y < 1) return 'Invalid year.';
    if (w != null && (w < 1 || w > 48)) return 'The week must be between 1 and 48.';
    if (d != null && (d < 1 || d > 7)) return 'The day must be between 1 and 7.';
    return null;
  }

  Future<void> _chooseParticipants<T>({required String title, required List<T> items,
    required Set<int> selected, required int? Function(T) idOf,
    required String Function(T) nameOf, required ValueChanged<Set<int>> onChanged}) async {
    final picked = await pickEntities<T>(context: context, available: items,
      idOf: idOf, nameOf: nameOf, selectedIds: selected, title: title, multiSelect: true);
    onChanged(picked.map((item) => idOf(item)!).toSet());
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final startYear = _number(_startYear)!; final startWeek = _number(_startWeek)!;
    final startDay = _number(_startDay)!;
    final endYear = _number(_endYear) ?? 0; final endWeek = _number(_endWeek) ?? 0;
    final endDay = _number(_endDay) ?? 1;
    if (endYear != 0 && (endYear < startYear || (endYear == startYear && (endWeek < startWeek || (endWeek == startWeek && endDay < startDay))))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The end date must be on or after the start date.'))); return;
    }
    setState(() => _saving = true);
    try {
      final existing = widget.storyline;
      final value = Storylines(id: existing?.id, title: _title.text.trim(), text: _description.text.trim(), yearStart: startYear, yearEnd: endYear, start: startWeek, end: endWeek, dayStart: startDay, dayEnd: endDay, status: _status);
      final saved = existing == null ? await StorylinesDatabaseHelper.createStoryline(value) : value;
      if (existing != null) await StorylinesDatabaseHelper.updateStoryline(value);
      await StorylineParticipantsDatabaseHelper.replace(storylineId: saved.id!, superstarIds: _selectedSuperstars.toList(), teamIds: _selectedTeams.toList());
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to save storyline: $e')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _selectStorylineDate(
    String label,
    TextEditingController year,
    TextEditingController week,
    TextEditingController day,
  ) async {
    final selected = await showDialog<Map<String, int>>(
      context: context,
      builder: (_) => WweDateDialog(
        title: 'WWE Date – $label',
        confirmLabel: 'Confirm',
        initialYear: _number(year),
        initialWeek: _number(week),
        initialDay: _number(day) ?? 1,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      year.text = selected['year'].toString();
      week.text = selected['week'].toString();
      day.text = selected['day'].toString();
    });
  }

  Widget _dateField(
    String label,
    TextEditingController year,
    TextEditingController week,
    TextEditingController day, {
    bool required = false,
  }) {
    final hasDate = _number(year) != null && _number(week) != null && _number(day) != null;
    return FormField<bool>(
      validator: (_) => _validateDate(year, week, day, label, required: required),
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month, color: AppFormStyles.primary),
            title: Text(label),
            subtitle: Text(hasDate
                ? 'WWE Year ${year.text} • Week ${week.text} • Day ${day.text}'
                : 'Select a date in the WWE calendar'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (hasDate && !required)
                IconButton(
                  tooltip: 'Clear date',
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() { year.clear(); week.clear(); day.clear(); field.didChange(false); }),
                ),
              const Icon(Icons.chevron_right),
            ]),
            onTap: () async {
              await _selectStorylineDate(label, year, week, day);
              field.didChange(_number(year) != null && _number(week) != null && _number(day) != null);
            },
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(field.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101010),
    appBar: AppBar(title: Text(widget.storyline == null ? 'New Storyline' : 'Edit Storyline'), actions: [TextButton(onPressed: _saving || _loading ? null : _save, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('SAVE'))]),
    body: _loading ? const Center(child: CircularProgressIndicator()) : Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
      AppFormSection(title: 'Information', children: [
        TextFormField(controller: _title, decoration: AppFormStyles.inputDecoration(label: 'Title'), validator: (v) => v == null || v.trim().isEmpty ? 'The title is required.' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _description, minLines: 4, maxLines: 8, decoration: AppFormStyles.inputDecoration(label: 'Description / Summary'), validator: (v) => v == null || v.trim().isEmpty ? 'The description is required.' : null),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _status, decoration: AppFormStyles.inputDecoration(label: 'Status'), items: StorylineStatus.values.map((v) => DropdownMenuItem(value: v, child: Text(StorylineStatus.label(v)))).toList(), onChanged: (v) => setState(() => _status = v ?? _status)),
      ]), const SizedBox(height: 16),
      AppFormSection(title: 'WWE Timeline', children: [
        _dateField('Start', _startYear, _startWeek, _startDay, required: true), const SizedBox(height: 12),
        _dateField('End (optional)', _endYear, _endWeek, _endDay),
        const SizedBox(height: 8), const Text('The WWE calendar has 48 weeks. Leave the end date empty for an ongoing storyline.', style: TextStyle(color: AppFormStyles.secondaryText, fontSize: 12)),
      ]), const SizedBox(height: 16),
      AppFormSection(title: 'Participants', children: [
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.person_outline), title: const Text('Superstars'), subtitle: Text('${_selectedSuperstars.length} selected'), trailing: const Icon(Icons.chevron_right), onTap: () async { final picked = await pickSuperstars(context: context, available: _allSuperstars, selectedIds: _selectedSuperstars, title: 'Select Storyline Superstars'); setState(() => _selectedSuperstars = picked.map((e) => e.id!).toSet()); }),
        const Divider(height: 1),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.groups_outlined), title: const Text('Teams'), subtitle: Text('${_selectedTeams.length} selected'), trailing: const Icon(Icons.chevron_right), onTap: () => _chooseParticipants<Teams>(title: 'Participating Teams', items: _allTeams, selected: _selectedTeams, idOf: (v) => v.id, nameOf: (v) => v.name, onChanged: (v) => setState(() => _selectedTeams = v))),
      ]),
    ])),
  );
}
