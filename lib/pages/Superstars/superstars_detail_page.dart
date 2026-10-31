import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/pages/Superstars/add_edit_superstars_page.dart';

class SuperstarsDetailPage extends StatefulWidget {
  final int superstarId;

  const SuperstarsDetailPage({
    super.key,
    required this.superstarId,
  });

  @override
  SuperstarsDetailPageState createState() => SuperstarsDetailPageState();
}

class SuperstarsDetailPageState extends State<SuperstarsDetailPage> {
  Superstars? superstar;
  List<MatchRecord> listMatches = [];
  List<Brands> listBrands = [];
  List<Superstars> listSuperstars = [];

  bool isLoading = true;
  String? loadError;

  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color border = Color(0xFF303030);
  static const Color primary = Color(0xFFD71920);
  static const Color secondaryText = Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    refreshSuperstar();
  }

  Future<void> refreshSuperstar() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final loadedSuperstar =
          await SuperstarsDatabaseHelper.readSuperstar(widget.superstarId);

      final brands = await BrandsDatabaseHelper.readAllBrands();
      final superstars = await SuperstarsDatabaseHelper.readAllSuperstars();
      final matches = await MatchesDatabaseHelper.readAllMatchesSuperstar(
        widget.superstarId,
      );

      if (!mounted) return;

      setState(() {
        superstar = loadedSuperstar;
        listBrands = brands;
        listSuperstars = superstars;
        listMatches = matches;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadError = e.toString();
        isLoading = false;
      });

      debugPrint('Error loading Superstar: $e');
    }
  }

  String get initials {
    final name = superstar?.name.trim() ?? '';
    if (name.isEmpty) return '?';

    return name
        .split(RegExp(r'\s+'))
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'SUPERSTAR DETAILS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Superstar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: isLoading || superstar == null ? null : editSuperstar,
          ),
          IconButton(
            tooltip: 'Delete Superstar',
            icon: const Icon(Icons.delete_outline),
            onPressed:
                isLoading || superstar == null ? null : confirmDelete,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    if (superstar == null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: refreshSuperstar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 26),
          _buildSectionTitle('PROFILE INFORMATION'),
          const SizedBox(height: 12),
          _buildInformationCard(),
          const SizedBox(height: 28),
          _buildSectionTitle(
            'MATCH HISTORY',
            '${listMatches.length} MATCHES',
          ),
          const SizedBox(height: 12),
          if (listMatches.isEmpty)
            _buildEmptyMatches()
          else
            ...listMatches.map(_buildMatchCard),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final brandName = superstar!.brand?.name ?? 'NO BRAND';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF35171D),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: primary.withOpacity(0.55),
                width: 1.5,
              ),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            superstar!.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _profileTag(
                brandName.toUpperCase(),
                Icons.branding_watermark_outlined,
              ),
              _profileTag(
                superstar!.orientation.toUpperCase(),
                Icons.person_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primary, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, [String? subtitle]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.7,
            ),
          ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          _informationRow(
            'Name',
            superstar!.name,
            Icons.badge_outlined,
          ),
          const Divider(color: border, height: 24),
          _informationRow(
            'Brand',
            superstar!.brand?.name ?? 'No brand assigned',
            Icons.branding_watermark_outlined,
          ),
          const Divider(color: border, height: 24),
          _informationRow(
            'Orientation',
            superstar!.orientation,
            Icons.person_outline,
          ),
          const Divider(color: border, height: 24),
          _informationRow(
            'Recorded matches',
            '${listMatches.length}',
            Icons.sports_mma_outlined,
          ),
        ],
      ),
    );
  }

  Widget _informationRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: secondaryText, size: 19),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 13,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(MatchRecord match) {
    final currentSuperstarId = superstar!.id;

    final allParticipants = match.sides
        .expand((side) => side.participants)
        .toList();

    final opponents = allParticipants
        .where((participant) => participant.superstarId != currentSuperstarId)
        .map((participant) => participant.superstarName)
        .toSet()
        .toList();

    final currentParticipant = allParticipants.any(
      (participant) => participant.superstarId == currentSuperstarId,
    );

    final wonAsIndividual =
        match.resultStatus == MatchResultStatus.winner &&
        match.winnerSuperstarId == currentSuperstarId;

    final winningSide = match.sides.where(
      (side) => side.sideOrder == match.winnerSideOrder,
    );

    final wonAsTeam =
        match.resultStatus == MatchResultStatus.winner &&
        winningSide.isNotEmpty &&
        winningSide.first.participants.any(
          (participant) => participant.superstarId == currentSuperstarId,
        );

    String resultLabel;

    if (match.resultStatus == MatchResultStatus.pending) {
      resultLabel = 'Pending';
    } else if (match.resultStatus == MatchResultStatus.draw) {
      resultLabel = 'Draw';
    } else if (match.resultStatus == MatchResultStatus.noContest) {
      resultLabel = 'No contest';
    } else if (wonAsIndividual || wonAsTeam) {
      resultLabel = 'Victory';
    } else {
      resultLabel = 'Defeat';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sports_mma_outlined,
                color: primary,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  match.formatName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                resultLabel.toUpperCase(),
                style: TextStyle(
                  color: wonAsIndividual || wonAsTeam
                      ? Colors.amber
                      : secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (match.stipulationName.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              match.stipulationName,
              style: const TextStyle(
                color: secondaryText,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            !currentParticipant
                ? 'Participant history unavailable'
                : opponents.isEmpty
                    ? 'No other participants'
                    : 'Opponent${opponents.length > 1 ? 's' : ''}: ${opponents.join(', ')}',
            style: const TextStyle(
              color: secondaryText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.event_outlined,
                color: secondaryText,
                size: 15,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  match.show?.name ?? 'Show not assigned',
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (match.title != null) ...[
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  color: secondaryText,
                  size: 15,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    match.title!.name,
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyMatches() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.sports_mma_outlined,
            color: Color(0xFF555555),
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No matches recorded',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Matches involving this Superstar will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: primary,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load Superstar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (loadError != null) ...[
              const SizedBox(height: 8),
              Text(
                loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: refreshSuperstar,
              icon: const Icon(Icons.refresh),
              label: const Text('RETRY'),
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> editSuperstar() async {
    if (superstar == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditSuperstarsPage(
          superstar: superstar,
          listBrands: listBrands,
          listSuperstars: listSuperstars,
        ),
      ),
    );

    if (mounted) {
      await refreshSuperstar();
    }
  }

  Future<void> confirmDelete() async {
    final currentSuperstar = superstar;
    if (currentSuperstar == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Delete Superstar?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${currentSuperstar.name}? '
          'All matches involving this Superstar and their team memberships '
          'will also be deleted.',
          style: const TextStyle(color: secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: secondaryText),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    try {
      await SuperstarsDatabaseHelper.deleteSuperstar(widget.superstarId);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete Superstar: $e')),
      );
    }
  }
}
