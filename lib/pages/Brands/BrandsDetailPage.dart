import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Brands.dart';
import 'package:wwe_universe/classes/Superstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Brands/AddEditBrandsPage.dart';
import 'package:wwe_universe/pages/Superstars/SuperstarsDetailPage.dart';

class BrandsDetailPage extends StatefulWidget {
  final int brandId;

  const BrandsDetailPage({
    Key? key,
    required this.brandId,
  }) : super(key: key);

  @override
  _BrandsDetailPage createState() => _BrandsDetailPage();
}

class _BrandsDetailPage extends State<BrandsDetailPage> {
  late Brands brand;
  late List<Superstars> superstarsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshBrand();
  }

  Future refreshBrand() async {
    setState(() => isLoading = true);

    brand = await DatabaseService.instance.readBrand(widget.brandId);
    superstarsList = await DatabaseService.instance.readAllSuperstarsFilter(brand.id!);

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
        : buildSuperstars(),
    ),      
  );


  Widget buildSuperstars() => ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount: superstarsList.length,
    itemBuilder: (context, index){
      final superstar = superstarsList[index];
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SuperstarsDetailPage(superstarId: superstar.id!),
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
        MaterialPageRoute(builder: (context) => AddEditBrandsPage(brand: brand),)
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
        await DatabaseService.instance.deleteBrand(widget.brandId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to delete this brand ?"),
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