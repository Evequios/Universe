import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/UniverseSuperstarsDetailPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/AddEditUniverseTitlesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/UniverseTitlesReigns.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/UniverseTitlesSetDivisions.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseTitlesDetailPage extends StatefulWidget {
  final int titleId;

  const UniverseTitlesDetailPage({
    Key? key,
    required this.titleId,
    
  }) : super(key: key);

  @override
  _UniverseTitlesDetailPage createState() => _UniverseTitlesDetailPage();
}

class _UniverseTitlesDetailPage extends State<UniverseTitlesDetailPage> {
  UniverseTitles title = const UniverseTitles(name: '', tag: 0, brand: 0, holder1: 0, holder2: 0);
  UniverseBrands brand = const UniverseBrands(name: '');
  UniverseSuperstars h1 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0); 
  UniverseSuperstars h2 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  late List<UniverseBrands> brandsList;
  late List<UniverseSuperstars> superstarsList;
  bool isLoading = false;
  

  @override
  void initState() {
    super.initState();

    refreshTitle();
  }

  Future refreshTitle() async {
    setState(() => isLoading = true);

    title = await UniverseDatabase.instance.readTitle(widget.titleId);
    if(title.brand != 0) brand = await UniverseDatabase.instance.readBrand(title.brand);
    if(title.holder1 != 0) h1 = await UniverseDatabase.instance.readSuperstar(title.holder1);
    if(title.holder2 != 0) h2 = await UniverseDatabase.instance.readSuperstar(title.holder2);
    superstarsList = await UniverseDatabase.instance.readAllSuperstarsDivision(title.id!);
    brandsList = await UniverseDatabase.instance.readAllBrands();

    setState(() => isLoading = false);  
  }



  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Text(
                  title.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                Text("Brand : ${brand.name}",
                  style: const TextStyle(color: Colors.black, fontSize: 18)
                ),
                const SizedBox(height: 8),
                title.tag == 0 && title.holder1 != 0 ?
                Text("Champion : ${h1.name}",
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                )
                :
                title.tag == 1 && title.holder1 != 0 && title.holder2 != 0 ?
                Text("Champions : ${h1.name} & ${h2.name}",
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                )
                : const SizedBox(height: 0),
                const SizedBox(height : 24),
                Material(
                  color: Colors.blueGrey,
                  elevation: 5,
                  borderRadius: BorderRadius.circular(15),
                  child: MaterialButton(
                    
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => UniverseTitlesReigns(titleId: title.id!,)),
                      ).then((value) => refreshTitle());
                    }, 
                    child: const Text("Title history", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),),
                  )
                ),
                SizedBox(height: 8),
                Material(
                  color: Colors.blueGrey,
                  elevation: 5,
                  borderRadius: BorderRadius.circular(15),
                  child: MaterialButton(
                    
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => UniverseTitlesSetDivisions(titleId: title.id!,)),
                      ).then((value) => refreshTitle());
                    }, 
                    child: const Text("Set divisions", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),),
                  )
                ),
                Container(child: buildUniverseSuperstars(),)
              ],
            ),
          ),
  );

  Widget buildUniverseSuperstars() => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding : const EdgeInsets.all(8),
    itemCount: superstarsList.length,
    itemBuilder: (context, index){
      final superstar = superstarsList[index];
      if(superstar.brand != 0) brand = brandsList.firstWhere((brand) => brand.id == superstar.brand);
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseSuperstarsDetailPage(superstarId: superstar.id!),
          )).then((value) => refreshTitle());
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

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    onPressed: () async {

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AddEditUniverseTitlesPage(title: title, listBrands: brandsList, listSuperstars: superstarsList,),
      ));

      refreshTitle();
    }
  );

  Widget deleteButton() => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () async {
      showAlertDialog(context);
    },
  );

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () { 
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed:  () async {
        await UniverseDatabase.instance.deleteTitle(widget.titleId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to delete this title ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}