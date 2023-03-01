import 'package:flutter/material.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseBrands/AddEditUniverseBrandsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseBrands/UniverseBrandsDetailPage.dart';

class UniverseBrandsPage extends StatefulWidget{
  @override
  _UniverseBrandsPageState createState() => _UniverseBrandsPageState();
}

class _UniverseBrandsPageState extends State<UniverseBrandsPage> {
  late List<UniverseBrands> brandsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    
    refreshBrands();
  }

  Future refreshBrands() async {
    setState(() => isLoading = true);

    this.brandsList = await UniverseDatabase.instance.readAllBrands();

    setState(() => isLoading = false);
  }

   Widget build(BuildContext context) => Scaffold(
    drawer: Navbar(),
    appBar: AppBar(
      title: const Text(
        'Brands',
      ), 
    ),
    body: Center(
      child: isLoading
      ? const CircularProgressIndicator()
      : brandsList.isEmpty
        ? const Text(
            'No created brands'
          )
        : buildUniverseBrands(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseBrandsPage()),
        );

        refreshBrands();
      },
    ),
   );

   Widget buildUniverseBrands() => ListView.builder(
      padding : EdgeInsets.all(8),
      itemCount:  brandsList.length,
      itemBuilder: (context, index){
        final brand = brandsList[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UniverseBrandsDetailPage(brandId : brand.id!),
            )).then((value) => refreshBrands());
          },
          child : Container(
            height: 100,
            child : Card(
              shape : RoundedRectangleBorder(
                side : new BorderSide(color : Color.fromARGB(189, 96, 125, 139)),
                borderRadius: BorderRadius.circular(4.0)
              ),
              elevation: 2,
              child: Padding (
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child : Row (
                  children: [ 
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${brand.nom}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      alignment: Alignment.centerLeft, 
                    )
                  ),
                  Spacer(),
                  Container(child : ((){ if(brand.nom.toLowerCase() == 'raw' || brand.nom.toLowerCase() == 'smackdown' || brand.nom.toLowerCase() == 'nxt') return Image(image: AssetImage('assets/${brand.nom.toLowerCase()}.png'));}()))
                ],
                )
              ),
            )
          )
        );
      },
    );

}