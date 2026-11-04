import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/news.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/news_database_helper.dart';
import 'package:wwe_universe/database/storylines_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/news_associations_database_helper.dart';
import 'package:wwe_universe/widget/news_form_widget.dart';

class AddEditNewsPage extends StatefulWidget {
  final News? news;
  const AddEditNewsPage({super.key, this.news});
  @override
  AddEditNewsPageState createState() => AddEditNewsPageState();
}

class AddEditNewsPageState extends State<AddEditNewsPage> {
  final _formKey = GlobalKey<FormState>();
  late String title, text, type;
  late int year, week, dayOfWeek;
  int? storylineId;
  List<Storylines> storylines = [];
  List<Superstars> superstars = [];
  List<Teams> teams = [];
  List<Titles> titles = [];
  List<Show> shows = [];
  Map<String, Set<int>> selectedEntities = {'superstars': {}, 'teams': {}, 'titles': {}, 'shows': {}};
  bool loading = true, saving = false;

  @override
  void initState() {
    super.initState();
    final news = widget.news;
    title = news?.title ?? '';
    text = news?.text ?? '';
    type = news?.type ?? 'Announcement';
    // News dates use the in-app WWE calendar, never the Gregorian year.
    year = news?.year ?? 1;
    week = news?.week ?? 1;
    dayOfWeek = news?.dayOfWeek ?? 1;
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final values = await StorylinesDatabaseHelper.readAllStorylines();
    final loadedSuperstars = await SuperstarsDatabaseHelper.readAllSuperstars();
    final loadedTeams = await TeamsDatabaseHelper.readAllTeams();
    final loadedTitles = await TitlesDatabaseHelper.readAllTitles();
    final loadedShows = await ShowsDatabaseHelper.readAllShows();
    final linked = widget.news?.id == null ? null : await NewsDatabaseHelper.readLinkedStorylineId(widget.news!.id!);
    final associations = widget.news?.id == null ? null : await NewsAssociationsDatabaseHelper.read(widget.news!.id!);
    if (!mounted) return;
    if (widget.news == null && loadedShows.isNotEmpty) {
      loadedShows.sort((a, b) {
        final ak = a.year * 336 + (a.week - 1) * 7 + a.dayOfWeek;
        final bk = b.year * 336 + (b.week - 1) * 7 + b.dayOfWeek;
        return ak.compareTo(bk);
      });
      final completed = loadedShows.where((show) => show.isCompleted).toList();
      final lastCompletedKey = completed.isEmpty
          ? null
          : completed.map((show) => show.year * 336 + (show.week - 1) * 7 + show.dayOfWeek).reduce((a, b) => a > b ? a : b);
      final upcoming = loadedShows.where((show) {
        final key = show.year * 336 + (show.week - 1) * 7 + show.dayOfWeek;
        return !show.isCompleted && (lastCompletedKey == null || key > lastCompletedKey);
      }).toList();
      final remaining = loadedShows.where((show) => !show.isCompleted).toList();
      final reference = upcoming.isNotEmpty
          ? upcoming.first
          : remaining.isNotEmpty ? remaining.first : loadedShows.last;
      year = reference.year; week = reference.week; dayOfWeek = reference.dayOfWeek;
    }
    setState(() { storylines = values; superstars = loadedSuperstars; teams = loadedTeams; titles = loadedTitles; shows = loadedShows; storylineId = linked; if (associations != null) selectedEntities = associations.map((k, v) => MapEntry(k, v.toSet())); loading = false; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101010),
    appBar: AppBar(title: Text(widget.news == null ? 'Nouvelle actualité' : 'Modifier l’actualité'),
      actions: [TextButton(onPressed: loading || saving ? null : _save, child: const Text('Enregistrer'))]),
    body: loading ? const Center(child: CircularProgressIndicator()) : Form(key: _formKey,
      child: NewsFormWidget(title: title, text: text, type: type, year: year, week: week,
        dayOfWeek: dayOfWeek, storylineId: storylineId, storylines: storylines,
        superstars: superstars, teams: teams, titles: titles, shows: shows,
        selectedEntities: selectedEntities, onChangedEntities: (v) => setState(() => selectedEntities = v),
        onChangedTitle: (v) => title = v, onChangedText: (v) => text = v,
        onChangedType: (v) => type = v ?? 'Other',
        onChangedDate: (date) => setState(() { year = date['year']!; week = date['week']!; dayOfWeek = date['day']!; }),
        onChangedStoryline: (v) => setState(() => storylineId = v))),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      final existing = widget.news;
      final value = News(id: existing?.id, title: title.trim(), text: text.trim(),
        createdTime: existing?.createdTime ?? DateTime.now(), type: type,
        year: year, week: week, dayOfWeek: dayOfWeek);
      News saved;
      if (existing == null) {
        saved = await NewsDatabaseHelper.createNews(value);
      } else {
        await NewsDatabaseHelper.updateNews(value);
        saved = value;
      }
      await NewsDatabaseHelper.syncStoryline(news: saved, storylineId: storylineId);
      await NewsAssociationsDatabaseHelper.replace(newsId: saved.id!, ids: selectedEntities.map((k, v) => MapEntry(k, v.toList())));
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l’enregistrement : $error')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}
