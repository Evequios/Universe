import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';

enum _Impact { minor, major, shocking }
enum _Category { superstars, teams, championships, brands, shows }

class _GeneratedEvent {
  final String title;
  final String description;
  final _Impact impact;
  final _Category category;
  final DateTime createdAt;
  bool accepted;
  bool ignored = false;

  _GeneratedEvent({required this.title, required this.description, required this.impact,
    required this.category, required this.createdAt, this.accepted = false});
}

class RandomEventsPage extends StatefulWidget {
  const RandomEventsPage({super.key});
  @override
  State<RandomEventsPage> createState() => _RandomEventsPageState();
}

class _RandomEventsPageState extends State<RandomEventsPage> {
  final Set<_Category> _categories = _Category.values.toSet();
  final List<_GeneratedEvent> _history = [];
  _Impact? _selectedImpact;
  _Impact? _historyFilter;
  bool _loading = true;
  String? _error;
  List<Superstars> _superstars = [];
  List<Teams> _teams = [];
  List<Titles> _titles = [];
  List<Brands> _brands = [];
  List<Show> _shows = [];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final values = await Future.wait([
        SuperstarsDatabaseHelper.readAllSuperstars(), TeamsDatabaseHelper.readAllTeams(),
        TitlesDatabaseHelper.readAllTitles(), BrandsDatabaseHelper.readAllBrands(),
        ShowsDatabaseHelper.readAllShows(),
      ]);
      if (!mounted) return;
      setState(() {
        _superstars = values[0] as List<Superstars>;
        _teams = values[1] as List<Teams>;
        _titles = values[2] as List<Titles>;
        _brands = values[3] as List<Brands>;
        _shows = values[4] as List<Show>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  T _pick<T>(List<T> values) => values[Random().nextInt(values.length)];
  String _name(Superstars? value) => value?.name ?? 'a Superstar';

  _GeneratedEvent? _createEvent(_Category category, _Impact impact) {
    final r = Random();
    final level = impact;
    String title;
    String description;
    switch (category) {
      case _Category.superstars:
        if (_superstars.isEmpty) return null;
        final a = _pick(_superstars);
        final others = _superstars.where((s) => s.id != a.id).toList();
        final b = others.isEmpty ? a : _pick(others);
        final options = <List<String>>[
          ['Unexpected alliance', '${a.name} proposes an unlikely alliance to ${b.name}.'],
          ['Backstage confrontation', '${a.name} confronts ${b.name} backstage, escalating tensions between the two Superstars.'],
          ['Demand for opportunity', '${a.name} publicly demands a major opportunity and puts the locker room on notice.'],
          ['Shocking betrayal', '${a.name} turns on ${b.name} at the worst possible moment.'],
          ['Surprise return', '${a.name} makes an unexpected return and immediately targets ${b.name}.'],
          ['Momentum shift', '${a.name} scores a statement victory that could change their position in the division.'],
          ['Injury scare', '${a.name} is involved in an incident that leaves their status for the next show uncertain.'],
        ];
        final selected = _pick(options); title = selected[0]; description = selected[1];
        break;
      case _Category.teams:
        if (_teams.isEmpty) return null;
        final team = _pick(_teams);
        final options = <List<String>>[
          ['Tag team tension', '${team.name} suffer a disagreement that threatens their partnership.'],
          ['Open challenge', '${team.name} issue an open challenge to any team willing to face them.'],
          ['Unexpected reunion', '${team.name} reunite for one night to settle unfinished business.'],
          ['Team under pressure', '${team.name} are told that another poor performance could cost them their place in the title picture.'],
          ['Betrayal in the making', 'One member of ${team.name} appears to be negotiating opportunities behind the other members’ backs.'],
        ];
        final selected = _pick(options); title = selected[0]; description = selected[1];
        break;
      case _Category.championships:
        if (_titles.isEmpty) return null;
        final belt = _pick(_titles);
        final champion = belt.holder1 == null ? 'the champion' : _name(belt.holder1);
        final options = <List<String>>[
          ['Title opportunity', 'A contender steps forward to challenge $champion for the ${belt.name}.'],
          ['Championship controversy', 'A disputed decision involving the ${belt.name} puts the championship scene in turmoil.'],
          ['Champion’s ultimatum', '$champion demands that the next challenger prove they deserve a shot at the ${belt.name}.'],
          ['Title defended unexpectedly', '$champion is challenged to defend the ${belt.name} sooner than expected.'],
          ['Vacant title shock', 'An unexpected situation puts the future of the ${belt.name} in doubt.'],
        ];
        final selected = _pick(options); title = selected[0]; description = selected[1];
        break;
      case _Category.brands:
        if (_brands.isEmpty) return null;
        final brand = _pick(_brands);
        final options = <List<String>>[
          ['Brand invasion', '${brand.name} Superstars appear on another Brand’s show and make their intentions clear.'],
          ['Roster shake-up', '${brand.name} management announces that major roster changes are being considered.'],
          ['Brand competition', '${brand.name} is challenged to prove its superiority in an inter-brand contest.'],
          ['Management decision', '${brand.name} management introduces a new rule that will affect the entire roster.'],
          ['Locker room unrest', 'Several members of ${brand.name} are unhappy with how opportunities are being distributed.'],
        ];
        final selected = _pick(options); title = selected[0]; description = selected[1];
        break;
      case _Category.shows:
        if (_shows.isEmpty) return null;
        final show = _pick(_shows);
        final options = <List<String>>[
          ['Main event change', 'The main event of ${show.name} is changed at the last minute following an unexpected development.'],
          ['Surprise appearance', 'A surprise Superstar appearance steals the spotlight on ${show.name}.'],
          ['Unscheduled match', 'An unscheduled match is added to the card of ${show.name}.'],
          ['Show disruption', 'A backstage incident threatens to disrupt the running order of ${show.name}.'],
          ['High-stakes announcement', 'A major announcement on ${show.name} changes the direction of the coming weeks.'],
        ];
        final selected = _pick(options); title = selected[0]; description = selected[1];
        break;
    }
    if (impact == _Impact.major && r.nextBool()) description = '$description The consequences will be felt across the next few shows.';
    if (impact == _Impact.shocking) description = '$description The entire Universe is left stunned, and the fallout could reshape the landscape.';
    return _GeneratedEvent(title: title, description: description, impact: level, category: category, createdAt: DateTime.now());
  }

  void _generate() {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one event category.')));
      return;
    }
    final available = _categories.where((c) => _hasData(c)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('There is no data available for the selected categories.')));
      return;
    }
    final category = _pick(available);
    final _Impact impact = _selectedImpact ?? _pick<_Impact>(_Impact.values);
    final event = _createEvent(category, impact);
    if (event == null) return;
    setState(() => _history.insert(0, event));
  }

  bool _hasData(_Category c) {
    switch (c) {
      case _Category.superstars:
        return _superstars.isNotEmpty;
      case _Category.teams:
        return _teams.isNotEmpty;
      case _Category.championships:
        return _titles.isNotEmpty;
      case _Category.brands:
        return _brands.isNotEmpty;
      case _Category.shows:
        return _shows.isNotEmpty;
    }
  }

  String _categoryLabel(_Category c) {
    switch (c) {
      case _Category.superstars: return 'Superstars';
      case _Category.teams: return 'Teams';
      case _Category.championships: return 'Championships';
      case _Category.brands: return 'Brands';
      case _Category.shows: return 'Shows';
    }
  }

  String _impactLabel(_Impact i) {
    switch (i) {
      case _Impact.minor: return 'Minor';
      case _Impact.major: return 'Major';
      case _Impact.shocking: return 'Shocking';
    }
  }

  Color _impactColor(_Impact i) {
    switch (i) {
      case _Impact.minor: return Colors.blueGrey;
      case _Impact.major: return Colors.orange;
      case _Impact.shocking: return const Color(0xFFE11D2E);
    }
  }

  IconData _categoryIcon(_Category c) {
    switch (c) {
      case _Category.superstars: return Icons.person;
      case _Category.teams: return Icons.groups;
      case _Category.championships: return Icons.workspace_premium;
      case _Category.brands: return Icons.flag;
      case _Category.shows: return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleHistory = _historyFilter == null ? _history : _history.where((e) => e.impact == _historyFilter).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Random Events'), actions: [
        if (_history.isNotEmpty) IconButton(tooltip: 'Clear history', onPressed: () => setState(_history.clear), icon: const Icon(Icons.delete_outline)),
      ]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null
        ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 42), const SizedBox(height: 12), const Text('Unable to load Universe data'), Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton(onPressed: _loadData, child: const Text('Retry'))])))
        : ListView(padding: const EdgeInsets.all(16), children: [
          _buildIntro(), const SizedBox(height: 18), _buildCategorySelector(), const SizedBox(height: 16),
          _buildImpactSelector(), const SizedBox(height: 18),
          SizedBox(height: 52, child: FilledButton.icon(onPressed: _generate, icon: const Icon(Icons.casino_outlined), label: const Text('Generate random event'))),
          const SizedBox(height: 24),
          Row(children: [Expanded(child: Text('Session history (${_history.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))), DropdownButton<_Impact?>(value: _historyFilter, underline: const SizedBox(), hint: const Text('All impacts'), items: [const DropdownMenuItem(value: null, child: Text('All impacts')), ..._Impact.values.map((i) => DropdownMenuItem(value: i, child: Text(_impactLabel(i))))], onChanged: (v) => setState(() => _historyFilter = v))]),
          const SizedBox(height: 8),
          if (visibleHistory.isEmpty) _emptyHistory() else ...visibleHistory.map(_eventCard),
        ]),
    );
  }

  Widget _buildIntro() => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF211A1C), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF49242A))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Shake up your Universe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), SizedBox(height: 7), Text('Generate unexpected booking twists using the Superstars, Teams, Championships, Brands and Shows already in your Universe. Every event is a suggestion — nothing is saved automatically.', style: TextStyle(color: Colors.white70, height: 1.4))]));

  Widget _buildCategorySelector() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Event categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 9), Wrap(spacing: 8, runSpacing: 8, children: _Category.values.map((c) => FilterChip(avatar: Icon(_categoryIcon(c), size: 17), label: Text(_categoryLabel(c)), selected: _categories.contains(c), onSelected: (v) => setState(() => v ? _categories.add(c) : _categories.remove(c)))).toList())]);

  Widget _buildImpactSelector() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Impact level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 9), SegmentedButton<_Impact?>(segments: const [ButtonSegment(value: null, label: Text('Random'), icon: Icon(Icons.shuffle)), ButtonSegment(value: _Impact.minor, label: Text('Minor')), ButtonSegment(value: _Impact.major, label: Text('Major')), ButtonSegment(value: _Impact.shocking, label: Text('Shocking'))], selected: {_selectedImpact}, onSelectionChanged: (s) => setState(() => _selectedImpact = s.first))]);

  Widget _eventCard(_GeneratedEvent event) => Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(_categoryIcon(event.category), size: 18, color: Colors.white70), const SizedBox(width: 7), Text(_categoryLabel(event.category), style: const TextStyle(color: Colors.white70, fontSize: 12)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: _impactColor(event.impact).withOpacity(.16), borderRadius: BorderRadius.circular(20)), child: Text(_impactLabel(event.impact).toUpperCase(), style: TextStyle(color: _impactColor(event.impact), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: .6)))]), const SizedBox(height: 11), Text(event.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 7), Text(event.description, style: const TextStyle(height: 1.4)), const SizedBox(height: 12), Row(children: [if (event.accepted) const Chip(avatar: Icon(Icons.check_circle, size: 16), label: Text('Accepted'), visualDensity: VisualDensity.compact) else if (event.ignored) const Chip(avatar: Icon(Icons.do_not_disturb_on, size: 16), label: Text('Ignored'), visualDensity: VisualDensity.compact) else ...[TextButton.icon(onPressed: () => setState(() { event.accepted = true; event.ignored = false; }), icon: const Icon(Icons.check, size: 17), label: const Text('Accept')), TextButton.icon(onPressed: () => setState(() { event.ignored = true; event.accepted = false; }), icon: const Icon(Icons.close, size: 17), label: const Text('Ignore'))], const Spacer(), IconButton(tooltip: 'Copy event', onPressed: () { Clipboard.setData(ClipboardData(text: '${event.title}\n${event.description}\nImpact: ${_impactLabel(event.impact)}')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event copied.'))); }, icon: const Icon(Icons.copy_outlined)), IconButton(tooltip: 'Remove from history', onPressed: () => setState(() => _history.remove(event)), icon: const Icon(Icons.close))])])));

  Widget _emptyHistory() => Padding(padding: const EdgeInsets.symmetric(vertical: 35), child: Column(children: [Icon(Icons.casino_outlined, size: 42, color: Colors.white.withOpacity(.35)), const SizedBox(height: 10), const Text('No events generated yet', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 5), const Text('Your generated events will appear here.', style: TextStyle(color: Colors.white54))]));
}
