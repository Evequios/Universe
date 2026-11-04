import 'package:wwe_universe/navbar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/pages/Superstars/add_edit_superstars_page.dart';
import 'package:wwe_universe/pages/Superstars/superstars_detail_page.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';

class SuperstarsPage extends StatefulWidget{
  const SuperstarsPage({super.key});

  @override
  SuperstarsPageState createState() => SuperstarsPageState();
}

class SuperstarsPageState extends State<SuperstarsPage> with AutomaticKeepAliveClientMixin<SuperstarsPage> {
  late List<Superstars> superstarsList;
  late List<Brands> brandsList;
  bool isLoading = false;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Superstars');
  String searchString = '';
  int _searchRequestId = 0;
  String _sortOrder = 'name';

  List<Superstars> get _visibleSuperstars {
    final rows = [...superstarsList];
    rows.sort((a, b) {
      if (_sortOrder == 'brand') {
        final byBrand = (a.brand?.name ?? '').toLowerCase().compareTo((b.brand?.name ?? '').toLowerCase());
        if (byBrand != 0) return byBrand;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return rows;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    refreshSuperstars();
  }

  Future<void> refreshSuperstars() async {
    final requestId = ++_searchRequestId;
    if (mounted) setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        SuperstarsDatabaseHelper.readAllSuperstarsSearch(searchString),
        BrandsDatabaseHelper.readAllBrands(),
      ]);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        superstarsList = results[0] as List<Superstars>;
        brandsList = results[1] as List<Brands>;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to load Superstars: $error')));
    }
  }

  Future<void> setSuperstarsList(String search) async {
    final requestId = ++_searchRequestId;
    if (mounted) setState(() => isLoading = true);
    try {
      final results = await SuperstarsDatabaseHelper.readAllSuperstarsSearch(search);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() { superstarsList = results.cast<Superstars>(); isLoading = false; });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to search Superstars: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(
      title: customSearchBar,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (customIcon.icon == Icons.search) {
                customIcon = const Icon(Icons.cancel);
                customSearchBar =  ListTile(
                  leading: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 28,
                  ),
                  title: TextFormField(
                    initialValue: searchString,
                    decoration: const InputDecoration(
                      hintText: "type in superstar's name...",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    onChanged: (searchString) => ((){this.searchString = searchString; setSuperstarsList(searchString);}()),
                  ),
                );
              } else {
                  searchString = '';
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Superstars');
                  setSuperstarsList(searchString);
              }
            });
          },
          icon : customIcon,
        ),
      ],
      centerTitle: true,
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : superstarsList.isEmpty
            ? const Center(child: Text('No created superstars'))
            : Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Row(children: [
                    const Text('Sort by: ', style: TextStyle(color: Colors.white70)),
                    DropdownButton<String>(
                      value: _sortOrder,
                      isDense: true,
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Name A → Z')),
                        DropdownMenuItem(value: 'brand', child: Text('Brand then name')),
                      ],
                      onChanged: (value) => setState(() => _sortOrder = value ?? 'name'),
                    ),
                  ]),
                ),
                Expanded(child: buildUniverseSuperstars()),
              ]),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditSuperstarsPage(listBrands: brandsList, listSuperstars: superstarsList,))
        );

        refreshSuperstars();
      },
    ),
  );
  }
  
  Widget buildUniverseSuperstars() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
    itemCount: _visibleSuperstars.length,
    itemBuilder: (context, index) {
      final superstar = _visibleSuperstars[index];
      final brandName = superstar.brand?.name ?? '';
      final normalizedBrand = brandName.toLowerCase();

      final hasBrandLogo = normalizedBrand == 'raw' ||
          normalizedBrand == 'smackdown' ||
          normalizedBrand == 'nxt';



      return Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SuperstarsDetailPage(
                  superstarId: superstar.id!,
                ),
              ),
            );

            if (!mounted) return;
            await refreshSuperstars();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            child: Row(
              children: [
                SuperstarAvatar(superstar: superstar, size: 54, radius: 16),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        superstar.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      if (brandName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF292930),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            brandName.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFCACAD4),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        )
                      else
                        const Text(
                          'NO BRAND',
                          style: TextStyle(
                            color: Color(0xFF8E8E9A),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (hasBrandLogo)
                  SizedBox(
                    width: 48,
                    height: 38,
                    child: Image.asset(
                      'assets/$normalizedBrand.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.sports_mma,
                        color: Color(0xFF8E8E9A),
                        size: 24,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF8E8E9A),
                    size: 26,
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

}
