import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/AddEditUniverseSuperstarsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/UniverseSuperstarsDetailPage.dart';

class UniverseSuperstarsPage extends StatefulWidget{
  const UniverseSuperstarsPage({super.key});

  @override
  _UniverseSuperstarsPage createState() => _UniverseSuperstarsPage();
}

class _UniverseSuperstarsPage extends State<UniverseSuperstarsPage> with AutomaticKeepAliveClientMixin<UniverseSuperstarsPage> {
  UniverseBrands defaultBrand = const UniverseBrands(name: 'name');
  late List<UniverseSuperstars> superstarsList;
  late List<UniverseBrands> brandsList;
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

    superstarsList = await UniverseDatabase.instance.readAllSuperstars();
    brandsList = await UniverseDatabase.instance.readAllBrands();

    setState(() => isLoading = false);
  }

  void setSuperstarsList(String search) async {
    setState(() => isLoading = true);

    superstarsList = await UniverseDatabase.instance.readAllSuperstarsSearch(search);
  
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
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseSuperstarsPage(listBrands: brandsList, listSuperstars: superstarsList,))
        );

        refreshSuperstars();
      },
    ),
  );
  }


  Widget buildUniverseSuperstars() => ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount: superstarsList.length,
    itemBuilder: (context, index){
      final superstar = superstarsList[index];
      UniverseBrands brand = defaultBrand; 
      if(superstar.brand != 0) brand = brandsList.firstWhere((brand) => brand.id == superstar.brand);
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseSuperstarsDetailPage(superstarId: superstar.id!),
          )).then((value) => refreshSuperstars());
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
                    flex:10,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(superstar.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                    )
                  ),
                  const Spacer(),
                  Container(child : ((){ if(superstar.brand != 0 && (brand.name.toLowerCase() == 'raw' || brand.name.toLowerCase() == 'smackdown' || brand.name.toLowerCase() == 'nxt')) {
                    return Image(image: AssetImage('assets/${brand.name.toLowerCase()}.png')); 
                  } else {
                    return Text(brand.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24));
                  }}()))
                ],
              )
            )
          )
        )
      );
    }
  );
}
