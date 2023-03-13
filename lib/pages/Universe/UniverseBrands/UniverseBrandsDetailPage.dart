import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseBrands/AddEditUniverseBrandsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/UniverseSuperstarsDetailPage.dart';

class UniverseBrandsDetailPage extends StatefulWidget {
  final int brandId;

  const UniverseBrandsDetailPage({
    Key? key,
    required this.brandId,
  }) : super(key: key);

  @override
  _UniverseBrandsDetailPage createState() => _UniverseBrandsDetailPage();
}

class _UniverseBrandsDetailPage extends State<UniverseBrandsDetailPage> {
  late UniverseBrands brand;
  late List<UniverseSuperstars> superstarsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshBrand();
  }

  Future refreshBrand() async {
    setState(() => isLoading = true);

    brand = await UniverseDatabase.instance.readBrand(widget.brandId);
    superstarsList = await UniverseDatabase.instance.readAllSuperstarsFilter(brand.id!);

    setState(() => isLoading = false);  
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        brand.name,
      ),
      actions: [editButton(), deleteButton()],
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


  Widget buildUniverseSuperstars() => ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount: superstarsList.length,
    itemBuilder: (context, index){
      final superstar = superstarsList[index];
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseSuperstarsDetailPage(superstarId: superstar.id!),
          )).then((value) => refreshBrand());
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
        MaterialPageRoute(builder: (context) => AddEditUniverseBrandsPage(brand: brand),)
      );

      refreshBrand();
    });

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
        await UniverseDatabase.instance.deleteBrand(widget.brandId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Text("Are you sure you want to delete this brand ?"),
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