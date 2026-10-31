
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/pages/Teams/add_edit_teams_page.dart';

class TeamsDetailPage extends StatefulWidget {
  final int teamId;

  const TeamsDetailPage({
    super.key,
    required this.teamId,
  });

  @override
  TeamsDetailPageState createState() => TeamsDetailPageState();
}

class TeamsDetailPageState extends State<TeamsDetailPage> {
  late Teams team;
  late List<Superstars> superstarList;

  bool isLoading = true;
  bool hasTeam = false;
  String? loadError;

  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color border = Color(0xFF303030);
  static const Color primary = Color(0xFFD71920);
  static const Color secondaryText = Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    refreshTeam();
  }

  Future<void> refreshTeam() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      superstarList = await SuperstarsDatabaseHelper.readAllSuperstars();
      team = await TeamsDatabaseHelper.readTeam(widget.teamId);

      hasTeam = true;
    } catch (e) {
      loadError = e.toString();
      debugPrint('Error loading team: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<Superstars> get members => [
        team.member1,
        team.member2,
        if (team.member3 != null) team.member3!,
        if (team.member4 != null) team.member4!,
        if (team.member5 != null) team.member5!,
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TEAM DETAILS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit team',
            icon: const Icon(Icons.edit_outlined),
            onPressed: isLoading || !hasTeam ? null : editTeam,
          ),
          IconButton(
            tooltip: 'Delete team',
            icon: const Icon(Icons.delete_outline),
            onPressed: isLoading || !hasTeam ? null : confirmDelete,
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

    if (loadError != null || !hasTeam) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: refreshTeam,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _buildTeamHeader(),
          const SizedBox(height: 28),
          _buildSectionTitle(
            'TEAM ROSTER',
            '${members.length} MEMBERS',
          ),
          const SizedBox(height: 14),
          ...List.generate(
            members.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildMemberCard(members[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHeader() {
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
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.13),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: primary.withOpacity(0.45),
              ),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: primary,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            team.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.13),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${members.length} ${members.length > 1 ? 'MEMBERS' : 'MEMBER'}',
              style: const TextStyle(
                color: primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(Superstars superstar, int index) {
    final brandName = superstar.brand?.name;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  superstar.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: [
                    if (brandName != null && brandName.isNotEmpty)
                      _memberTag(
                        brandName,
                        Icons.branding_watermark_outlined,
                      ),
                    if (superstar.orientation.isNotEmpty)
                      _memberTag(
                        superstar.orientation,
                        Icons.person_outline,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.check_circle,
            color: primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _memberTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: secondaryText,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
              'Unable to load this team',
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
              onPressed: refreshTeam,
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

  Future<void> editTeam() async {
    if (isLoading) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTeamsPage(
          team: team,
          listSuperstars: superstarList,
        ),
      ),
    );

    if (mounted) {
      await refreshTeam();
    }
  }

  Future<void> confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Delete team?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${team.name}"?',
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
      await TeamsDatabaseHelper.deleteTeam(widget.teamId);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete team: $e'),
        ),
      );
    }
  }
}