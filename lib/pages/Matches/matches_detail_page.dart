
import 'package:flutter/material.dart';

import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/storyline_relations_database_helper.dart';
import 'package:wwe_universe/database/storylines_database_helper.dart';
import 'package:wwe_universe/pages/Storylines/storylines_detail_page.dart';
import 'package:wwe_universe/pages/Matches/add_edit_matches_page.dart';
import 'package:wwe_universe/database/superstar_relationships_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';
import 'package:wwe_universe/pages/Superstars/superstars_detail_page.dart';
import 'package:wwe_universe/pages/Superstars/select_superstars_page.dart';

class MatchesDetailPage extends StatefulWidget {
  final int matchId;
  final int showId;

  const MatchesDetailPage({
    super.key,
    required this.matchId,
    required this.showId,
  });

  @override
  State<MatchesDetailPage> createState() => MatchesDetailPageState();
}

class MatchesDetailPageState extends State<MatchesDetailPage> {
  MatchRecord? match;
  Show? show;
  bool isLoading = true;

  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color border = Color(0xFF383838);
  static const Color primary = Color(0xFFD71920);
  static const Color secondaryText = Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    refreshMatch();
  }

  Future<void> refreshMatch() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      final results = await Future.wait([
        MatchesDatabaseHelper.readMatch(widget.matchId),
        ShowsDatabaseHelper.readShow(widget.showId),
      ]);

      if (!mounted) return;

      setState(() {
        match = results[0] as MatchRecord;
        show = results[1] as Show;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load match: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Match Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: isLoading || match == null ? null : editMatch,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: isLoading || match == null ? null : confirmDelete,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : match == null
              ? const Center(
                  child: Text(
                    'Match not found.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : _buildContent(match!),
    );
  }

  Widget _buildContent(MatchRecord value) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          value.formatName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        if ((value.matchTypeName.isNotEmpty ? value.matchTypeName : value.stipulationName).trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            value.matchTypeName.isNotEmpty ? value.matchTypeName : value.stipulationName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 16,
            ),
          ),
        ],
        const SizedBox(height: 24),
        _buildResult(value),
        const SizedBox(height: 24),
        _buildSectionTitle('Participants'),
        const SizedBox(height: 12),
        ...value.sides.map((side) => _buildSide(value, side)),
        if (value.specialParticipants.isNotEmpty) ...[
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Participants', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ...value.specialParticipants.map(_buildParticipant),
          ])),
        ],
        if (value.title != null) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Enjeu'),
          const SizedBox(height: 10),
          _buildInfoCard(
            icon: Icons.workspace_premium_outlined,
            title: value.title!.name,
            subtitle: 'Championnat',
          ),
        ],
        const SizedBox(height: 24),
        _buildSectionTitle('Information'),
        const SizedBox(height: 10),
        _buildInfoCard(
          icon: Icons.event_outlined,
          title: show?.name ?? 'Show unavailable',
          subtitle: show == null
              ? 'The linked Show is no longer available'
              : 'Year ${show!.year} • Week ${show!.week}',
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Related Storylines'),
        const SizedBox(height: 10),
        FutureBuilder<List<int>>(
          future: StorylineRelationsDatabaseHelper.readStorylineIdsForMatch(value.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final ids = snapshot.data ?? const <int>[];
            if (ids.isEmpty) return const Text('This match is not linked to any storyline.', style: TextStyle(color: secondaryText));
            return Column(children: ids.map((id) => FutureBuilder(
              future: StorylinesDatabaseHelper.readStoryline(id),
              builder: (context, storylineSnapshot) {
                if (!storylineSnapshot.hasData) return const SizedBox.shrink();
                final storyline = storylineSnapshot.data!;
                return Card(color: surface, child: ListTile(
                  leading: const Icon(Icons.auto_stories_outlined, color: primary),
                  title: Text(storyline.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Open Storyline', style: const TextStyle(color: secondaryText)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StorylinesDetailPage(storylineId: id))),
                ));
              },
            )).toList());
          },
        ),
      ],
    );
  }

  Widget _buildResult(MatchRecord value) {
    String title;
    String subtitle;
    IconData icon;

    switch (value.resultStatus) {
      case MatchResultStatus.winner:
        final winningSide = value.sides.cast<MatchSides?>().firstWhere(
              (side) => side?.sideOrder == value.winnerSideOrder,
              orElse: () => null,
            );

        if (winningSide != null) {
          title = 'Winner: ${winningSide.name}';
          subtitle = 'Side win';
        } else {
          final winner = _findWinner(value);
          final winnerName = winner?.superstarName ?? value.winnerName;

          title = winnerName == null || winnerName.isEmpty
              ? 'Individual Winner'
              : 'Winner: $winnerName';

          subtitle = 'Individual win';
        }

        icon = Icons.emoji_events_outlined;
        break;

      case MatchResultStatus.draw:
        title = 'Draw';
        subtitle = 'No winner';
        icon = Icons.handshake_outlined;
        break;

      case MatchResultStatus.noContest:
        title = 'No Contest';
        subtitle = 'Match declared a No Contest';
        icon = Icons.block_outlined;
        break;

      default:
        title = 'To Be Determined';
        subtitle = 'The match result has not been entered yet';
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  MatchParticipants? _findWinner(MatchRecord value) {
    for (final participant in value.specialParticipants) {
      if (value.winnerSuperstarId != null ? participant.superstarId == value.winnerSuperstarId : value.winnerName != null && participant.superstarName == value.winnerName) return participant;
    }
    for (final side in value.sides) {
      for (final participant in side.participants) {
        if (value.winnerSuperstarId != null) {
          if (participant.superstarId == value.winnerSuperstarId) {
            return participant;
          }
        } else if (value.winnerName != null &&
            participant.superstarName == value.winnerName) {
          return participant;
        }
      }
    }

    return null;
  }

  Widget _buildSide(MatchRecord value, MatchSides side) {
    final isWinner = value.resultStatus == MatchResultStatus.winner &&
        value.winnerSideOrder == side.sideOrder;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? primary : border,
          width: isWinner ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  side.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isWinner)
                const Icon(
                  Icons.emoji_events,
                  color: primary,
                  size: 21,
                ),
            ],
          ),
          if (side.participants.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...side.participants.map(_buildParticipant),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipant(MatchParticipants participant) {
    final currentMatch = match;
    final isIndividualWinner = currentMatch?.resultStatus == MatchResultStatus.winner &&
        currentMatch?.winnerSideOrder == null &&
        (currentMatch?.winnerSuperstarId != null
            ? participant.superstarId == currentMatch!.winnerSuperstarId
            : currentMatch?.winnerName != null && participant.superstarName == currentMatch!.winnerName);

    final superstarFuture = participant.superstarId == null
        ? null
        : SuperstarsDatabaseHelper.readSuperstar(participant.superstarId!);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Row(children: [
          if (superstarFuture != null)
            FutureBuilder<Superstars>(
              future: superstarFuture,
              builder: (context, snapshot) => snapshot.hasData
                  ? SuperstarAvatar(superstar: snapshot.data!, size: 48, radius: 12)
                  : CircleAvatar(radius: 24, backgroundColor: const Color(0xFF35171D), child: Text(participant.superstarName.isEmpty ? '?' : participant.superstarName[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
            )
          else
            const CircleAvatar(radius: 24, backgroundColor: Color(0xFF292929), child: Icon(Icons.person_outline, color: secondaryText)),
          const SizedBox(width: 10),
          Expanded(child: InkWell(
            onTap: participant.superstarId == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuperstarsDetailPage(superstarId: participant.superstarId!))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(participant.superstarName, style: TextStyle(color: isIndividualWinner ? Colors.white : secondaryText, fontWeight: isIndividualWinner ? FontWeight.bold : FontWeight.w600)),
              if (participant.superstarId != null) const Text('View Superstar profile', style: TextStyle(color: primary, fontSize: 11)),
              if (participant.superstarId == null) const Text('Historical participant', style: TextStyle(color: secondaryText, fontSize: 11)),
            ]),
          )),
          if (isIndividualWinner) const Icon(Icons.emoji_events, color: primary, size: 18),
          if (participant.superstarId != null)
            IconButton(tooltip: 'Match managers', icon: const Icon(Icons.groups_outlined, color: secondaryText), onPressed: () => _editParticipantManagers(participant)),
        ]),
        if (participant.superstarId != null && currentMatch?.id != null)
          _buildParticipantManagers(participant, currentMatch!),
      ]),
    );
  }

  Widget _buildParticipantManagers(MatchParticipants participant, MatchRecord current) {
    return FutureBuilder<List<Superstars>>(
      future: _loadEffectiveManagers(current.id!, participant.superstarId!),
      builder: (context, snapshot) {
        final managers = snapshot.data ?? const <Superstars>[];
        if (snapshot.connectionState == ConnectionState.waiting || managers.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8, left: 58),
          child: Row(children: [
            const Icon(Icons.groups_outlined, color: secondaryText, size: 15),
            const SizedBox(width: 6),
            Expanded(child: Wrap(spacing: 6, runSpacing: 5, children: managers.map((manager) => InkWell(
              onTap: manager.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuperstarsDetailPage(superstarId: manager.id!))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SuperstarAvatar(superstar: manager, size: 25, radius: 7),
                const SizedBox(width: 4),
                Text(manager.name, style: const TextStyle(color: secondaryText, fontSize: 11)),
              ]),
            )).toList())),
          ]),
        );
      },
    );
  }

  Future<List<Superstars>> _loadEffectiveManagers(int matchId, int participantId) async {
    final hasOverride = await SuperstarRelationshipsDatabaseHelper.hasMatchManagerOverride(matchId, participantId);
    final ids = hasOverride
        ? await SuperstarRelationshipsDatabaseHelper.readMatchManagers(matchId, participantId)
        : await SuperstarRelationshipsDatabaseHelper.readRelatedIds(participantId, 'manager');
    final values = await Future.wait(ids.map((id) async {
      try { return await SuperstarsDatabaseHelper.readSuperstar(id); } catch (_) { return null; }
    }));
    return values.whereType<Superstars>().toList();
  }

  Future<void> _editParticipantManagers(MatchParticipants participant) async {
    final current = match;
    final superstarId = participant.superstarId;
    if (current == null || current.id == null || superstarId == null) return;
    try {
      final roster = await SuperstarsDatabaseHelper.readAllSuperstars();
      final hasOverride = await SuperstarRelationshipsDatabaseHelper.hasMatchManagerOverride(current.id!, superstarId);
      final usual = await SuperstarRelationshipsDatabaseHelper.readRelatedIds(superstarId, 'manager');
      final saved = await SuperstarRelationshipsDatabaseHelper.readMatchManagers(current.id!, superstarId);
      final selected = hasOverride ? saved : usual;
      if (!mounted) return;
      final result = await Navigator.push<List<int>>(context, MaterialPageRoute(builder: (_) => SelectSuperstarsPage(
        title: 'Select match managers',
        initiallySelected: Set<int>.from(selected),
        excludedIds: {superstarId},
      )));
      if (result != null) {
        await SuperstarRelationshipsDatabaseHelper.replaceMatchManagers(current.id!, superstarId, result);
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to load managers: $e')));
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editMatch() async {
    final currentMatch = match;
    final currentShow = show;

    if (currentMatch == null || currentShow == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditMatchesPage(
          match: currentMatch,
          show: currentShow,
        ),
      ),
    );

    if (mounted) {
      await refreshMatch();
    }
  }

  Future<void> confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Match'),
        content: const Text(
          'Are you sure you want to delete this match? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await MatchesDatabaseHelper.deleteMatch(widget.matchId);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
