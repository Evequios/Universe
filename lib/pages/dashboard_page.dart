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
      final currentReigns = <int, Reigns?>{};
      for (final title in titles) {
        if (title.id != null) {
          currentReigns[title.id!] = await ReignsDatabaseHelper.readCurrentReign(title.id!);
        }
      }
      if (!mounted) return;
      setState(() {
        _shows = shows;
        _titles = titles;
        _storylines = storylines.where((s) => s.status == StorylineStatus.ongoing).toList();
        _recentMatches = recent.take(6).toList();
        _currentReigns
          ..clear()
          ..addAll(currentReigns);
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _date(Show s) => 'Y${s.year} · S${s.week} · J${s.dayOfWeek}';
  String _matchParticipants(MatchRecord m) => m.allParticipants.map((p) => p.superstarName).join(' · ');
  String _result(MatchRecord m) {
    if (m.resultStatus == MatchResultStatus.draw) return 'Match nul';
    if (m.resultStatus == MatchResultStatus.noContest) return 'No contest';
    if (m.winnerName?.isNotEmpty == true) return '${m.winnerName} vainqueur';
    if (m.winnerSideOrder != null) {
      final side = m.sides.where((s) => s.sideOrder == m.winnerSideOrder);
      if (side.isNotEmpty) return '${side.first.name} vainqueur';
    }
    return 'Résultat enregistré';
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crée d’abord un Show pour pouvoir y ajouter un match.')));
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
    return _card(child: upcoming.isEmpty
      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Aucun show à venir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Planifie ton prochain événement pour commencer.'), const SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: FilledButton.icon(onPressed: _openCreateShow, icon: const Icon(Icons.add), label: const Text('Créer un show')))])
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.upcoming_rounded, color: Color(0xFFFF6672)), SizedBox(width: 8), Text('PROCHAINS SHOWS', style: TextStyle(color: Color(0xFFFF6672), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2))]),
          const SizedBox(height: 8),
          ...upcoming.asMap().entries.map((entry) {
            final show = entry.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: entry.key == 0 ? const Color(0xFF35171D) : const Color(0xFF25252D),
                child: Text('${entry.key + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              title: Text(show.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              subtitle: Text(_date(show)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () => _openShow(show),
            );
          }),
        ]));
  }

  Widget _quickActions() => _card(child: Wrap(spacing: 9, runSpacing: 9, children: [
    _action(Icons.event_available, 'Nouveau show', _openCreateShow),
    _action(Icons.sports_mma_outlined, 'Nouveau match', _openCreateMatch),
    _action(Icons.account_tree_outlined, 'Storyline', _openCreateStoryline),
    _action(Icons.groups_outlined, 'Superstars', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperstarsPage()))),
    _action(Icons.event_note_outlined, 'Calendrier', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShowsPage()))),
  ]));

  Widget _action(IconData icon, String label, VoidCallback callback) => OutlinedButton.icon(
    onPressed: callback,
    icon: Icon(icon, size: 17),
    label: Text(label),
    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF383841)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
  );

  Widget _recentResults() => _card(child: _recentMatches.isEmpty ? _empty('Aucun résultat enregistré pour le moment.', icon: Icons.sports_mma_outlined) : Column(children: _recentMatches.map((m) => ListTile(
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
    return _card(child: active.isEmpty ? _empty('Aucun règne en cours.', icon: Icons.workspace_premium_outlined) : Column(children: active.map((title) {
      final reign = _currentReigns[title.id!]!;
      final holders = [reign.holder1Name, if (reign.holder2Name?.isNotEmpty == true) reign.holder2Name!].join(' & ');
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(backgroundColor: Color(0xFF302719), child: Icon(Icons.workspace_premium, color: Color(0xFFF5C451))),
        title: Text(title.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$holders · Depuis Y${reign.yearStart} S${reign.weekStart} J${reign.dayStart}'),
        onTap: title.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => TitlesDetailPage(titleId: title.id!))),
      );
    }).toList()));
  }

  Widget _activeStorylines() => _card(child: _storylines.isEmpty ? _empty('Aucune storyline en cours.', icon: Icons.account_tree_outlined) : Column(children: _storylines.take(5).map((s) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const CircleAvatar(backgroundColor: Color(0xFF202A38), child: Icon(Icons.account_tree, color: Color(0xFF8AB4F8))),
    title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text('Depuis Y${s.yearStart} · S${s.start} · J${s.dayStart}'),
    onTap: s.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => StorylinesDetailPage(storylineId: s.id!))),
  )).toList()));

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(title: const Text('Dashboard'), actions: [IconButton(tooltip: 'Actualiser', onPressed: _load, icon: const Icon(Icons.refresh))]),
    body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null
      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 40, color: Colors.redAccent), const SizedBox(height: 12), const Text('Impossible de charger le dashboard'), const SizedBox(height: 8), Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)), const SizedBox(height: 16), FilledButton(onPressed: _load, child: const Text('Réessayer'))])))
      : RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
          _nextShowCard(),
          _sectionTitle('Actions rapides'),
          _quickActions(),
          _sectionTitle('Derniers résultats', trailing: 'Voir les shows', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShowsPage()))),
          _recentResults(),
          _sectionTitle('Champions en titre', trailing: 'Tous les titres', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TitlesPage()))),
          _champions(),
          _sectionTitle('Storylines actives', trailing: 'Voir tout', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorylinesPage()))),
          _activeStorylines(),
        ])),
  );
}
