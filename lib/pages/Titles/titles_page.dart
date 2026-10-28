import 'package:wwe_universe/navbar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/pages/Titles/add_edit_titles_page.dart';
import 'package:wwe_universe/pages/Titles/titles_detail_page.dart';



class TitlesPage extends StatefulWidget{
  const TitlesPage({super.key});

  @override
  TitlesPageState createState() => TitlesPageState();
}

class TitlesPageState extends State<TitlesPage> with AutomaticKeepAliveClientMixin {
  Brands defaultBrand = const Brands(name: 'nom');
  late List<Titles> titlesList;
  late List<Superstars> superstarsList;
  late List<Brands> brandsList;
  bool isLoading = false;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Titles');
  String searchString = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    refreshTitles();
  }

  void setTitlesList(String search) async {
    setState(() => isLoading = true);

    titlesList = await TitlesDatabaseHelper.readAllTitlesSearch(search);
  
    setState(() => isLoading = false); 
  }

  Future refreshTitles() async {
    setState(() => isLoading = true);

    titlesList = await TitlesDatabaseHelper.readAllTitles();
    superstarsList = await SuperstarsDatabaseHelper.readAllSuperstars();
    brandsList = await BrandsDatabaseHelper.readAllBrands();

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
                      hintText: "type in title name...",
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
                    onChanged: (searchString) => ((){this.searchString = searchString; setTitlesList(searchString);}()),
                  ),
                );
              } else {
                  searchString = '';
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Titles');
                  setTitlesList(searchString);
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
        : titlesList.isEmpty
          ? const Text(
            'No created titles'
          )
        : buildUniverseTitles(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditTitlesPage(listBrands: brandsList, listSuperstars: superstarsList,)),
        );

        refreshTitles();
      },
    ),
  );
  }

  Widget buildUniverseTitles() => ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount: titlesList.length,
    itemBuilder: (context, index){
      final title = titlesList[index];
      final brand = title.brand;
      // if (title.holder1 != 0) final h1 = superstarsList.firstWhere((h1) => h1.id == title.holder1);
      // if (title.holder2 != 0) final h2 = superstarsList.firstWhere((h2) => h2.id == title.holder2);
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TitlesDetailPage(titleId: title.id!),
          )).then((value) => refreshTitles());
        },
        child :SizedBox(
          height: 100,
          child : Card(
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF30303A)),
              borderRadius: BorderRadius.circular(16.0)
            ),
            elevation: 2,
            child: Padding(    
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(title.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                    )
                  ),
                  const Spacer(),
                  if (brand != null)
                  Container(
                    child: (() {
                      final brandName = brand.name.toLowerCase();

                      if (brandName == 'raw' ||
                          brandName == 'smackdown' ||
                          brandName == 'nxt') {
                        return Image(
                          image: AssetImage('assets/$brandName.png'),
                        );
                      }

                      return Text(
                        brand.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      );
                    }()),
                  )
                else
                  const SizedBox.shrink(),
                ]
              ),
            )
          )
        )
      );
    }
  );
}