import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/AddEditUniverseTitlesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/UniverseTitlesDetailPage.dart';



class UniverseTitlesPage extends StatefulWidget{
  const UniverseTitlesPage({super.key});

  @override
  _UniverseTitlesPageState createState() => _UniverseTitlesPageState();
}

class _UniverseTitlesPageState extends State<UniverseTitlesPage> with AutomaticKeepAliveClientMixin {
  UniverseBrands defaultBrand = const UniverseBrands(name: 'nom');
  late List<UniverseTitles> titlesList;
  late List<UniverseSuperstars> superstarsList;
  late List<UniverseBrands> brandsList;
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

    titlesList = await UniverseDatabase.instance.readAllTitlesSearch(search);
  
    setState(() => isLoading = false); 
  }

  Future refreshTitles() async {
    setState(() => isLoading = true);

    titlesList = await UniverseDatabase.instance.readAllTitles();
    superstarsList = await UniverseDatabase.instance.readAllSuperstars();
    brandsList = await UniverseDatabase.instance.readAllBrands();

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
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseTitlesPage(listBrands: brandsList, listSuperstars: superstarsList,)),
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
      UniverseBrands brand = defaultBrand;
      if (title.brand != 0) brand = brandsList.firstWhere((brand) => brand.id == title.brand);
      // if (title.holder1 != 0) final h1 = superstarsList.firstWhere((h1) => h1.id == title.holder1);
      // if (title.holder2 != 0) final h2 = superstarsList.firstWhere((h2) => h2.id == title.holder2);
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseTitlesDetailPage(titleId: title.id!),
          )).then((value) => refreshTitles());
        },
        child :SizedBox(
          height: 100,
          child : Card(
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)
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
                  Container(child : ((){ if(title.brand != 0 && (brand.name.toLowerCase() == 'raw' || brand.name.toLowerCase() == 'smackdown' || brand.name.toLowerCase() == 'nxt')) {
                    return Image(image: AssetImage('assets/${brand.name.toLowerCase()}.png'));
                  } else {
                    return Text(brand.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24));
                  }}()))
                ]
              ),
            )
          )
        )
      );
    }
  );
}