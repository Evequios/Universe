import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/classes/storyline_event.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/storyline_relations_database_helper.dart';
import 'package:wwe_universe/pages/Matches/matches_detail_page.dart';
import 'package:wwe_universe/pages/News/news_detail_page.dart';
import 'package:wwe_universe/database/storylines_database_helper.dart';
import 'package:wwe_universe/database/storyline_participants_database_helper.dart';
import 'package:wwe_universe/database/storyline_events_database_helper.dart';
import 'package:wwe_universe/pages/Storylines/add_edit_storylines_page.dart';

class StorylinesDetailPage extends StatefulWidget {
  final int storylineId;
  const StorylinesDetailPage({super.key, required this.storylineId});
  @override
  State<StorylinesDetailPage> createState() => _StorylinesDetailPageState();
}

class _StorylinesDetailPageState extends State<StorylinesDetailPage> {
  Storylines? _storyline;
  StorylineParticipants _participants = const StorylineParticipants();
  List<StorylineEvent> _events = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        StorylinesDatabaseHelper.readStoryline(widget.storylineId),
        StorylineParticipantsDatabaseHelper.read(widget.storylineId),
        StorylineEventsDatabaseHelper.readAll(widget.storylineId),
      ]);
      if (!mounted) return;
      setState(() {
        _storyline = results[0] as Storylines;
        _participants = results[1] as StorylineParticipants;
        _events = results[2] as List<StorylineEvent>;
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101010),
    appBar: AppBar(backgroundColor: const Color(0xFF101010), foregroundColor: Colors.white, title: const Text('Détails storyline'), actions: [
      if (_storyline != null) IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _edit),
      if (_storyline != null) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _confirmDelete),
    ]),
    floatingActionButton: _storyline == null || _loading ? null : FloatingActionButton.extended(
      onPressed: _chooseEventType, icon: const Icon(Icons.add), label: const Text('Ajouter à la chronologie')),
    body: _loading ? const Center(child: CircularProgressIndicator()) : _storyline == null
      ? const Center(child: Text('Storyline introuvable.')) : _content(_storyline!),
  );

  Widget _content(Storylines s) => ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), children: [
    Text(s.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
    const SizedBox(height: 10),
    Align(alignment: Alignment.centerLeft, child: Chip(label: Text(StorylineStatus.label(s.status)))),
    const SizedBox(height: 12),
    _section('PÉRIODE WWE', '${s.yearStart} · Semaine ${s.start}${s.end == 0 ? '  →  En cours / non définie' : '\n${s.yearEnd} · Semaine ${s.end}'}'),
    const SizedBox(height: 16),
    _section('DESCRIPTION', s.text),
    const SizedBox(height: 16),
    _section('SUPERSTARS', _participants.superstars.isEmpty ? 'Aucune superstar associée' : _participants.superstars.map((e) => e.name).join(' · ')),
    const SizedBox(height: 16),
    _section('ÉQUIPES', _participants.teams.isEmpty ? 'Aucune équipe associée' : _participants.teams.map((e) => e.name).join(' · ')),
    const SizedBox(height: 24),
    Row(children: [const Expanded(child: Text('CHRONOLOGIE', style: TextStyle(color: Color(0xFFD71920), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2))), Text('${_events.length} événement(s)', style: Theme.of(context).textTheme.bodySmall)]),
    const SizedBox(height: 10),
    if (_events.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Aucun événement pour le moment. Ajoute les segments importants de cette storyline.'))
    else ..._groupedTimeline(),
  ]);

  List<Widget> _groupedTimeline() {
    final groups = <String, List<StorylineEvent>>{};
    for (final event in _events) {
      final key = '${event.year} · Semaine ${event.week}';
      groups.putIfAbsent(key, () => []).add(event);
    }
    return groups.entries.expand((entry) => <Widget>[
      Padding(padding: const EdgeInsets.only(top: 14, bottom: 8), child: Text(entry.key.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.0))),
      ...entry.value.map(_eventTile),
    ]).toList();
  }

  Widget _eventTile(StorylineEvent event) => Dismissible(
    key: ValueKey(event.id), direction: DismissDirection.endToStart,
    background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
    confirmDismiss: (_) async => await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Supprimer cet événement ?'), content: Text(event.title),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer'))])) ?? false,
    onDismissed: (_) async { await StorylineEventsDatabaseHelper.delete(event.id!); _load(); },
    child: Card(color: const Color(0xFF1B1B1B), margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF383838))), child: ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFFD71920).withOpacity(.15), child: Icon(_eventIcon(event.type), color: const Color(0xFFD71920))),
      title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${_dayLabel(event.dayOfWeek)} · ${event.year} · Semaine ${event.week}${event.description.isEmpty ? '' : '\n${event.description}'}'),
      isThreeLine: event.description.isNotEmpty,
      onTap: () => _openEvent(event),
      trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: event.type == StorylineEventType.segment ? () => _editEvent(event) : null),
    )),
  );

  String _dayLabel(int day) => const ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'][(day.clamp(1, 7) as int) - 1];

  Widget _section(String title, String body) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF1B1B1B), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF383838))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Color(0xFFD71920), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      const SizedBox(height: 10), Text(body, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45)),
    ]));

  IconData _eventIcon(String type) {
    switch (type) {
      case StorylineEventType.match: return Icons.sports_mma;
      case StorylineEventType.news: return Icons.newspaper_outlined;
      default: return Icons.mic_none;
    }
  }

  Future<void> _chooseEventType() async {
    final choice = await showModalBottomSheet<String>(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.mic_none), title: const Text('Ajouter un segment'), onTap: () => Navigator.pop(ctx, 'segment')),
      ListTile(leading: const Icon(Icons.sports_mma), title: const Text('Associer un match existant'), onTap: () => Navigator.pop(ctx, 'match')),
    ])));
    if (choice == 'segment') await _editEvent(null);
    if (choice == 'match') await _addMatchEvent();
  }

  Future<void> _addMatchEvent() async {
    final shows = await ShowsDatabaseHelper.readAllShows();
    if (!mounted) return;
    if (shows.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun show disponible.'))); return; }
    final show = await showDialog<Show>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Choisir un show'), content: SizedBox(width: 420, child: ListView(shrinkWrap: true, children: shows.map((s) => ListTile(title: Text(s.name), subtitle: Text('${s.year} · Semaine ${s.week}'), onTap: () => Navigator.pop(ctx, s))).toList())),
    ));
    if (show == null || show.id == null || !mounted) return;
    final allMatches = await MatchesDatabaseHelper.readAllMatches(show.id!);
    final linkedMatchIds = (await StorylineRelationsDatabaseHelper.readMatchIds(widget.storylineId)).toSet();
    final matches = allMatches.where((match) => match.id == null || !linkedMatchIds.contains(match.id)).toList();
    if (!mounted) return;
    if (matches.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun match dans ce show.'))); return; }
    final match = await showDialog<MatchRecord>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Matchs – ${show.name}'), content: SizedBox(width: 420, child: ListView(shrinkWrap: true, children: matches.map((m) => ListTile(title: Text(m.formatName), subtitle: Text([m.matchTypeName, m.stipulationName].where((v) => v.trim().isNotEmpty).join(' · ')), onTap: () => Navigator.pop(ctx, m))).toList())),
    ));
    if (match == null || match.id == null) return;
    final event = StorylineEvent(storylineId: widget.storylineId, type: StorylineEventType.match,
      title: match.formatName, description: '${show.name} · ${match.resultStatus}', year: show.year,
      week: show.week, dayOfWeek: show.dayOfWeek, position: _events.length, matchId: match.id);
    await StorylineEventsDatabaseHelper.create(event);
    await StorylineRelationsDatabaseHelper.linkMatch(storylineId: widget.storylineId, matchId: match.id!, position: _events.length);
    await _load();
  }

  Future<void> _openEvent(StorylineEvent event) async {
    if (event.type == StorylineEventType.match && event.matchId != null) {
      try {
        final match = await MatchesDatabaseHelper.readMatch(event.matchId!);
        if (!mounted) return;
        await Navigator.push(context, MaterialPageRoute(builder: (_) => MatchesDetailPage(matchId: match.id!, showId: match.show.id!)));
        await _load();
      } catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ce match n’est plus disponible.'))); }
    } else if (event.type == StorylineEventType.news && event.newsId != null) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetailPage(newsId: event.newsId!)));
      await _load();
    }
  }

  Future<void> _addEvent() => _editEvent(null);

  Future<void> _editEvent(StorylineEvent? existing) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final description = TextEditingController(text: existing?.description ?? '');
    final year = TextEditingController(text: '${existing?.year ?? _storyline!.yearStart}');
    final week = TextEditingController(text: '${existing?.week ?? _storyline!.start}');
    int day = existing?.dayOfWeek ?? 1;
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: Text(existing == null ? 'Nouveau segment' : 'Modifier le segment'),
      content: SizedBox(width: 420, child: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Titre du segment'), validator: (v) => v == null || v.trim().isEmpty ? 'Le titre est obligatoire.' : null),
        const SizedBox(height: 10),
        TextFormField(controller: description, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Description (facultative)')),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: TextFormField(controller: year, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Année'), validator: (v) => int.tryParse(v ?? '') == null || int.parse(v!) < 1 ? 'Année invalide' : null)), const SizedBox(width: 10), Expanded(child: TextFormField(controller: week, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Semaine'), validator: (v) => int.tryParse(v ?? '') == null || int.parse(v!) < 1 || int.parse(v) > 48 ? '1 à 48' : null))]),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(value: day, decoration: const InputDecoration(labelText: 'Jour'), items: List.generate(7, (i) => DropdownMenuItem(value: i + 1, child: Text(_dayLabel(i + 1)))).toList(), onChanged: (v) => setDialogState(() => day = v ?? day)),
      ])))),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')), FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true); }, child: const Text('Enregistrer'))],
    )));
    if (saved == true && mounted) {
      final event = StorylineEvent(id: existing?.id, storylineId: widget.storylineId, title: title.text.trim(), description: description.text.trim(), year: int.parse(year.text), week: int.parse(week.text), dayOfWeek: day, position: existing?.position ?? _events.length);
      if (existing == null) { await StorylineEventsDatabaseHelper.create(event); } else { await StorylineEventsDatabaseHelper.update(event); }
      await _load();
    }
    title.dispose(); description.dispose(); year.dispose(); week.dispose();
  }

  Future<void> _edit() async { await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditStorylinesPage(storyline: _storyline))); _load(); }
  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Supprimer la storyline ?'),
      content: const Text('Les associations avec ses participants et ses événements seront également supprimées. Les actualités et les matchs resteront dans l’application.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer'))]));
    if (confirm == true) { await StorylinesDatabaseHelper.deleteStoryline(widget.storylineId); if (mounted) Navigator.pop(context, true); }
  }
}
