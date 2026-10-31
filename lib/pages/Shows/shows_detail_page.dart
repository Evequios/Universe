import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/pages/Matches/add_edit_matches_page.dart';
import 'package:wwe_universe/pages/Matches/matches_detail_page.dart';
import 'package:wwe_universe/pages/Shows/add_edit_shows_page.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
class ShowsDetailPage extends StatefulWidget {
  final int showId;

  const ShowsDetailPage({
    super.key,
    required this.showId,
  });

  @override
  ShowsDetailPageState createState() => ShowsDetailPageState();
}

class ShowsDetailPageState extends State<ShowsDetailPage> {
  Show? show;
  List<MatchRecord> matchesList = [];

  bool isLoading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    refreshMatches();
  }

  Future<void> refreshMatches() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        loadError = null;
      });
    }

    try {
      final loadedShow = await ShowsDatabaseHelper.readShow(widget.showId);
      final loadedMatches =
          await MatchesDatabaseHelper.readAllMatches(widget.showId);

      if (!mounted) return;

      setState(() {
        show = loadedShow;
        matchesList = loadedMatches;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadError = e.toString();
        isLoading = false;
      });
    }
  }

  String getDayName(int day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    if (day < 1 || day > 7) return 'Unknown day';
    return days[day - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(show?.name ?? 'Show details'),
        actions: [
          IconButton(
            tooltip: 'Edit show',
            icon: const Icon(Icons.edit_outlined),
            onPressed: isLoading || show == null ? null : editButton,
          ),
          IconButton(
            tooltip: 'Delete show',
            icon: const Icon(Icons.delete_outline),
            onPressed: isLoading || show == null ? null : deleteButton,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: show == null || isLoading
          ? null
          : FloatingActionButton(
              backgroundColor: AppFormStyles.primary,
              foregroundColor: Colors.white,
              tooltip: 'Add match',
              onPressed: addMatch,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'Unable to load this show.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: refreshMatches,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (show == null) {
      return const Center(child: Text('Show not found.'));
    }

    return RefreshIndicator(
      onRefresh: refreshMatches,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildShowHeader(),
          const SizedBox(height: 20),
          _buildSummary(),
          const SizedBox(height: 24),
          _buildMatchesHeader(),
          const SizedBox(height: 8),
          if (matchesList.isEmpty)
            _buildEmptyMatches()
          else
            _buildReorderableMatches(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildShowHeader() {
    final currentShow = show!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppFormStyles.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppFormStyles.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppFormStyles.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event,
                  color: AppFormStyles.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  currentShow.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip('Year ${currentShow.year}', Icons.calendar_today),
              _buildInfoChip('Week ${currentShow.week}', Icons.date_range),
              _buildInfoChip(
                getDayName(currentShow.dayOfWeek),
                Icons.today,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppFormStyles.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppFormStyles.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppFormStyles.secondaryText),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final summary = show!.summary.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Summary', Icons.description_outlined),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppFormStyles.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppFormStyles.border),
          ),
          child: Text(
            summary.isEmpty ? 'No summary available.' : summary,
            style: TextStyle(
              color: summary.isEmpty
                  ? AppFormStyles.secondaryText
                  : null,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesHeader() {
    return Row(
      children: [
        Expanded(
          child: _buildSectionTitle(
            'Matches',
            Icons.sports_mma_outlined,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppFormStyles.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${matchesList.length}',
            style: const TextStyle(
              color: AppFormStyles.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppFormStyles.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMatches() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppFormStyles.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppFormStyles.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sports_mma_outlined,
            size: 38,
            color: AppFormStyles.secondaryText,
          ),
          const SizedBox(height: 10),
          const Text(
            'No matches created yet',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            'Use the + button to add the first match.',
            style: TextStyle(color: AppFormStyles.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchRecord match, int index) {
    final participants = match.sides
        .expand((side) => side.participants)
        .map((participant) => participant.superstarName)
        .toList();

    final participantsText = participants.isEmpty
        ? 'Participants unavailable'
        : participants.join(' vs ');

    String resultText;

    switch (match.resultStatus) {
      case MatchResultStatus.winner:
        final winningSide = match.sides.where(
          (side) => side.sideOrder == match.winnerSideOrder,
        );

        if (winningSide.isNotEmpty) {
          resultText = 'Winner: ${winningSide.first.name}';
        } else {
          MatchParticipants? winner;

          for (final side in match.sides) {
            for (final participant in side.participants) {
              if (match.winnerSuperstarId != null) {
                if (participant.superstarId == match.winnerSuperstarId) {
                  winner = participant;
                  break;
                }
              } else if (match.winnerName != null &&
                  participant.superstarName == match.winnerName) {
                winner = participant;
                break;
              }
            }

            if (winner != null) break;
          }

          final winnerName = winner?.superstarName ?? match.winnerName;

          resultText = winnerName == null || winnerName.trim().isEmpty
              ? 'Individual winner'
              : 'Winner: $winnerName';
        }
        break;
      case MatchResultStatus.draw:
        resultText = 'Draw';
        break;

      case MatchResultStatus.noContest:
        resultText = 'No contest';
        break;

      default:
        resultText = 'Pending';
    }

    return Card(
      key: ValueKey(match.id),
      margin: const EdgeInsets.only(bottom: 10),
      color: AppFormStyles.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppFormStyles.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MatchesDetailPage(
                matchId: match.id!,
                showId: show!.id!,
              ),
            ),
          );

          if (mounted) {
            await refreshMatches();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.drag_handle,
                    color: AppFormStyles.secondaryText,
                  ),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppFormStyles.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_mma,
                  color: AppFormStyles.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participantsText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      match.formatName,
                      style: TextStyle(
                        color: AppFormStyles.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    if (match.stipulationName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        match.stipulationName,
                        style: TextStyle(
                          color: AppFormStyles.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      resultText,
                      style: TextStyle(
                        color: match.resultStatus == MatchResultStatus.winner
                            ? Colors.amber
                            : AppFormStyles.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppFormStyles.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addMatch() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditMatchesPage(
          show: show!,
        ),
      ),
    );

    if (mounted) {
      await refreshMatches();
    }
  }

  Future<void> editButton() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditShowsPage(show: show!),
      ),
    );

    if (mounted) refreshMatches();
  }

  void deleteButton() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete show?'),
        content: const Text(
          'Are you sure you want to delete this show? '
          'All matches associated with it will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppFormStyles.primary,
            ),
            onPressed: () async {
              await ShowsDatabaseHelper.deleteShow(widget.showId);

              if (!mounted) return;

              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderableMatches() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: matchesList.length,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) {
          newIndex--;
        }

        setState(() {
          final item = matchesList.removeAt(oldIndex);
          matchesList.insert(newIndex, item);
        });

        final orderedIds = matchesList
            .where((match) => match.id != null)
            .map((match) => match.id!)
            .toList();

        await MatchesDatabaseHelper.reorderMatches(
          widget.showId,
          orderedIds,
        );
      },
      itemBuilder: (context, index) {
        final match = matchesList[index];

        return KeyedSubtree(
          key: ValueKey(match.id),
          child: _buildMatchCard(match, index),
        );
      },
    );
  }
}
