
import 'package:flutter/material.dart';
import 'package:wwe_universe/navbar.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/pages/Titles/add_edit_titles_page.dart';
import 'package:wwe_universe/pages/Titles/titles_detail_page.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';

class TitlesPage extends StatefulWidget {
  const TitlesPage({super.key});

  @override
  TitlesPageState createState() => TitlesPageState();
}

class TitlesPageState extends State<TitlesPage>
    with AutomaticKeepAliveClientMixin {
  List<Titles> titlesList = [];
  List<Superstars> superstarsList = [];
  List<Brands> brandsList = [];

  bool isLoading = true;
  bool isSearchVisible = false;
  String searchString = '';
  String? loadError;
  String _typeFilter = 'all';
  String _championFilter = 'all';
  String _sortOrder = 'name';

  List<Titles> get _visibleTitles {
    final rows = titlesList.where((title) {
      final isTag = title.tag == 1;
      final hasChampion = title.holder1 != null || title.holder2 != null;
      return (_typeFilter == 'all' || (_typeFilter == 'tag' && isTag) || (_typeFilter == 'singles' && !isTag)) &&
          (_championFilter == 'all' || (_championFilter == 'active' && hasChampion) || (_championFilter == 'vacant' && !hasChampion));
    }).toList();
    rows.sort((a, b) {
      if (_sortOrder == 'brand') {
        final brandCompare = (a.brand?.name ?? '').compareTo(b.brand?.name ?? '');
        if (brandCompare != 0) return brandCompare;
      }
      if (_sortOrder == 'champion') {
        final championCompare = (a.holder1?.name ?? '').compareTo(b.holder1?.name ?? '');
        if (championCompare != 0) return championCompare;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return rows;
  }

  final TextEditingController searchController = TextEditingController();

  int searchRequestId = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    refreshTitles();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshTitles() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final results = await Future.wait([
        TitlesDatabaseHelper.readAllTitles(),
        SuperstarsDatabaseHelper.readAllSuperstars(),
        BrandsDatabaseHelper.readAllBrands(),
      ]);

      if (!mounted) return;

      setState(() {
        titlesList = results[0] as List<Titles>;
        superstarsList = results[1] as List<Superstars>;
        brandsList = results[2] as List<Brands>;
        isLoading = false;
      });

      // Reapply the current search after a refresh.
      if (searchString.isNotEmpty) {
        await setTitlesList(searchString);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = 'Unable to load titles.';
      });
    }
  }

  Future<void> setTitlesList(String search) async {
    final requestId = ++searchRequestId;

    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final results = search.trim().isEmpty
          ? await TitlesDatabaseHelper.readAllTitles()
          : await TitlesDatabaseHelper.readAllTitlesSearch(search.trim());

      if (!mounted || requestId != searchRequestId) return;

      setState(() {
        titlesList = results;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != searchRequestId) return;

      setState(() {
        isLoading = false;
        loadError = 'Unable to search titles.';
      });
    }
  }

  void toggleSearch() {
    setState(() {
      isSearchVisible = !isSearchVisible;

      if (!isSearchVisible) {
        searchString = '';
        searchController.clear();
      }
    });

    if (!isSearchVisible) {
      setTitlesList('');
    }
  }

  Future<void> openAddTitle() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTitlesPage(
          listBrands: brandsList,
          listSuperstars: superstarsList,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await refreshTitles();
    }
  }

  Future<void> openTitleDetails(Titles title) async {
    if (title.id == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TitlesDetailPage(
          titleId: title.id!,
        ),
      ),
    );

    if (!mounted) return;

    await refreshTitles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      drawer: const Navbar(),
      appBar: AppBar(
        centerTitle: true,
        title: isSearchVisible
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search titles...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  searchString = value;
                  setTitlesList(value);
                },
              )
            : const Text('Titles'),
        actions: [
          IconButton(
            tooltip: isSearchVisible ? 'Close search' : 'Search',
            icon: Icon(
              isSearchVisible ? Icons.close : Icons.search,
            ),
            onPressed: toggleSearch,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: isLoading ? null : openAddTitle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (loadError != null) {
      return _buildMessage(
        icon: Icons.error_outline,
        message: loadError!,
        action: 'Retry',
        onPressed: refreshTitles,
      );
    }

    if (titlesList.isEmpty) {
      return _buildMessage(
        icon: Icons.emoji_events_outlined,
        message: searchString.isNotEmpty
            ? 'No titles found'
            : 'No titles created yet',
      );
    }

    final visibleTitles = _visibleTitles;
    if (visibleTitles.isEmpty) {
      return _buildMessage(icon: Icons.filter_list_off, message: 'No title matches these filters.');
    }
    return RefreshIndicator(
      onRefresh: refreshTitles,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
        children: [
          Wrap(spacing: 7, runSpacing: 4, children: [
            _filterChip('All', _typeFilter == 'all', () => setState(() => _typeFilter = 'all')),
            _filterChip('Solo', _typeFilter == 'singles', () => setState(() => _typeFilter = 'singles')),
            _filterChip('Tag Team', _typeFilter == 'tag', () => setState(() => _typeFilter = 'tag')),
          ]),
          const SizedBox(height: 4),
          Wrap(spacing: 7, runSpacing: 4, children: [
            _filterChip('All statuses', _championFilter == 'all', () => setState(() => _championFilter = 'all')),
            _filterChip('Avec champion', _championFilter == 'active', () => setState(() => _championFilter = 'active')),
            _filterChip('Vacant', _championFilter == 'vacant', () => setState(() => _championFilter = 'vacant')),
          ]),
          Align(alignment: Alignment.centerRight, child: DropdownButton<String>(
            value: _sortOrder,
            isDense: true,
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name A → Z')),
              DropdownMenuItem(value: 'brand', child: Text('Brand puis nom')),
              DropdownMenuItem(value: 'champion', child: Text('Champion puis nom')),
            ],
            onChanged: (value) => setState(() => _sortOrder = value ?? 'name'),
          )),
          Text('${visibleTitles.length} title(s)', style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
          const SizedBox(height: 8),
          ...visibleTitles.map(_buildTitleCard),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
    label: Text(label), selected: selected, onSelected: (_) => onTap(),
    selectedColor: const Color(0xFF5A171A),
    labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFFBBBBBB), fontSize: 12),
    side: const BorderSide(color: Color(0xFF383838)),
  );

  Widget _buildMessage({
    required IconData icon,
    required String message,
    String? action,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 54,
              color: const Color(0xFF777777),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 16,
              ),
            ),
            if (action != null && onPressed != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onPressed,
                child: Text(action),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitleCard(Titles title) {
    final brand = title.brand;
    final championNames = _getChampionNames(title);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF1B1B1B),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Color(0xFF383838),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openTitleDetails(title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildTitleIcon(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _buildChampions(championNames),
                    if (title.holder1 != null || title.holder2 != null) ...[
                      const SizedBox(height: 7),
                      Row(children: [
                        if (title.holder1 != null) SuperstarAvatar(superstar: title.holder1!, size: 30, radius: 8),
                        if (title.tag == 1 && title.holder2 != null) ...[
                          const SizedBox(width: 5),
                          SuperstarAvatar(superstar: title.holder2!, size: 30, radius: 8),
                        ],
                      ]),
                    ],
                    if (title.tag == 1) ...[
                      const SizedBox(height: 5),
                      _buildTagBadge(),
                    ],
                  ],
                ),
              ),
              if (brand != null) ...[
                const SizedBox(width: 10),
                _buildBrand(brand),
              ],
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF888888),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleIcon() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF351719),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.emoji_events_outlined,
        color: Color(0xFFD71920),
        size: 26,
      ),
    );
  }

  List<String> _getChampionNames(Titles title) {
    final names = <String>[];

    if (title.holder1 != null) {
      names.add(title.holder1!.name);
    }

    if (title.tag == 1 && title.holder2 != null) {
      names.add(title.holder2!.name);
    }

    return names;
  }

  Widget _buildChampions(List<String> names) {
    if (names.isEmpty) {
      return const Row(
        children: [
          Icon(
            Icons.person_outline,
            size: 15,
            color: Color(0xFF888888),
          ),
          SizedBox(width: 5),
          Text(
            'No champion',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(
          Icons.person_outline,
          size: 15,
          color: Color(0xFFD71920),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            names.join(' & '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBBBBBB),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'TAG TEAM',
        style: TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildBrand(Brands brand) {
    final brandName = brand.name.toLowerCase();

    if (brandName == 'raw' ||
        brandName == 'smackdown' ||
        brandName == 'nxt') {
      return SizedBox(
        width: 58,
        height: 42,
        child: Image.asset(
          'assets/$brandName.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildBrandText(brand.name);
          },
        ),
      );
    }

    return SizedBox(
      width: 65,
      child: _buildBrandText(brand.name),
    );
  }

  Widget _buildBrandText(String name) {
    return Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}
