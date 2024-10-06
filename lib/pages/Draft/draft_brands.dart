import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/pages/Draft/draft_results.dart';

class DraftBrands extends StatefulWidget{
  final List<Superstars> selectedSuperstars;
  const DraftBrands({super.key, required this.selectedSuperstars });

  @override
  _DraftBrandsState createState() => _DraftBrandsState();
}

class _DraftBrandsState extends State<DraftBrands> {
  late List<Brands> brandsList;
  // late List<UniverseSuperstars> selectedSuperstars;
  List<Brands> selectedBrands = [];
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
    appBar: AppBar(
      title: const Text(
        'Select brands',
      ), 
      actions: [buildButton()],
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
   );

  Widget buildUniverseBrands() => ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount:  brandsList.length,
    itemBuilder: (context, index){
      final brand = brandsList[index];
      return GestureDetector(
         onTap: () {
          setState(() {
            if(selectedBrands.contains(brand)){
              selectedBrands.remove(brand);
            }
            else{
              selectedBrands.add(brand);
            }
          });
        },
        child : SizedBox(
          height: 100,
          child : Card(
            color : selectedBrands.contains(brand) == true ? const Color.fromARGB(189, 96, 125, 139) : Colors.white,
            shape : RoundedRectangleBorder(
              side : const BorderSide(color : Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)
            ),
            elevation: selectedBrands.contains(brand) == true ? 0 : 2,
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

  Widget buildButton() {
    final isFormValid = selectedBrands.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: () async {
          if(isFormValid){
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DraftResults(selectedSuperstars : widget.selectedSuperstars, selectedBrands : selectedBrands),
            ));
          }
        },
        child: const Text('Draft'),
      ),
    );
  }
}