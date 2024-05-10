import 'dart:math';

import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Brands.dart';
import 'package:wwe_universe/classes/Superstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Draft/DraftBrands.dart';

class DraftPage extends StatefulWidget{
  const DraftPage({super.key});

  @override
  _DraftPage createState() => _DraftPage();
}

class _DraftPage extends State<DraftPage> with AutomaticKeepAliveClientMixin<DraftPage> {
  Brands defaultBrand = const Brands(name: 'name');
  late List<Superstars> superstarsList;
  late List<Brands> brandsList;
  List<Superstars> selectedSuperstars = [];
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

    superstarsList = await DatabaseService.instance.readAllSuperstars();
    brandsList = await DatabaseService.instance.readAllBrands();

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
      onPressed: () async {
        setState(() {
          selectedSuperstars = [];
          Random r = Random();
          for (Superstars s in superstarsList){
            int rand = 0 + r.nextInt(2);
            if(rand == 1){
              selectedSuperstars.add(s);
            }
          }
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
      Brands brand = defaultBrand;
      if(superstar.brand != 0) brand = brandsList.firstWhere((brand) => brand.id == superstar.brand);
      return GestureDetector( 
        onTap: () async {
          setState(() {
            if(selectedSuperstars.contains(superstar)){
              selectedSuperstars.remove(superstar);
            }
            else{
              selectedSuperstars.add(superstar);
            }
          });
        },
        child :SizedBox(
          height: 100,
          child : Card(
            color: selectedSuperstars.contains(superstar) == true ? const Color.fromARGB(189, 96, 125, 139) : Colors.white,
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)
            ),
            elevation: selectedSuperstars.contains(superstar) == true ? 0 : 2,
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

  
  Widget buildUnselectAll() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
        ),
        onPressed: () async {
          setState(() {
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
        onPressed: () async {
          setState(() {
            selectedSuperstars = [];
            selectedSuperstars.addAll(superstarsList);
          });
        },
        child: const Text('Select all'),
      ),
    );
  }

  Widget buildButton() {
    final isFormValid = selectedSuperstars.isNotEmpty;
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
              builder: (context) => DraftBrands(selectedSuperstars : selectedSuperstars),
            ));
          }
        },
        child: const Text('Next'),
      ),
    );
  }
}
