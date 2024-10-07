import 'package:flutter/material.dart';
import 'package:wwe_universe/navbar.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/pages/Brands/add_edit_brands_page.dart';
import 'package:wwe_universe/pages/Brands/brands_detail_page.dart';

class BrandsPage extends StatefulWidget{
  const BrandsPage({super.key});

  @override
  BrandsPageState createState() => BrandsPageState();
}

class BrandsPageState extends State<BrandsPage> {
  late List<Brands> brandsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    
    refreshBrands();
  }

  Future refreshBrands() async {
    setState(() => isLoading = true);

    brandsList = await BrandsDatabaseHelper.readAllBrands();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(
      title: const Text(
        'Brands',
      ), 
      centerTitle: true,
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
          MaterialPageRoute(builder: (context) => const AddEditBrandsPage()),
        );

        refreshBrands();
      },
    ),
   );

  Widget buildUniverseBrands() => ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount:  brandsList.length,
    itemBuilder: (context, index){
      final brand = brandsList[index];
      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BrandsDetailPage(brandId : brand.id!),
          )).then((value) => refreshBrands());
        },
        child : SizedBox(
          height: 100,
          child : Card(
            shape : RoundedRectangleBorder(
              side : const BorderSide(color : Color.fromARGB(189, 96, 125, 139)),
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
                    alignment: Alignment.centerLeft,
                    child: Text(brand.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                  )
                ),
                const Spacer(),
                Container(child : ((){ if(brand.name.toLowerCase() == 'raw' || brand.name.toLowerCase() == 'smackdown' || brand.name.toLowerCase() == 'nxt') return Image(image: AssetImage('assets/${brand.name.toLowerCase()}.png'));}()))
              ],
              )
            ),
          )
        )
      );
    },
  );
}