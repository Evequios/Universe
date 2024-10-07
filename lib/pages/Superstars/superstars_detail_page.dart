import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/matches.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/pages/Superstars/add_edit_superstars_page.dart';

class SuperstarsDetailPage extends StatefulWidget {
  final int superstarId;

  const SuperstarsDetailPage({
    super.key,
    required this.superstarId,
  });

  @override
  SuperstarsDetailPageState createState() => SuperstarsDetailPageState();
}

class SuperstarsDetailPageState extends State<SuperstarsDetailPage> {
  int wins = 0;
  int losses = 0;
  List<int> team1 = [];
  List<int> team2 = [];
  List<int> team3 = [];
  List<int> team4 = [];
  late Superstars superstar;
  late Brands brand;
  late List<Matches> listMatches;
  late List<Brands> listBrands = [];
  late List<Superstars> listSuperstars = [];
  Brands defaultBrand = const Brands(name: '');
  Superstars ally1 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars ally2 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars ally3 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars ally4 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars ally5 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars rival1 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars rival2 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars rival3 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars rival4 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars rival5 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);

  

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshSuperstars();
  }

  Future refreshSuperstars() async {
    setState(() => isLoading = true);
    
    superstar = await SuperstarsDatabaseHelper.readSuperstar(widget.superstarId);
    if(superstar.ally1 != 0) ally1 = await SuperstarsDatabaseHelper.readSuperstar(superstar.ally1);
    if(superstar.ally2 != 0) ally2 = await SuperstarsDatabaseHelper.readSuperstar(superstar.ally2);
    if(superstar.ally3 != 0) ally3 = await SuperstarsDatabaseHelper.readSuperstar(superstar.ally3);
    if(superstar.ally4 != 0) ally4 = await SuperstarsDatabaseHelper.readSuperstar(superstar.ally4);
    if(superstar.ally5 != 0) ally5 = await SuperstarsDatabaseHelper.readSuperstar(superstar.ally5);

    if(superstar.rival1 != 0) rival1 = await SuperstarsDatabaseHelper.readSuperstar(superstar.rival1);
    if(superstar.rival2 != 0) rival2 = await SuperstarsDatabaseHelper.readSuperstar(superstar.rival2);
    if(superstar.rival3 != 0) rival3 = await SuperstarsDatabaseHelper.readSuperstar(superstar.rival3);
    if(superstar.rival4 != 0) rival4 = await SuperstarsDatabaseHelper.readSuperstar(superstar.rival4);
    if(superstar.rival5 != 0) rival5 = await SuperstarsDatabaseHelper.readSuperstar(superstar.rival5);

    if(superstar.brand != 0) {
      brand = await BrandsDatabaseHelper.readBrand(superstar.brand);
    } 
    else {
      brand = defaultBrand;
    }
    listBrands = await BrandsDatabaseHelper.readAllBrands();
    listSuperstars = await SuperstarsDatabaseHelper.readAllSuperstars();
    listMatches = await MatchesDatabaseHelper.readAllMatchesSuperstar(superstar.id!);

    await getRecord();
    
    setState(() => isLoading = false);  
  }

  Future<int> getRecord() async {
    int w = 0;
    int l = 0;
    late Stipulations stip;
    List<String> soloType = ['1v1', 'Triple Threat', 'Fatal 4-Way', '5-Way', '6-Way', '8-Way', '10 Man', '20 Man', '30 Man'];
    List<String> tagType = ['2v2', '3v3', '4v4', '3-Way Tag', '4-Way Tag', 'Handicap 1v2', 'Handicap 1v3', 'Handicap 2v3'];
    for(Matches m in listMatches){
      stip = await StipulationsDatabaseHelper.readStipulation(m.stipulation);
      switch(stip.type){
        case '2v2':
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s1)).id!);
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s2)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s3)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s4)).id!);
          break;
        case '3v3':
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s1)).id!);
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s2)).id!);
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s3)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s4)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s5)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s6)).id!);
          break;
        case '4v4':
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s1)).id!);
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s2)).id!);
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s3)).id!);
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s4)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s5)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s6)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s7)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s8)).id!);
          break;
        case '3-Way Tag':
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s1)).id!);
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s2)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s3)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s4)).id!);
          team3.add((await SuperstarsDatabaseHelper.readSuperstar(m.s5)).id!);
          team3.add((await SuperstarsDatabaseHelper.readSuperstar(m.s6)).id!);
          break;  
        case '4-Way Tag':
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s1)).id!);
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s2)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s3)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s4)).id!);
          team3.add((await SuperstarsDatabaseHelper.readSuperstar(m.s5)).id!);
          team3.add((await SuperstarsDatabaseHelper.readSuperstar(m.s6)).id!);
          team4.add((await SuperstarsDatabaseHelper.readSuperstar(m.s7)).id!);
          team4.add((await SuperstarsDatabaseHelper.readSuperstar(m.s8)).id!);
          break;
        case 'Handicap 1v2' :
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s1)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s2)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s3)).id!);
          break;
        case'Handicap 1v3' : 
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s1)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s2)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s3)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s4)).id!);
          break;
        case'Handicap 2v3' : 
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s1)).id!);
          team1.add((await SuperstarsDatabaseHelper.readSuperstar(m.s2)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s3)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s4)).id!);
          team2.add((await SuperstarsDatabaseHelper.readSuperstar(m.s5)).id!);
          break; 
        default:
          break;
      }

      if(soloType.contains(stip.type)){
        if(m.winner == superstar.id){
          w++;
        }
        else{
          l++;
        }
      }

      if(tagType.contains(stip.type)){
        int winnerList = 0;
        int superstarList = 0;

        if(team1.contains(m.winner)){
          winnerList = 1;
        }
        else if(team2.contains(m.winner)){
          winnerList = 2;
        }
        else if(team3.contains(m.winner)){
          winnerList = 3;
        }
        else if(team4.contains(m.winner)){
          winnerList = 4;
        }

        if(team1.contains(superstar.id)){
          superstarList = 1;
        }
        else if(team2.contains(superstar.id)){
          superstarList = 2;
        }
        else if(team3.contains(superstar.id)){
          superstarList = 3;
        }
        else if(team4.contains(superstar.id)){
          superstarList = 4;
        }

        if(winnerList == superstarList){
          w++;
        }
        else{
          l++;
        }
      }
    }
    wins = w;
    losses = l;
    return 1;
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
                  'Name : ${superstar.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Brand : ${brand.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Orientation : ${superstar.orientation}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),

                const SizedBox(height: 8),
                superstar.ally1 != 0 ? Text(
                  'Ally 1 : ${ally1.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.ally2 != 0 ? Text(
                  'Ally 2 : ${ally2.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.ally3!= 0 ? Text(
                  'Ally 3 : ${ally3.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.ally4 != 0 ? Text(
                  'Ally 4 : ${ally4.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.ally5 != 0 ? Text(
                  'Ally 5 : ${ally5.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.rival1 != 0 ? Text(
                  'Rival 1 : ${rival1.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),
                const SizedBox(height: 8),

                superstar.rival2 != 0 ? Text(
                  'Rival 2 : ${rival2.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),
                const SizedBox(height: 8),

                superstar.rival3 != 0 ? Text(
                  'Rival 3 : ${rival3.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.rival4 != 0 ? Text(
                  'Rival 4 : ${rival4.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.rival5 != 0 ? Text(
                  'Rival5 : ${rival5.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                Text(
                  'Wins : $wins',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),

                const SizedBox(height: 8),
                Text(
                  'Losses : $losses',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),

              ],
            ),
          ),
  );

  
  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditSuperstarsPage(superstar: superstar, listBrands: listBrands, listSuperstars: listSuperstars,),
        ));

        refreshSuperstars();
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
        await SuperstarsDatabaseHelper.deleteSuperstar(widget.superstarId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to delete this superstar ? Every matches in which this superstar competed will get deleted too and won't count for other superstars stats"),
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