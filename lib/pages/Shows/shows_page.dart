
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
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    refreshShows(initializeYear: true);
  }

  Future<void> refreshShows({bool initializeYear = false}) async {
    final shows = await ShowsDatabaseHelper.readAllShows();

    if (!mounted) return;

    setState(() {
      showsList = shows;

      if (initializeYear && showsList.isNotEmpty) {
        selectedYear = showsList.first.year;
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

  Future<void> openShow(Show show) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShowsDetailPage(showId: show.id!),
      ),
    );

    refreshShows();
  }

  Future<void> editShow(Show show) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditShowsPage(show: show),
      ),
    );

    if (!mounted) return;
    await refreshShows();
  }

  Future<void> deleteShow(Show show) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          'Delete show?',
          style: TextStyle(color: Colors.white),
        ),
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
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD71920),
            ),
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
      MaterialPageRoute(
        builder: (context) => const AddEditShowsPage(),
      ),
    );

    refreshShows();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      drawer: const Navbar(),
      appBar: AppBar(
        title: const Text(
          'SHOWS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF101010),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Conserve ici ton body actuel.
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildMonthNavigation(),
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

  
  Widget buildMonthNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: Colors.white,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  months[selectedMonth - 1].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD71920),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'YEAR $selectedYear',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            onPressed: () => changeMonth(1),
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            color: Colors.white,
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
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD71920),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: days.map((day) {
          return Expanded(
            child: Text(
              day.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFDDDDDD),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          );
        }).toList(),
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

            final dayShows = showsList.where((show) {
              return show.year == selectedYear &&
                  show.week == week &&
                  show.dayOfWeek == dayOfWeek;
            }).toList();
            return InkWell(
              onTap: () {
                if (dayShows.isEmpty) {
                  // Journée vide : créer un show
                  addShowForDay(
                    week: week,
                    dayOfWeek: dayOfWeek,
                  );
                } else {
                  // Journée occupée : afficher les shows
                  showDayShows(
                    shows: dayShows,
                    week: week,
                    dayOfWeek: dayOfWeek,
                  );
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: buildDayCell(
                dayNumber: index + 1,
                shows: dayShows,
                week: week,
                dayOfWeek: dayOfWeek,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: shows.isNotEmpty
            ? const Color(0xFF222222)
            : const Color(0xFF151515),
        border: Border.all(
          color: shows.isNotEmpty
              ? const Color(0xFF8F171B)
              : const Color(0xFF303030),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$dayNumber',
            style: TextStyle(
              color: shows.isNotEmpty ? Colors.white : Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (shows.isNotEmpty) ...[
            const SizedBox(height: 4),
            Expanded(
              child: InkWell(
                onTap: () => openShow(shows.first),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F171B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.topLeft,
                  child: Text(
                    shows.first.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            if (shows.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: SizedBox(
                  width: double.infinity,
                  height: 20,
                  child: TextButton(
                    onPressed: () => showDayShows(
                      shows: shows,
                      week: week,
                      dayOfWeek: dayOfWeek,
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: const Color(0xFFFF6B6B),
                    ),
                    child: Text(
                      '+ ${shows.length - 1} MORE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
        side: BorderSide(
          color: Color(0xFF383838),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
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
                    children: shows.map((show) {
                      return ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(show.name),
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
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      addShowForDay(
                        week: week,
                        dayOfWeek: dayOfWeek,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add show'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> addShowForDay({
      required int week,
      required int dayOfWeek,
    }) async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddEditShowsPage(
            initialYear: selectedYear,
            initialWeek: week,
            initialDayOfWeek: dayOfWeek,
          ),
        ),
      );

      if (!mounted) return;
      await refreshShows();
    }
}
