import 'package:wwe_universe/widget/news_profile_section.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/reigns.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/pages/Teams/teams_detail_page.dart';
import 'package:wwe_universe/database/reings_database_helper.dart';
import 'package:wwe_universe/widget/wwe_date_dialog.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/pages/Superstars/superstars_detail_page.dart';
import 'package:wwe_universe/pages/Titles/add_edit_titles_page.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';

class TitlesDetailPage extends StatefulWidget {
  final int titleId;

  const TitlesDetailPage({
    super.key,
    required this.titleId,
    
  });

  @override
  TitlesDetailPageState createState() => TitlesDetailPageState();
}

class TitlesDetailPageState extends State<TitlesDetailPage> {
  Titles title = const Titles(name: '', tag: 0, brand: null, holder1: null, holder2: null);
  Superstars h1 = const Superstars(name: 'nom', brand: null, orientation: 'orientation', division: null); 
  Superstars h2 = const Superstars(name: 'nom', brand: null, orientation: 'orientation', division: null);
  bool isLoading = false;
  List<Reigns> reigns = [];
  final Map<int, Teams> _teamsById = {};
  

  @override
  void initState() {
    super.initState();

    refreshTitle();
  }

  Future<void> refreshTitle() async {
    if (mounted) setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        TitlesDatabaseHelper.readTitle(widget.titleId),
        ReignsDatabaseHelper.readReigns(widget.titleId),
        TeamsDatabaseHelper.readAllTeams(),
      ]);
      final loadedTitle = results[0] as Titles;
      final loadedReigns = results[1] as List<Reigns>;
      final loadedTeams = results[2] as List<Teams>;

      final holderIds = <int>{
        if (loadedTitle.holder1?.id != null) loadedTitle.holder1!.id!,
        if (loadedTitle.holder2?.id != null) loadedTitle.holder2!.id!,
      };
      final holderResults = await Future.wait(
        holderIds.map(SuperstarsDatabaseHelper.readSuperstar),
      );
      final holdersById = <int, Superstars>{};
      var index = 0;
      for (final id in holderIds) {
        holdersById[id] = holderResults[index++];
      }

      if (!mounted) return;
      setState(() {
        title = loadedTitle;
        reigns = loadedReigns;
        _teamsById
          ..clear()
          ..addEntries(loadedTeams.where((team) => team.id != null)
              .map((team) => MapEntry(team.id!, team)));
        h1 = loadedTitle.holder1?.id == null
            ? const Superstars(name: 'nom', brand: null, orientation: 'orientation', division: null)
            : holdersById[loadedTitle.holder1!.id!]!;
        h2 = loadedTitle.holder2?.id == null
            ? const Superstars(name: 'nom', brand: null, orientation: 'orientation', division: null)
            : holdersById[loadedTitle.holder2!.id!]!;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load title details: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Title details'),
      actions: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          tooltip: 'Declare title vacant',
          onPressed: _vacateTitle,
        ),
        editButton(),
        deleteButton(),
      ],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title identity card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF383838),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHAMPIONSHIP',
                      style: TextStyle(
                        color: Color(0xFFD71920),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF383838)),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.branding_watermark_outlined,
                      'Brand',
                      title.brand?.name ?? 'None',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.emoji_events_outlined,
                      'Title type',
                      title.tag == 1 ? 'Tag Team' : 'Singles',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Current champion(s)
              const Text(
                'CURRENT CHAMPION',
                style: TextStyle(
                  color: Color(0xFFD71920),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              if (title.holder1 != null)
                _buildChampionCard(h1)
              else
                _buildEmptyChampionCard(),
              if (title.tag == 1) ...[
                const SizedBox(height: 10),
                if (title.holder2 != null)
                  _buildChampionCard(h2)
                else
                  _buildEmptyChampionCard(),
                if (reigns.isNotEmpty && reigns.first.isCurrent && reigns.first.teamId != null) ...[
                  const SizedBox(height: 10),
                  _buildTeamChampionCard(reigns.first),
                ],
              ],
              const SizedBox(height: 28),
              const Text(
                'REIGN HISTORY',
                style: TextStyle(color: Color(0xFFD71920), fontSize: 13,
                  fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              if (reigns.isEmpty)
                const Text('No reign recorded yet.', style: TextStyle(color: Color(0xFFAAAAAA)))
              else
                ...reigns.map(_buildReignCard),
              const SizedBox(height: 28),
              NewsProfileSection(relationTable: 'news_titles', relationColumn: 'title_id', entityId: widget.titleId),
            ],
          ),
  );


  Widget _buildTeamChampionCard(Reigns reign) {
    final team = _teamsById[reign.teamId];
    return Card(
      color: const Color(0xFF222222),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFF351719), child: Icon(Icons.groups, color: Color(0xFFD71920))),
        title: Text(team?.name ?? reign.teamName ?? 'Champion Team', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: const Text('Linked tag team', style: TextStyle(color: Color(0xFFAAAAAA))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF888888)),
        onTap: team?.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeamsDetailPage(teamId: team!.id!))),
      ),
    );
  }

  Widget _buildReignCard(Reigns reign) {
    final start = 'Year ${reign.yearStart} • Week ${reign.weekStart} • Day ${reign.dayStart}';
    final end = reign.isCurrent
        ? 'Current reign'
        : 'Year ${reign.yearEnd} • Week ${reign.weekEnd} • Day ${reign.dayEnd ?? 1}';
    final holders = reign.holder2Name == null
        ? reign.holder1Name
        : '${reign.holder1Name} & ${reign.holder2Name}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF383838)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: reign.holder1Id == null ? null : () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SuperstarsDetailPage(superstarId: reign.holder1Id!)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(holders, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          if (reign.holder1Id != null) const Icon(Icons.chevron_right, color: Color(0xFF888888), size: 18),
        ]),
        const SizedBox(height: 6),
        Text('$start → $end', style: const TextStyle(color: Color(0xFFAAAAAA))),
        if (reign.teamName != null)
          Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [
            const Icon(Icons.groups_outlined, size: 15, color: Color(0xFFD71920)),
            const SizedBox(width: 6),
            Text(reign.teamName!, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12)),
          ])),
        if (reign.startMatchId == null)
          Align(alignment: Alignment.centerRight, child: TextButton.icon(
            onPressed: () => _editReignDate(reign),
            icon: const Icon(Icons.edit_calendar_outlined, size: 16),
            label: const Text('Edit reign date'),
          )),
        if (reign.endReason == 'vacated')
          const Padding(padding: EdgeInsets.only(top: 5), child: Text('Title vacated', style: TextStyle(color: Colors.orangeAccent, fontSize: 12))),
      ])),
    );
  }

  Future<void> _editReignDate(Reigns reign) async {
    final date = await showDialog<Map<String, int>>(
      context: context,
      builder: (_) => WweDateDialog(
        title: 'Edit reign start date',
        confirmLabel: 'Save',
        initialYear: reign.yearStart,
        initialWeek: reign.weekStart,
        initialDay: reign.dayStart,
      ),
    );
    if (date == null || !mounted) return;
    try {
      await ReignsDatabaseHelper.updateManualReignDate(
        reign: reign,
        year: date['year']!,
        week: date['week']!,
        dayOfWeek: date['day']!,
      );
      await refreshTitle();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to edit reign: $error')),
      );
    }
  }

  Future<void> _vacateTitle() async {
    if (title.holder1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This title is already vacant.')),
      );
      return;
    }
    if (reigns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reigns have been recorded for this title yet.')),
      );
      return;
    }
    final date = await showDialog<Map<String, int>>(
      context: context,
      builder: (_) => const WweDateDialog(
        title: 'Vacate Title',
        confirmLabel: 'Confirmer',
        initialDay: 1,
      ),
    );
    if (date == null || !mounted) return;
    final year = date['year']!;
    final week = date['week']!;
    final day = date['day']!;

    try {
      await ReignsDatabaseHelper.vacateTitle(titleId: widget.titleId, year: year, week: week, dayOfWeek: day);
      await refreshTitle();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to vacate title: $error')));
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD71920), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChampionCard(Superstars champion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF383838)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: champion.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuperstarsDetailPage(superstarId: champion.id!))),
        child: Row(
        children: [
          SuperstarAvatar(superstar: champion, size: 52, radius: 13),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              champion.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.emoji_events,
            color: Color(0xFFD71920),
            size: 22,
          ),
        ],
      )),
    );
  }

  Widget _buildEmptyChampionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF383838)),
      ),
      child: const Row(
        children: [
          Icon(Icons.person_outline, color: Color(0xFF888888)),
          SizedBox(width: 12),
          Text(
            'No champion assigned',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    tooltip: 'Edit title',
    onPressed: () async {
      final updated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => AddEditTitlesPage(title: title),
        ),
      );

      if (updated == true && mounted) {
        await refreshTitle();
      }
    },
  );

  Widget deleteButton() => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () async {
      showAlertDialog(context);
    },
  );

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () { 
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed:  () async {
        await TitlesDatabaseHelper.deleteTitle(widget.titleId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to delete this title ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}