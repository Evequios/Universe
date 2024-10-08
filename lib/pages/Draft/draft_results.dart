import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'dart:math';

import 'package:wwe_universe/pages/Draft/draft_page.dart';
import 'package:wwe_universe/pages/Superstars/superstars_page.dart';


class DraftResults extends StatefulWidget{
  final List<Superstars> selectedSuperstars;
  final List<Brands> selectedBrands;
  const DraftResults({
    super.key, 
    required this.selectedSuperstars,
    required this.selectedBrands});

  @override
  DraftResultsState createState() => DraftResultsState();
}

class DraftResultsState extends State<DraftResults> {
  List<Superstars> selectedSuperstars = [];
  List<Brands> selectedBrands = [];
  HashMap<int, int> draftResults = HashMap();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    
    refreshResults();
  }

  Future refreshResults() async {
    setState(() => isLoading = true);

    selectedBrands = widget.selectedBrands;
    selectedSuperstars = widget.selectedSuperstars;

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildCancel(), buildReroll(),buildButton()],
      centerTitle: true,
    ),
    body: Center(
      child: isLoading
      ? const CircularProgressIndicator()
      : buildDraftResults(),
    ),
   );

  Widget buildDraftResults() => ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount:  selectedSuperstars.length,
    itemBuilder: (context, index){
      final superstar = selectedSuperstars[index];
      Random r = Random();
      int randomBrand = r.nextInt(selectedBrands.length);
      final brand = selectedBrands[randomBrand];
      draftResults.addAll({superstar.id! : brand.id!});
      return SizedBox(
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
                  flex: 10,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(superstar.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                  )
                ),
                const Spacer(),
                const Icon(Icons.arrow_right_outlined),
                const Spacer(), 
                Container(child : ((){ if(brand.name.toLowerCase() == 'raw' || brand.name.toLowerCase() == 'smackdown' || brand.name.toLowerCase() == 'nxt') {
                  return Image(image: AssetImage('assets/${brand.name.toLowerCase()}.png'));
                } else {
                  return Text(brand.name);
                }}()))
              ],
              )
            ),
          )
      );
    },
  );

  Widget buildCancel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
        ),
        onPressed: () {
          if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const DraftPage(),));
        },
        child: const Text('Cancel'),
      ),
    );
  }

  Widget buildReroll() {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          setState(() {
            
          }); 
        },
        child: const Text('Reroll'),
      ),
    );
  }

  Widget buildButton() {
    final isFormValid = selectedBrands.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: () {
          if(isFormValid){
            showAlertDialog(context);
          }
          
        },
        child: const Text('Confirm'),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () {
        if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const SuperstarsPage(),));
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed:  () async {
        await SuperstarsDatabaseHelper.draft(draftResults);
        if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const SuperstarsPage(),));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to confirm this draft ?"),
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