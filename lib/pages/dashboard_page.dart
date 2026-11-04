import 'package:flutter/material.dart';
import 'package:wwe_universe/navbar.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/reigns.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/database/reings_database_helper.dart';
import 'package:wwe_universe/database/storylines_database_helper.dart';
import 'package:wwe_universe/pages/Shows/shows_detail_page.dart';
import 'package:wwe_universe/pages/Shows/add_edit_shows_page.dart';
import 'package:wwe_universe/pages/Matches/add_edit_matches_page.dart';
import 'package:wwe_universe/pages/Titles/titles_detail_page.dart';
import 'package:wwe_universe/pages/Storylines/storylines_detail_page.dart';
import 'package:wwe_universe/pages/Storylines/add_edit_storylines_page.dart';
import 'package:wwe_universe/pages/Storylines/storylines_page.dart';
import 'package:wwe_universe/pages/Titles/titles_page.dart';
import 'package:wwe_universe/pages/Matches/matches_detail_page.dart';
import 'package:wwe_universe/pages/Superstars/superstars_page.dart';
import 'package:wwe_universe/pages/Shows/shows_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  String? _error;
  List<Show> _shows = [];
  List<MatchRecord> _recentMatches = [];
  List<Titles> _titles = [];
  final Map<int, Reigns?> _currentReigns = {};
  List<Storylines> _storylines = [];

  int _dateKey(Show s) => s.year * 336 + (s.week - 1) * 7 + s.dayOfWeek;

  List<Show> get _upcomingShows {
    final completed = _shows.where((s) => s.isCompleted).toList()
      ..sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
    final lastCompleted = completed.isEmpty ? null : _dateKey(completed.last);
    final upcoming = _shows.where((s) => !s.isCompleted &&
        (lastCompleted == null || _dateKey(s) > lastCompleted)).toList()
      ..sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
    if (upcoming.isNotEmpty) return upcoming;
    return _shows.where((s) => !s.isCompleted).toList()
      ..sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
  }

  Show? get _nextShow => _upcomingShows.isEmpty ? null : _upcomingShows.first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ShowsDatabaseHelper.readAllShows(),
        TitlesDatabaseHelper.readAllTitles(),
        StorylinesDatabaseHelper.readAllStorylines(),
      ]);
      final shows = results[0] as List<Show>;
      final titles = results[1] as List<Titles>;
      final storylines = results[2] as List<Storylines>;
      final completed = shows.where((s) => s.isCompleted).toList()
        ..sort((a, b) => _dateKey(b).compareTo(_dateKey(a)));
      final recent = <MatchRecord>[];
      for (final show in completed.take(8)) {
        if (show.id == null) continue;
        final matches = await MatchesDatabaseHelper.readAllMatches(show.id!);
        recent.addAll(matches.reversed.where((m) => m.resultStatus != MatchResultStatus.pending));
        if (recent.length >= 6) break;
      }
      // Load current reigns concurrently instead of issuing one awaited query
      // after another. This keeps the dashboard responsive with a large title list.
      final reignEntries = await Future.wait(
        titles.where((title) => title.id != null).map((title) async {
          final id = title.id!;
          final reign = await ReignsDatabaseHelper.readCurrentReign(id);
          return MapEntry<int, Reigns?>(id, reign);
        }),
      );
      final currentReigns = Map<int, Reigns?>.fromEntries(reignEntries);
      if (!mounted) return;
      setState(() {
        _shows = shows;
        _titles = titles;
        _storylines = storylines.where((s) => s.status == StorylineStatus.ongoing).toList();
        _recentMatches = recent.take(3).toList();
        _currentReigns
          ..clear()
          ..addAll(currentReigns);
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _date(Show s) => 'Year ${s.year} · Week ${s.week} · Day ${s.dayOfWeek}';
  String _matchParticipants(MatchRecord m) => m.allParticipants.map((p) => p.superstarName).join(' · ');
  String _result(MatchRecord m) {
    if (m.resultStatus == MatchResultStatus.draw) return 'Draw';
    if (m.resultStatus == MatchResultStatus.noContest) return 'No contest';
    if (m.winnerName?.isNotEmpty == true) return '${m.winnerName} wins';
    if (m.winnerSideOrder != null) {
      final side = m.sides.where((s) => s.sideOrder == m.winnerSideOrder);
      if (side.isNotEmpty) return '${side.first.name} wins';
    }
    return 'Result recorded';
  }

  Future<void> _openShow(Show show) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ShowsDetailPage(showId: show.id!)));
    _load();
  }

  Future<void> _openCreateShow() async {
    final reference = _nextShow ?? (_shows.isNotEmpty ? _shows.last : null);
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditShowsPage(
      initialYear: reference?.year ?? 1,
      initialWeek: reference?.week ?? 1,
      initialDayOfWeek: reference?.dayOfWeek ?? 1,
    )));
    _load();
  }

  Future<void> _openCreateMatch() async {
    final show = _nextShow;
    if (show == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create a Show first to add a match to it.')));
      return;
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditMatchesPage(show: show)));
    _load();
  }

  Future<void> _openCreateStoryline() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditStorylinesPage()));
    _load();
  }

  Widget _sectionTitle(String title, {String? trailing, VoidCallback? onTap}) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
    child: Row(children: [
      Expanded(child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 1.35, fontWeight: FontWeight.w900, color: Color(0xFFFF6672)))),
      if (trailing != null) TextButton(onPressed: onTap, child: Text(trailing)),
    ]),
  );

  Widget _empty(String text, {IconData icon = Icons.inbox_outlined}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(children: [Icon(icon, color: Colors.white30), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(color: Colors.white54))) ]),
  );

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(14)}) => Card(
    margin: EdgeInsets.zero,
    child: Padding(padding: padding, child: child),
  );

  Widget _nextShowCard() {
    final upcoming = _upcomingShows.take(3).toList();
    final next = upcoming.isEmpty ? null : upcoming.first;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF54151D), Color(0xFF241216), Color(0xFF19191F)],
        ),
        border: Border.all(color: const Color(0xFF79313A), width: 0.8),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 7)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFFFF8790), size: 19),
              const SizedBox(width: 7),
              const Expanded(
                child: Text('ROAD TO THE NEXT SHOW', style: TextStyle(
                  color: Color(0xFFFFA0A7), fontSize: 11,
                  fontWeight: FontWeight.w900, letterSpacing: 1.25,
                )),
              ),
              if (upcoming.length > 1)
                Text('${upcoming.length} UPCOMING', style: const TextStyle(
                  color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w800,
                )),
            ]),
            const SizedBox(height: 14),
            if (next == null) ...[
              const Text('No scheduled Shows', style: TextStyle(
                color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900,
              )),
              const SizedBox(height: 6),
              const Text('Plan the next event in your Universe.',
                style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: _openCreateShow,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Show'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD71920)),
                ),
              ),
            ] else ...[
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openShow(next),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(next.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(_date(next), style: const TextStyle(
                          color: Color(0xFFFFB8BD), fontWeight: FontWeight.w700,
                        )),
                      ],
                    )),
                    const SizedBox(width: 12),
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD71920),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 25),
                    ),
                  ]),
                ),
              ),
              if (upcoming.length > 1) ...[
                const SizedBox(height: 14),
                const Divider(color: Color(0x55FFFFFF), height: 1),
                const SizedBox(height: 7),
                ...upcoming.skip(1).map((show) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(show.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: Text(_date(show), style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () => _openShow(show),
                )),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _overviewStats() {
    final completedShows = _shows.where((show) => show.isCompleted).length;
    final upcomingShows = _upcomingShows.length;
    final activeChampions = _currentReigns.values.where((reign) => reign != null).length;
    final activeStorylines = _storylines.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: [
        _statCard('COMPLETED SHOWS', completedShows, Icons.task_alt_rounded, const Color(0xFF75C995)),
        _statCard('UPCOMING SHOWS', upcomingShows, Icons.event_available_rounded, const Color(0xFFFF8790)),
        _statCard('CHAMPIONS', activeChampions, Icons.workspace_premium_rounded, const Color(0xFFF1C66D)),
        _statCard('ACTIVE STORYLINES', activeStorylines, Icons.account_tree_rounded, const Color(0xFF8AB4F8)),
      ],
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: const Color(0xFF1B1B22),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFF30303A)),
    ),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: accent.withOpacity(0.13), borderRadius: BorderRadius.circular(11)),
        child: Icon(icon, color: accent, size: 19),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 1),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.45)),
        ],
      )),
    ]),
  );

  Widget _quickActions() => _card(child: Wrap(spacing: 9, runSpacing: 9, children: [
    _action(Icons.event_available, 'New Show', _openCreateShow),
    _action(Icons.sports_mma_outlined, 'New Match', _openCreateMatch),
    _action(Icons.account_tree_outlined, 'Storyline', _openCreateStoryline),
    _action(Icons.groups_outlined, 'Superstars', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperstarsPage()))),
    _action(Icons.event_note_outlined, 'Calendar', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShowsPage()))),
  ]));

  Widget _action(IconData icon, String label, VoidCallback callback) => OutlinedButton.icon(
    onPressed: callback,
    icon: Icon(icon, size: 17),
    label: Text(label),
    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF383841)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
  );

  Widget _recentResults() => _card(child: _recentMatches.isEmpty ? _empty('No results recorded yet.', icon: Icons.sports_mma_outlined) : Column(children: _recentMatches.take(3).map((m) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const CircleAvatar(backgroundColor: Color(0xFF35171D), child: Icon(Icons.sports_mma, color: Color(0xFFFF6672))),
    title: Text(m.formatName.isNotEmpty ? m.formatName : 'Match', style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text('${m.show.name} · ${_date(m.show)}\n${_matchParticipants(m)}\n${_result(m)}', maxLines: 4, overflow: TextOverflow.ellipsis),
    isThreeLine: true,
    trailing: m.titleChange ? const Icon(Icons.workspace_premium, color: Color(0xFFF5C451)) : null,
    onTap: m.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchesDetailPage(matchId: m.id!, showId: m.show.id!))),
  )).toList()));

  Widget _champions() {
    final active = _titles.where((t) => t.id != null && _currentReigns[t.id!] != null).toList();
    return _card(child: active.isEmpty ? _empty('No active reigns.', icon: Icons.workspace_premium_outlined) : Column(children: active.take(3).map((title) {
      final reign = _currentReigns[title.id!]!;
      final holders = [reign.holder1Name, if (reign.holder2Name?.isNotEmpty == true) reign.holder2Name!].join(' & ');
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(backgroundColor: Color(0xFF302719), child: Icon(Icons.workspace_premium, color: Color(0xFFF5C451))),
        title: Text(title.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$holders · Since Year ${reign.yearStart} • Week ${reign.weekStart} • Day ${reign.dayStart}'),
        onTap: title.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => TitlesDetailPage(titleId: title.id!))),
      );
    }).toList()));
  }

  Widget _activeStorylines() => _card(child: _storylines.isEmpty ? _empty('No active storylines.', icon: Icons.account_tree_outlined) : Column(children: _storylines.take(3).map((s) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const CircleAvatar(backgroundColor: Color(0xFF202A38), child: Icon(Icons.account_tree, color: Color(0xFF8AB4F8))),
    title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text('Since Year ${s.yearStart} · Week ${s.start} · Day ${s.dayStart}'),
    onTap: s.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => StorylinesDetailPage(storylineId: s.id!))),
  )).toList()));

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(title: const Text('Dashboard'), actions: [IconButton(tooltip: 'Refresh', onPressed: _load, icon: const Icon(Icons.refresh))]),
    body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null
      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 40, color: Colors.redAccent), const SizedBox(height: 12), const Text('Unable to load dashboard'), const SizedBox(height: 8), Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)), const SizedBox(height: 16), FilledButton(onPressed: _load, child: const Text('Retry'))])))
      : RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 32), children: [
          _nextShowCard(),
          _sectionTitle('Overview'),
          _overviewStats(),
          _sectionTitle('Quick Actions'),
          _quickActions(),
          _sectionTitle('Recent Results', trailing: 'View Shows', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShowsPage()))),
          _recentResults(),
          _sectionTitle('Current Champions', trailing: 'All Titles', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TitlesPage()))),
          _champions(),
          _sectionTitle('Active Storylines', trailing: 'View All', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorylinesPage()))),
          _activeStorylines(),
        ])),
  );
}
