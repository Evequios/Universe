
import 'package:flutter/material.dart';

import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/pages/Matches/add_edit_matches_page.dart';

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
        SnackBar(content: Text('Impossible de charger le combat : $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Détail du combat'),
        actions: [
          IconButton(
            tooltip: 'Modifier',
            icon: const Icon(Icons.edit_outlined),
            onPressed: isLoading || match == null ? null : editMatch,
          ),
          IconButton(
            tooltip: 'Supprimer',
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
                    'Combat introuvable.',
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
        if (value.stipulationName.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            value.stipulationName,
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
        _buildSectionTitle('Informations'),
        const SizedBox(height: 10),
        _buildInfoCard(
          icon: Icons.event_outlined,
          title: show?.name ?? 'Show indisponible',
          subtitle: show == null
              ? 'Le show associé n’est plus disponible'
              : 'Année ${show!.year} • Semaine ${show!.week}',
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
          title = 'Vainqueur : ${winningSide.name}';
          subtitle = 'Victoire du camp';
        } else {
          final winner = _findWinner(value);
          final winnerName = winner?.superstarName ?? value.winnerName;

          title = winnerName == null || winnerName.isEmpty
              ? 'Vainqueur individuel'
              : 'Vainqueur : $winnerName';

          subtitle = 'Victoire individuelle';
        }

        icon = Icons.emoji_events_outlined;
        break;

      case MatchResultStatus.draw:
        title = 'Match nul';
        subtitle = 'Aucun vainqueur';
        icon = Icons.handshake_outlined;
        break;

      case MatchResultStatus.noContest:
        title = 'Sans résultat';
        subtitle = 'Combat déclaré sans résultat';
        icon = Icons.block_outlined;
        break;

      default:
        title = 'À déterminer';
        subtitle = 'Le résultat du combat n’a pas encore été renseigné';
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

    final isIndividualWinner =
        currentMatch?.resultStatus == MatchResultStatus.winner &&
        currentMatch?.winnerSideOrder == null &&
        (currentMatch?.winnerSuperstarId != null
            ? participant.superstarId == currentMatch!.winnerSuperstarId
            : currentMatch?.winnerName != null &&
                participant.superstarName == currentMatch!.winnerName);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: isIndividualWinner ? primary : secondaryText,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              participant.superstarName,
              style: TextStyle(
                color: isIndividualWinner ? Colors.white : secondaryText,
                fontWeight:
                    isIndividualWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isIndividualWinner)
            const Icon(Icons.emoji_events, color: primary, size: 18),
        ],
      ),
    );
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
        title: const Text('Supprimer le combat'),
        content: const Text(
          'Voulez-vous vraiment supprimer ce combat ? Cette action est définitive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Supprimer',
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
