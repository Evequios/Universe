
import 'package:flutter/material.dart';
import 'package:wwe_universe/navbar.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/pages/Teams/add_edit_teams_page.dart';
import 'package:wwe_universe/pages/Teams/teams_detail_page.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  TeamsPageState createState() => TeamsPageState();
}

class TeamsPageState extends State<TeamsPage>
    with AutomaticKeepAliveClientMixin {
  List<Superstars> superstarsList = [];
  List<Teams> teamsList = [];

  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;
  bool isSearching = false;
  String? loadError;

  int requestId = 0;

  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color border = Color(0xFF303030);
  static const Color primary = Color(0xFFD71920);
  static const Color secondaryText = Color(0xFFAAAAAA);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    refreshTeams();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshTeams({String? search}) async {
    final currentRequest = ++requestId;
    final query = search ?? searchController.text.trim();

    if (mounted) {
      setState(() {
        isLoading = true;
        loadError = null;
      });
    }

    try {
      final results = query.isEmpty
          ? await TeamsDatabaseHelper.readAllTeams()
          : await TeamsDatabaseHelper.readAllTeamsSearch(query);

      final superstars = superstarsList.isEmpty
          ? await SuperstarsDatabaseHelper.readAllSuperstars()
          : superstarsList;

      if (!mounted || currentRequest != requestId) return;

      setState(() {
        teamsList = results;
        superstarsList = superstars;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted || currentRequest != requestId) return;

      setState(() {
        loadError = e.toString();
        isLoading = false;
      });

      debugPrint('Error loading teams: $e');
    }
  }

  void setTeamsList(String search) {
    refreshTeams(search: search);
  }

  Future<void> openCreateTeam() async {
    if (isLoading) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTeamsPage(
          listSuperstars: superstarsList,
        ),
      ),
    );

    if (mounted) {
      await refreshTeams();
    }
  }

  Future<void> openTeam(Teams team) async {
    if (team.id == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeamsDetailPage(teamId: team.id!),
      ),
    );

    if (mounted) {
      await refreshTeams();
    }
  }

  Future<void> confirmDelete(Teams team) async {
    if (team.id == null) return;

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
      await TeamsDatabaseHelper.deleteTeam(team.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team deleted')),
        );
        await refreshTeams();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete team: $e')),
      );
    }
  }

  List<Superstars> getMembers(Teams team) {
    return [
      team.member1,
      team.member2,
      if (team.member3 != null) team.member3!,
      if (team.member4 != null) team.member4!,
      if (team.member5 != null) team.member5!,
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: background,
      drawer: const Navbar(),
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search a team...',
                  hintStyle: TextStyle(color: secondaryText),
                  border: InputBorder.none,
                ),
                onChanged: setTeamsList,
              )
            : const Text(
                'TEAMS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 17,
                ),
              ),
        actions: [
          IconButton(
            tooltip: isSearching ? 'Close search' : 'Search',
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  searchController.clear();
                } else {
                  isSearching = true;
                }
              });

              if (!isSearching) {
                refreshTeams(search: '');
              }
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : openCreateTeam,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && teamsList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    if (loadError != null && teamsList.isEmpty) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: refreshTeams,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _buildHeader(),
          const SizedBox(height: 22),
          if (isLoading)
            const LinearProgressIndicator(
              color: primary,
              backgroundColor: surface,
            ),
          if (loadError != null)
            _buildInlineError(),
          if (teamsList.isEmpty)
            _buildEmptyState()
          else ...[
            _buildSectionTitle(),
            const SizedBox(height: 12),
            ...teamsList.map(_buildTeamCard),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR TEAMS',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${teamsList.length} ${teamsList.length == 1 ? 'TEAM' : 'TEAMS'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.shield_outlined,
            color: Color(0xFF555555),
            size: 34,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'YOUR ROSTER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        Text(
          '${teamsList.length} RESULTS',
          style: const TextStyle(
            color: secondaryText,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(Teams team) {
    final members = getMembers(team);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => openTeam(team),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: primary,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        members.map((member) => member.name).join(' • '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF292929),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${members.length} MEMBERS',
                          style: const TextStyle(
                            color: primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: secondaryText,
                  ),
                  color: surface,
                  onSelected: (value) {
                    if (value == 'delete') {
                      confirmDelete(team);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: primary,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Delete team',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  color: secondaryText,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearchEmpty = searchController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          Icon(
            isSearchEmpty
                ? Icons.search_off_rounded
                : Icons.groups_outlined,
            color: const Color(0xFF555555),
            size: 58,
          ),
          const SizedBox(height: 18),
          Text(
            isSearchEmpty ? 'No teams found' : 'No teams created yet',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchEmpty
                ? 'Try another search.'
                : 'Create your first team and build your roster.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 13,
            ),
          ),
          if (!isSearchEmpty) ...[
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: openCreateTeam,
              icon: const Icon(Icons.add),
              label: const Text('CREATE A TEAM'),
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Unable to refresh teams: $loadError',
        style: const TextStyle(color: Colors.redAccent),
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
              'Unable to load teams',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: refreshTeams,
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
}
