import 'dart:math';

import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseDraft/UniverseDraftBrands.dart';

class UniverseDraftPage extends StatefulWidget{
  const UniverseDraftPage({super.key});

  @override
  _UniverseDraftPage createState() => _UniverseDraftPage();
}

class _UniverseDraftPage extends State<UniverseDraftPage> with AutomaticKeepAliveClientMixin<UniverseDraftPage> {
  UniverseBrands defaultBrand = const UniverseBrands(name: 'name');
  bool randomize = false;
  late List<UniverseSuperstars> superstarsList;
  late List<UniverseBrands> brandsList;
  List<UniverseSuperstars> selectedSuperstars = [];
  bool selectAll = false;
  bool isLoading = false;
  
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
      actions: [buildUnselectAll(),buildSelectAll(),buildButton()],
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
      child: const FittedBox(child : Text('Randomize')),
      onPressed: () {
        setState(() {
          randomize = true;
          selectAll = false;
          selectedSuperstars = [];
        });
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
      int setRandom;
      if(randomize == true) {
        Random r = Random();
        setRandom = 0 + r.nextInt(2);
        print(setRandom);
        if(setRandom == 1){
          selectedSuperstars.add(superstar);
        }
      }
      else{
        if(selectAll == true) selectedSuperstars.add(superstar);
      }
      if(superstar.brand != 0) brand = brandsList.firstWhere((brand) => brand.id == superstar.brand);
      return GestureDetector( 
        onTap: () {
          setState(() {
            if(selectedSuperstars.contains(superstar)){
              randomize = false;
              selectedSuperstars.remove(superstar);
              selectAll = false;
            }
            else{
              randomize = false;
              selectedSuperstars.add(superstar);
            }
          });
        },
        child :SizedBox(
          height: 100,
          child : Card(
            color: selectAll == true ? const Color.fromARGB(189, 96, 125, 139) : selectedSuperstars.contains(superstar) == true ? const Color.fromARGB(189, 96, 125, 139) : Colors.white,
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)
            ),
            elevation: selectAll == true ? 0 : selectedSuperstars.contains(superstar) == true ? 0 : 2,
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
                  Container(child : ((){ if(superstar.brand != 0 && (brand.name.toLowerCase() == 'raw' || brand.name.toLowerCase() == 'smackdown' || brand.name.toLowerCase() == 'nxt')) return Image(image: AssetImage('assets/${brand.name.toLowerCase()}.png'));}()))
                ],
              )
            )
          )
        )
      );
    }
  );

  Widget buildRandom() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
        ),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseDraftBrands(selectedSuperstars : selectedSuperstars),
          ));
        },
        child: const Text('Random'),
      ),
    );
  }

  
  Widget buildUnselectAll() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
        ),
        onPressed: () {
          setState(() {
              randomize = false;
              selectAll = false;
              selectedSuperstars = [];
          });
        },
        child: const Text('Unselect all'),
      ),
    );
  }

  Widget buildSelectAll() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
        ),
        onPressed: () {
          setState(() {
            if(selectAll == true){
              selectAll = false;
            }
            else{
              randomize = false;
              selectAll = true;
              selectedSuperstars = [];
            }
          });
        },
        child: const Text('Select all'),
      ),
    );
  }

  Widget buildButton() {
    final isFormValid = selectedSuperstars.isNotEmpty || selectAll == true || randomize == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: () async {
          if (isFormValid){
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UniverseDraftBrands(selectedSuperstars : selectedSuperstars),
            ));
          }
        },
        child: const Text('Next'),
      ),
    );
  }
}
