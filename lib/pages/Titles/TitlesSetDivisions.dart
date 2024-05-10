import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Brands.dart';
import 'package:wwe_universe/classes/Superstars.dart';
import 'package:wwe_universe/classes/Titles.dart';
import 'package:wwe_universe/database.dart';

class TitlesSetDivisions extends StatefulWidget{
  final int titleId;

  const TitlesSetDivisions({
    super.key,
    required this.titleId
  });

  @override
  _TitlesSetDivisions createState() => _TitlesSetDivisions();
}

class _TitlesSetDivisions extends State<TitlesSetDivisions> with AutomaticKeepAliveClientMixin<TitlesSetDivisions> {
  Brands defaultBrand = const Brands(name: 'name');
  late List<Superstars> superstarsList;
  late List<Superstars> superstarsBrandList;
  late List<Brands> brandsList;
  late Titles title;
  List<Superstars> selectedSuperstars = [];
  bool checkedValue = false;
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

    brandsList = await DatabaseService.instance.readAllBrands();
    title = await DatabaseService.instance.readTitle(widget.titleId);
    superstarsList = await DatabaseService.instance.readAllSuperstars();
    superstarsBrandList = await DatabaseService.instance.readAllSuperstarsFilter(title.brand);
    setState(() => isLoading = false);
  }

  Future switchList() async {
    setState(() => isLoading = true);
    if(checkedValue){
      checkedValue = false;
      superstarsList = await DatabaseService.instance.readAllSuperstars();
    }
    else{
      checkedValue = true; 
      superstarsList = await DatabaseService.instance.readAllSuperstarsFilter(title.brand);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
      :  ListView(
        children: [ 
          CheckboxListTile(
            title: const Text("Brand superstars only"),
            activeColor: Colors.blueGrey,
            value: checkedValue, 
            onChanged: (newValue) async {
              setState(() {
                checkedValue ? checkedValue = false : checkedValue = true;
              });
            }
          ),
          buildUniverseSuperstars(),]
      )
      )
    );
  }


  Widget buildUniverseSuperstars() => 
    ListView.builder(
    physics: const ScrollPhysics(),
    shrinkWrap: true,
    padding : const EdgeInsets.all(8),
    itemCount: checkedValue ? superstarsBrandList.length : superstarsList.length,
    itemBuilder: (context, index){
      final superstar = checkedValue ? superstarsBrandList[index] : superstarsList[index];
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
                  Container(child : ((){ if(superstar.brand != 0 && (brand.name.toLowerCase() == 'raw' || brand.name.toLowerCase() == 'smackdown' || brand.name.toLowerCase() == 'nxt')) return Image(image: AssetImage('assets/${brand.name.toLowerCase()}.png'));}())),
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
            await DatabaseService.instance.setDivision(selectedSuperstars, widget.titleId);
            if(context.mounted) Navigator.of(context).pop();
          }
        },
        child: const Text('Confirm'),
      ),
    );
  }

  
}
