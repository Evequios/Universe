import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/widget/shows_form_widget.dart';

class AddEditShowsPage extends StatefulWidget {
  final Show? show;
  final int? initialYear;
  final int? initialWeek;
  final int? initialDayOfWeek;

  const AddEditShowsPage({
    super.key,
    this.show,
    this.initialYear,
    this.initialWeek,
    this.initialDayOfWeek,
  });

  @override
  AddEditShowsPageState createState() => AddEditShowsPageState();
}

class AddEditShowsPageState extends State<AddEditShowsPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late int year;
  late int week;
  late int dayOfWeek;
  late String summary;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    name = widget.show?.name ?? '';
    year = widget.show?.year ?? widget.initialYear ?? 1;
    week = widget.show?.week ?? widget.initialWeek ?? 1;
    dayOfWeek = widget.show?.dayOfWeek ?? widget.initialDayOfWeek ?? 1;
    summary = widget.show?.summary ?? '';
  }

  void _applySelectedDate(Map<String, int> date) {
    setState(() {
      year = date['year']!;
      week = date['week']!;
      dayOfWeek = date['day']!;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.show == null ? 'Create show' : "Show's infos"),
      centerTitle: true,
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: ShowsFormWidget(
        name: name,
        year: year,
        week: week,
        dayOfWeek: dayOfWeek,
        summary: summary,
        onChangedName: (value) => setState(() => name = value),
        onSelectDate: _applySelectedDate,
        onChangedSummary: (value) => summary = value,
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = name.trim().isNotEmpty &&
        year > 0 && week >= 1 && week <= 48 &&
        dayOfWeek >= 1 && dayOfWeek <= 7;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: isSaving ? null : addOrUpdateUniverseShows,
        child: isSaving
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Save'),
      ),
    );
  }

  Future<void> addOrUpdateUniverseShows() async {
    if (isSaving || !_formKey.currentState!.validate()) return;
    if (year < 1 || week < 1 || week > 48 || dayOfWeek < 1 || dayOfWeek > 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid WWE date.')),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      final existing = widget.show;
      final show = existing == null
          ? Show(
              name: name.trim(),
              year: year,
              week: week,
              dayOfWeek: dayOfWeek,
              summary: summary,
            )
          : existing.copy(
              name: name.trim(),
              year: year,
              week: week,
              dayOfWeek: dayOfWeek,
              summary: summary,
            );

      if (existing == null) {
        await ShowsDatabaseHelper.createShow(show);
      } else {
        await ShowsDatabaseHelper.updateShow(show);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save show: $error')),
      );
    }
  }
}
