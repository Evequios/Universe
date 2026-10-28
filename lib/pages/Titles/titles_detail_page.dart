import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/pages/Superstars/superstars_detail_page.dart';
import 'package:wwe_universe/pages/Titles/add_edit_titles_page.dart';

class TitlesDetailPage extends StatefulWidget {
  final int titleId;

  const TitlesDetailPage({
    super.key,
    required this.titleId,
    
  });

  @override
  TitlesDetailPageState createState() => TitlesDetailPageState();
}

class TitlesDetailPageState extends State<TitlesDetailPage> {
  Titles title = const Titles(name: '', tag: 0, brand: null, holder1: null, holder2: null);
  Brands brand = const Brands(name: '');
  Superstars h1 = const Superstars(name: 'nom', brand: null, orientation: 'orientation', division: null); 
  Superstars h2 = const Superstars(name: 'nom', brand: null, orientation: 'orientation', division: null);
  late List<Brands> brandsList;
  late List<Superstars> superstarsList;
  bool isLoading = false;
  

  @override
  void initState() {
    super.initState();

    refreshTitle();
  }

  Future<void> refreshTitle() async {
    setState(() => isLoading = true);

    title = await TitlesDatabaseHelper.readTitle(widget.titleId);

    // Chargement des données liées au titre
    if (title.brand != null) {
      brand = await BrandsDatabaseHelper.readBrand(title.brand!.id!);
    } else {
      brand = const Brands(name: '');
    }

    if (title.holder1 != null) {
      h1 = await SuperstarsDatabaseHelper.readSuperstar(title.holder1!.id!);
    } else {
      h1 = const Superstars(
        name: 'nom',
        brand: null,
        orientation: 'orientation',
        division: null,
      );
    }

    if (title.holder2 != null) {
      h2 = await SuperstarsDatabaseHelper.readSuperstar(title.holder2!.id!);
    } else {
      h2 = const Superstars(
        name: 'nom',
        brand: null,
        orientation: 'orientation',
        division: null,
      );
    }

    // Listes nécessaires au formulaire et à l'affichage
    brandsList = await BrandsDatabaseHelper.readAllBrands();
    superstarsList = await SuperstarsDatabaseHelper.readAllSuperstars();

    if (!mounted) return;
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
                Text(
                  'Brand : ${title.brand?.name ?? "Aucune"}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                const SizedBox(height: 8),
                if (title.tag == 0 && title.holder1 != null)
                Text(
                  'Champion : ${h1.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                )
                else if (title.tag == 1 &&
                    title.holder1 != null &&
                    title.holder2 != null)
                  Text(
                    'Champions : ${h1.name} & ${h2.name}',
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                  ),
                const SizedBox(height : 24),
                Material(
                  color: Colors.blueGrey,
                  elevation: 5,
                  borderRadius: BorderRadius.circular(15),
                  child: MaterialButton(
                    
                    onPressed: () async {
                      
                    }, 
                    child: const Text("Title history", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),),
                  )
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.blueGrey,
                  elevation: 5,
                  borderRadius: BorderRadius.circular(15),
                  child: MaterialButton(
                    
                    onPressed: () async {

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
      final superstarBrand = superstar.brand;
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SuperstarsDetailPage(superstarId: superstar.id!),
          )).then((value) => refreshTitle());
        },
        child :SizedBox(
          height: 100,
          child : Card(
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF30303A)),
              borderRadius: BorderRadius.circular(16.0)
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
                  if (superstarBrand != null)
                  if (['raw', 'smackdown', 'nxt']
                      .contains(superstarBrand.name.toLowerCase()))
                    Image(
                      image: AssetImage(
                        'assets/${superstarBrand.name.toLowerCase()}.png',
                      ),
                    )
                  else
                    Text(
                      superstarBrand.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    )
                else
                  const SizedBox.shrink(),
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
        MaterialPageRoute(builder: (context) => AddEditTitlesPage(title: title, listBrands: brandsList, listSuperstars: superstarsList,),
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
        await TitlesDatabaseHelper.deleteTitle(widget.titleId);
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