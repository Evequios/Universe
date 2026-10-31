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

  @override
  void initState() {
    super.initState();

    name = widget.show?.name ?? '';
    year = widget.show?.year ?? widget.initialYear ?? 1;
    week = widget.show?.week ?? widget.initialWeek ?? 1;
    dayOfWeek =
        widget.show?.dayOfWeek ?? widget.initialDayOfWeek ?? 1;
    summary = widget.show?.summary ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text("Show's infos"),
      centerTitle: true,
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: ShowsFormWidget(
        name: name,
        year : year,
        week: week,
        dayOfWeek: dayOfWeek,
        summary: summary,
        onChangedName: (name) => setState(() => this.name = name),
        onChangedYear: (year) => setState(() => this.year = int.parse(year)),
        onChangedWeek: (week) => setState(() => this.week = int.parse(week)),
        onChangedDayOfWeek: (dayOfWeek) => setState(() => this.dayOfWeek = int.parse(dayOfWeek)),
        onChangedSummary: (summary) => setState(() => this.summary = summary),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = name.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseShows,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseShows() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.show != null;

      if (isUpdating) {
        await updateUniverseShows();
      } else {
        await addUniverseShows();
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> updateUniverseShows() async {
    final show = widget.show!.copy(
      name: name,
      year: year,
      week: week,
      dayOfWeek: dayOfWeek,
      summary: summary,
    );

    await ShowsDatabaseHelper.updateShow(show);
  }

  Future addUniverseShows() async {
    final show = Show(
      name: name,
      year: year,
      week: week,
      dayOfWeek: dayOfWeek,
      summary: summary
    );
    await ShowsDatabaseHelper.createShow(show);
  }
}