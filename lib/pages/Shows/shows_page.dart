import 'package:flutter/material.dart';
import 'package:wwe_universe/navbar.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/pages/Shows/add_edit_shows_page.dart';
import 'package:wwe_universe/pages/Shows/shows_detail_page.dart';

class ShowsPage extends StatefulWidget {
  const ShowsPage({super.key});

  @override
  ShowsPageState createState() => ShowsPageState();
}

class ShowsPageState extends State<ShowsPage>
    with AutomaticKeepAliveClientMixin {
  List<Show> showsList = [];
  bool isLoading = true;
  int selectedYear = 1;
  int selectedMonth = 1;

  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> days = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    refreshShows(initializeMonth: true);
  }

  int _dateKey(Show show) =>
      show.year * 336 + (show.week - 1) * 7 + show.dayOfWeek;

  Show? _findNextShow(List<Show> shows) {
    final completed = shows.where((show) => show.isCompleted).toList();
    completed.sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
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

  Future<void> refreshShows({bool initializeMonth = false}) async {
    final shows = await ShowsDatabaseHelper.readAllShows();
    if (!mounted) return;

    shows.sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
    setState(() {
      showsList = shows;
      if (initializeMonth) {
        final reference = _findNextShow(shows) ??
            (shows.isNotEmpty ? shows.last : null);
        if (reference != null) {
          selectedYear = reference.year;
          selectedMonth = reference.month.clamp(1, 12).toInt();
        }
      }
      isLoading = false;
    });
  }

  void changeMonth(int offset) {
    setState(() {
      selectedMonth += offset;
      if (selectedMonth < 1) {
        selectedMonth = 12;
        selectedYear--;
      } else if (selectedMonth > 12) {
        selectedMonth = 1;
        selectedYear++;
      }
    });
  }

  void goToNextShow() {
    final nextShow = _findNextShow(showsList);
    if (nextShow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no upcoming show.')),
      );
      return;
    }
    setState(() {
      selectedYear = nextShow.year;
      selectedMonth = nextShow.month.clamp(1, 12).toInt();
    });
  }

  Show? get lastCompletedShow {
    final completed = showsList.where((show) => show.isCompleted).toList()
      ..sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
    return completed.isEmpty ? null : completed.last;
  }

  Future<void> openShow(Show show) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ShowsDetailPage(showId: show.id!)),
    );
    if (mounted) await refreshShows();
  }

  Future<void> editShow(Show show) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditShowsPage(show: show)),
    );
    if (mounted) await refreshShows();
  }

  Future<void> deleteShow(Show show) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text('Delete show?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${show.name}" and all its matches? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD71920)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || show.id == null || !mounted) return;
    await ShowsDatabaseHelper.deleteShow(show.id!);
    await refreshShows();
  }

  Future<void> addShow() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditShowsPage()),
    );
    if (mounted) await refreshShows();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      drawer: const Navbar(),
      appBar: AppBar(
        title: const Text('SHOWS', style: TextStyle(
          fontWeight: FontWeight.w900, letterSpacing: 2,
        )),
        centerTitle: true,
        backgroundColor: const Color(0xFF101010),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildMonthNavigation(),
                if (lastCompletedShow != null) _buildReferenceBanner(),
                buildDayHeaders(),
                Expanded(child: buildCalendar()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD71920),
        foregroundColor: Colors.white,
        onPressed: addShow,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReferenceBanner() {
    final reference = lastCompletedShow!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: Row(
        children: [
          const Icon(Icons.flag_outlined, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Last completed: ${reference.name} • Year ${reference.year} • Week ${reference.week} • Day ${reference.dayOfWeek}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          const Text('Earlier days are dimmed', style: TextStyle(
            color: Colors.white38, fontSize: 10,
          )),
        ],
      ),
    );
  }

  Widget buildMonthNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous month',
            onPressed: () => changeMonth(-1),
            icon: const Icon(Icons.chevron_left, size: 26),
            color: Colors.white,
          ),
          Expanded(
            child: Column(
              children: [
                Text(months[selectedMonth - 1].toUpperCase(), style: const TextStyle(
                  color: Colors.white, fontSize: 19,
                  fontWeight: FontWeight.w900, letterSpacing: 1.4,
                )),
                const SizedBox(height: 4),
                Text('YEAR $selectedYear', style: const TextStyle(
                  color: Color(0xFFFF7777), fontSize: 10,
                  fontWeight: FontWeight.bold, letterSpacing: 1.2,
                )),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            onPressed: () => changeMonth(1),
            icon: const Icon(Icons.chevron_right, size: 26),
            color: Colors.white,
          ),
          IconButton(
            tooltip: 'Go to next show',
            onPressed: goToNextShow,
            icon: const Icon(Icons.event_available, size: 20),
            color: const Color(0xFFFF7777),
          ),
        ],
      ),
    );
  }

  Widget buildDayHeaders() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF242424),
        border: Border(bottom: BorderSide(color: Color(0xFFD71920), width: 2)),
      ),
      child: Row(
        children: days.map((day) => Expanded(
          child: Text(day.toUpperCase(), textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFDDDDDD), fontSize: 10,
              fontWeight: FontWeight.w800, letterSpacing: 0.4,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget buildCalendar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;
        final cellHeight = (cellWidth * 1.75).clamp(86.0, 112.0);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: cellHeight,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          itemCount: 28,
          itemBuilder: (context, index) {
            final weekOfMonth = (index ~/ 7) + 1;
            final dayOfWeek = (index % 7) + 1;
            final week = ((selectedMonth - 1) * 4) + weekOfMonth;
            final dayShows = showsList.where((show) =>
              show.year == selectedYear &&
              show.week == week &&
              show.dayOfWeek == dayOfWeek
            ).toList();
            final dayKey = selectedYear * 336 + (week - 1) * 7 + dayOfWeek;
            final isBeforeReference = lastCompletedShow != null &&
                dayKey < _dateKey(lastCompletedShow!);
            return InkWell(
              onTap: () {
                if (dayShows.isEmpty) {
                  addShowForDay(week: week, dayOfWeek: dayOfWeek);
                } else {
                  showDayShows(shows: dayShows, week: week, dayOfWeek: dayOfWeek);
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: buildDayCell(
                dayNumber: index + 1,
                shows: dayShows,
                week: week,
                dayOfWeek: dayOfWeek,
                isBeforeReference: isBeforeReference,
              ),
            );
          },
        );
      },
    );
  }

  Widget buildDayCell({
    required int week,
    required int dayOfWeek,
    required int dayNumber,
    required List<Show> shows,
    required bool isBeforeReference,
  }) {
    final hasCompleted = shows.any((show) => show.isCompleted);
    final foreground = isBeforeReference ? Colors.white30 : Colors.white;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isBeforeReference
            ? const Color(0xFF111111)
            : (shows.isNotEmpty ? const Color(0xFF222222) : const Color(0xFF151515)),
        border: Border.all(
          color: isBeforeReference
              ? const Color(0xFF252525)
              : (hasCompleted ? Colors.green.shade900
                  : (shows.isNotEmpty ? const Color(0xFF8F171B) : const Color(0xFF303030))),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('$dayNumber', style: TextStyle(
                color: foreground, fontSize: 12, fontWeight: FontWeight.w900,
              ))),
              if (hasCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 11),
            ],
          ),
          if (shows.isNotEmpty) ...[
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isBeforeReference
                      ? const Color(0xFF292929)
                      : (hasCompleted ? const Color(0xFF17452B) : const Color(0xFF8F171B)),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.topLeft,
                child: Text(shows.first.name, maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isBeforeReference ? Colors.white38 : Colors.white,
                    fontSize: 10, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (shows.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: SizedBox(
                  width: double.infinity,
                  height: 18,
                  child: Text('+ ${shows.length - 1} MORE', textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isBeforeReference ? Colors.white30 : const Color(0xFFFF6B6B),
                      fontSize: 9, fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> showDayShows({
    required List<Show> shows,
    required int week,
    required int dayOfWeek,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1B1B),
      barrierColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        side: BorderSide(color: Color(0xFF383838)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${months[selectedMonth - 1]} ${((week - 1) % 4) * 7 + dayOfWeek}, Year $selectedYear',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: shows.map((show) => ListTile(
                    leading: Icon(
                      show.isCompleted ? Icons.check_circle : Icons.event,
                      color: show.isCompleted ? Colors.green : null,
                    ),
                    title: Text(show.name),
                    subtitle: Text(show.isCompleted ? 'Completed' : 'Upcoming'),
                    trailing: PopupMenuButton<String>(
                      color: const Color(0xFF292929),
                      onSelected: (value) {
                        Navigator.pop(sheetContext);
                        if (value == 'edit') {
                          editShow(show);
                        } else if (value == 'delete') {
                          deleteShow(show);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      openShow(show);
                    },
                  )).toList(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    addShowForDay(week: week, dayOfWeek: dayOfWeek);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add show'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addShowForDay({
    required int week,
    required int dayOfWeek,
  }) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddEditShowsPage(
        initialYear: selectedYear,
        initialWeek: week,
        initialDayOfWeek: dayOfWeek,
      ),
    ));
    if (mounted) await refreshShows();
  }
}
