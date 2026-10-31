import 'package:wwe_universe/navbar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/pages/Superstars/add_edit_superstars_page.dart';
import 'package:wwe_universe/pages/Superstars/superstars_detail_page.dart';

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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    refreshSuperstars();
  }

  Future refreshSuperstars() async {
    setState(() => isLoading = true);

    superstarsList = (await SuperstarsDatabaseHelper.readAllSuperstars()).cast<Superstars>();
    brandsList = await BrandsDatabaseHelper.readAllBrands();

    setState(() => isLoading = false);
  }

  void setSuperstarsList(String search) async {
    setState(() => isLoading = true);

    superstarsList = (await SuperstarsDatabaseHelper.readAllSuperstarsSearch(search)).cast<Superstars>();
  
    setState(() => isLoading = false); 
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
    body: Center(
      child: isLoading
        ? const CircularProgressIndicator()
        : superstarsList.isEmpty
          ? const Text(
            'No created superstars'
          )
        : buildUniverseSuperstars(),
    ),
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
    itemCount: superstarsList.length,
    itemBuilder: (context, index) {
      final superstar = superstarsList[index];
      final brandName = superstar.brand?.name ?? '';
      final normalizedBrand = brandName.toLowerCase();

      final hasBrandLogo = normalizedBrand == 'raw' ||
          normalizedBrand == 'smackdown' ||
          normalizedBrand == 'nxt';

      final trimmedName = superstar.name.trim();
      final initials = trimmedName.isEmpty
          ? '?'
          : trimmedName
              .split(RegExp(r'\s+'))
              .map((part) => part[0])
              .take(2)
              .join()
              .toUpperCase();

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
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF35171D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE11D2E).withOpacity(0.55),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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
