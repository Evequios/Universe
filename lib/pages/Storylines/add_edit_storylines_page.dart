import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/database/storylines_database_helper.dart';
import 'package:wwe_universe/widget/storylines_form_widget.dart';

class AddEditStorylinesPage extends StatefulWidget {
  final Storylines? storyline;

  const AddEditStorylinesPage({
    super.key,
    this.storyline,
  });
  @override
  AddEditStorylinesPageState createState() => AddEditStorylinesPageState();
}

class AddEditStorylinesPageState extends State<AddEditStorylinesPage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String text;
  late int yearStart;
  late int yearEnd;
  late int start;
  late int end;

  @override
  void initState() {
    super.initState();

    title = widget.storyline?.title ?? '';
    text = widget.storyline?.text ?? '';
    yearStart = widget.storyline?.yearStart ?? 0;
    yearEnd = widget.storyline?.yearEnd ?? 0;
    start = widget.storyline?.start?? 0;
    end = widget.storyline?.end ?? 0;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: StorylinesFormWidget(
        title: title,
        text: text,
        yearStart : yearStart,
        yearEnd : yearEnd,
        start : start,
        end : end,
        onChangedTitle: (title) => setState(() => this.title = title!),
        onChangedText: (text) => setState(() => this.text = text!),
        onChangedYearStart: (yearStart) => setState(() => this.yearStart = int.parse(yearStart!)),
        onChangedYearEnd: (yearEnd) => setState(() => this.yearEnd = int.parse(yearEnd!)),
        onChangedStart: (start) => setState(() => this.start = int.parse(start!)),
        onChangedEnd: (end) => setState(() => this.end = int.parse(end!)),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty && text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseStorylines,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseStorylines() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.storyline != null;

      if (isUpdating) {
        await updateUniverseStorylines();
      } else {
        await addUniverseStorylines();
      }
    
      if (mounted) {
        Navigator.of(context).pop();
      }

    }
  }

  Future updateUniverseStorylines() async {
    final storyline = widget.storyline!.copy(
      title: title,
      text: text,
      yearStart : yearStart,
      yearEnd: yearEnd,
      start: start,
      end: end
    );

    await StorylinesDatabaseHelper.updateStoryline(storyline);
  }

  Future addUniverseStorylines() async {
    final storyline = Storylines(
      title: title,
      text: text, 
      yearStart: yearStart,
      yearEnd: yearEnd,
      start: start, 
      end: end
    );

    await StorylinesDatabaseHelper.createStoryline(storyline);
  }
}