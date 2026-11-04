import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';

/// Calendar-based show picker: empty dates are never tappable; each show is
/// an individual selectable item, including multiple shows on the same day.
class WweShowPicker extends StatefulWidget {
  final String title;
  final int? initialShowId;
  const WweShowPicker({super.key, this.title = 'Select a Show', this.initialShowId});
  @override
  State<WweShowPicker> createState() => _WweShowPickerState();
}

class _WweShowPickerState extends State<WweShowPicker> {
  static const _months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  static const _days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  List<Show> _shows = [];
  bool _loading = true;
  late int _year;
  late int _month;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final shows = await ShowsDatabaseHelper.readAllShows();
      if (!mounted) return;
      final selected = shows.where((s) => s.id == widget.initialShowId).firstOrNull;
      setState(() { _shows = shows; _year = selected?.year ?? (shows.isNotEmpty ? shows.last.year : 1); _month = selected?.month ?? (shows.isNotEmpty ? shows.last.month : 1); _loading = false; });
    } catch (_) { if (mounted) setState(() { _year = 1; _month = 1; _loading = false; }); }
  }
  void _move(int delta) => setState(() { _month += delta; if (_month < 1) { _month = 12; _year--; } else if (_month > 12) { _month = 1; _year++; } });
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(width: 440, child: _loading ? const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())) : Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [IconButton(onPressed: () => _move(-1), icon: const Icon(Icons.chevron_left)), Expanded(child: Column(children: [Text(_months[_month-1], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), Text('WWE Year $_year') ])), IconButton(onPressed: () => _move(1), icon: const Icon(Icons.chevron_right))]),
      const SizedBox(height: 8),
      Row(children: _days.map((d) => Expanded(child: Center(child: Text(d, style: Theme.of(context).textTheme.labelSmall)))).toList()),
      const SizedBox(height: 6),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 28,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 4, mainAxisSpacing: 4, mainAxisExtent: 66),
        itemBuilder: (context, index) {
          final week = (_month-1)*4 + index ~/ 7 + 1; final day = index % 7 + 1;
          final dayShows = _shows.where((s) => s.year == _year && s.week == week && s.dayOfWeek == day).toList();
          return Container(
            decoration: BoxDecoration(
              color: dayShows.isEmpty
                  ? Theme.of(context).colorScheme.surface.withOpacity(.35)
                  : const Color(0xFF292929),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: dayShows.isEmpty ? Colors.white10 : Colors.redAccent.withOpacity(.7),
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('$day', style: TextStyle(fontSize: 10, color: dayShows.isEmpty ? Colors.white38 : Colors.white)),
                ...dayShows.map((show) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Material(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => Navigator.pop(context, show),
                        child: Center(
                          child: Text(show.name, textAlign: TextAlign.center,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          );
        }),
      if (_shows.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('No shows have been created yet.')),
    ])),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL'))],
  );
}

extension _FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
