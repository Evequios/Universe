import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';

/// WWE date selector. Show labels are display-only; tapping anywhere in a
/// calendar cell selects that cell's date.
class WweDateDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final int initialDay;
  final int? initialYear;
  final int? initialWeek;

  const WweDateDialog({
    super.key,
    required this.title,
    this.confirmLabel = 'Valider',
    this.initialDay = 1,
    this.initialYear,
    this.initialWeek,
  });

  @override
  State<WweDateDialog> createState() => _WweDateDialogState();
}

class _WweDateDialogState extends State<WweDateDialog> {
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  late int _year;
  late int _month;
  late int _week;
  late int _day;
  List<Show> _shows = [];
  bool _loadingShows = true;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear ?? 1;
    _week = (widget.initialWeek ?? 1).clamp(1, 48).toInt();
    _month = ((_week - 1) ~/ 4) + 1;
    _day = widget.initialDay.clamp(1, 7).toInt();
    _loadShows();
  }

  Future<void> _loadShows() async {
    try {
      final shows = await ShowsDatabaseHelper.readAllShows();
      shows.sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
      if (!mounted) return;
      setState(() {
        _shows = shows;
        if (widget.initialYear == null && shows.isNotEmpty) {
          final reference = _findNextShow(shows) ?? shows.last;
          _year = reference.year;
          _week = reference.week;
          _day = reference.dayOfWeek;
          _month = reference.month.clamp(1, 12).toInt();
        }
        _loadingShows = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingShows = false);
    }
  }

  int _dateKey(Show show) =>
      show.year * 336 + (show.week - 1) * 7 + show.dayOfWeek;

  Show? _findNextShow(List<Show> shows) {
    final completed = shows.where((show) => show.isCompleted).toList()
      ..sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
    final lastCompletedKey = completed.isEmpty ? null : _dateKey(completed.last);

    final upcoming = shows.where((show) =>
      !show.isCompleted &&
      (lastCompletedKey == null || _dateKey(show) > lastCompletedKey)
    ).toList()
      ..sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
    if (upcoming.isNotEmpty) return upcoming.first;

    final remaining = shows.where((show) => !show.isCompleted).toList()
      ..sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
    return remaining.isEmpty ? null : remaining.first;
  }

  void _changeMonth(int offset) {
    setState(() {
      _month += offset;
      if (_month < 1) {
        _month = 12;
        _year--;
      } else if (_month > 12) {
        _month = 1;
        _year++;
      }
      _week = (_month - 1) * 4 + 1;
    });
  }

  void _selectDay(int index) {
    setState(() {
      _week = (_month - 1) * 4 + (index ~/ 7) + 1;
      _day = (index % 7) + 1;
    });
  }

  void _submit() {
    if (_year < 1 || _week < 1 || _week > 48 || _day < 1 || _day > 7) return;
    Navigator.of(context).pop(<String, int>{
      'year': _year,
      'week': _week,
      'day': _day,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(_months[_month - 1], style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold,
                      )),
                      Text('WWE Year $_year', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: _days.map((day) => Expanded(
                child: Center(child: Text(day, style: Theme.of(context).textTheme.labelSmall)),
              )).toList(),
            ),
            const SizedBox(height: 6),
            if (_loadingShows)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 28,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  mainAxisExtent: 62,
                ),
                itemBuilder: (context, index) {
                  final week = (_month - 1) * 4 + (index ~/ 7) + 1;
                  final day = (index % 7) + 1;
                  final isSelected = week == _week && day == _day;
                  final dayShows = _shows.where((show) =>
                    show.year == _year &&
                    show.week == week &&
                    show.dayOfWeek == day
                  ).toList();
                  final hasCompleted = dayShows.any((show) => show.isCompleted);

                  return InkWell(
                    onTap: () => _selectDay(index),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8F171B)
                            : (dayShows.isNotEmpty
                                ? const Color(0xFF292929)
                                : Theme.of(context).colorScheme.surface),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF7777)
                              : (hasCompleted ? Colors.green : Colors.white12),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$day', style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold,
                          )),
                          if (dayShows.isNotEmpty)
                            Expanded(
                              child: Text(
                                dayShows.map((show) => show.name).join('\n'),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 7,
                                  height: 1.1,
                                  color: hasCompleted ? Colors.greenAccent : Colors.white70,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selected: WWE Year $_year • Week $_week • Day $_day',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
