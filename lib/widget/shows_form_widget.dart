import 'package:flutter/material.dart';
import 'package:wwe_universe/widget/wwe_date_dialog.dart';

class ShowsFormWidget extends StatelessWidget {
  final String? name;
  final int? year;
  final int? week;
  final int? dayOfWeek;
  final String? summary;
  final ValueChanged<String> onChangedName;
  final ValueChanged<Map<String, int>> onSelectDate;
  final ValueChanged<String> onChangedSummary;

  const ShowsFormWidget({
    super.key,
    this.name = '',
    this.year,
    this.week,
    this.dayOfWeek,
    this.summary = '',
    required this.onChangedName,
    required this.onSelectDate,
    required this.onChangedSummary,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildName(),
          const SizedBox(height: 12),
          _buildDate(context),
          const SizedBox(height: 12),
          _buildSummary(),
        ],
      ),
    ),
  );

  Widget _buildName() => TextFormField(
    textCapitalization: TextCapitalization.sentences,
    initialValue: name,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    decoration: const InputDecoration(
      labelText: 'Name',
      border: OutlineInputBorder(),
    ),
    validator: (value) =>
        value == null || value.trim().isEmpty ? "The show's name can't be empty" : null,
    onChanged: onChangedName,
  );

  Widget _buildDate(BuildContext context) {
    final hasDate = year != null && week != null && dayOfWeek != null;
    final dateText = hasDate
        ? 'Year $year • Week $week • ${_dayName(dayOfWeek!)}'
        : 'Select a WWE date';

    return InkWell(
      onTap: () async {
        final date = await showDialog<Map<String, int>>(
          context: context,
          builder: (_) => WweDateDialog(
            title: 'Select show date',
            initialYear: year,
            initialWeek: week,
            initialDay: dayOfWeek ?? 1,
          ),
        );
        if (date != null) onSelectDate(date);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'WWE date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_month),
        ),
        child: Text(
          dateText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: hasDate ? null : Colors.white54,
          ),
        ),
      ),
    );
  }

  String _dayName(int day) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return day >= 1 && day <= 7 ? names[day - 1] : 'Unknown day';
  }

  Widget _buildSummary() => TextFormField(
    textCapitalization: TextCapitalization.sentences,
    maxLines: null,
    minLines: 3,
    initialValue: summary,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    decoration: const InputDecoration(
      labelText: 'Summary',
      border: OutlineInputBorder(),
      alignLabelWithHint: true,
    ),
    onChanged: onChangedSummary,
  );
}
