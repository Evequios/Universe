import 'dart:math';

import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseDraft/UniverseDraftBrands.dart';

class UniverseTitlesSetDivisions extends StatefulWidget{
  final int titleId;

  const UniverseTitlesSetDivisions({
    super.key,
    required this.titleId
  });

  @override
  _UniverseTitlesSetDivisions createState() => _UniverseTitlesSetDivisions();
}

class _UniverseTitlesSetDivisions extends State<UniverseTitlesSetDivisions> with AutomaticKeepAliveClientMixin<UniverseTitlesSetDivisions> {
  UniverseBrands defaultBrand = const UniverseBrands(name: 'name');
  late List<UniverseSuperstars> superstarsList;
  late List<UniverseBrands> brandsList;
  late UniverseTitles title;
  List<UniverseSuperstars> selectedSuperstars = [];
  
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

    
    brandsList = await UniverseDatabase.instance.readAllBrands();
    title = await UniverseDatabase.instance.readTitle(widget.titleId);
    superstarsList = await UniverseDatabase.instance.readAllSuperstarsFilter(title.brand);

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
            'No superstars in this brand'
          )
        : buildUniverseSuperstars(),
    ),
  );
  }


  Widget buildUniverseSuperstars() => 
    ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount: superstarsList.length,
    itemBuilder: (context, index){
      final superstar = superstarsList[index];
      UniverseBrands brand = defaultBrand;
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
            await UniverseDatabase.instance.setDivision(selectedSuperstars, widget.titleId);
            if(context.mounted) Navigator.of(context).pop();
          }
        },
        child: const Text('Confirm'),
      ),
    );
  }
}
