import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/matches.dart';
import 'package:wwe_universe/classes/shows.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/pages/Matches/add_edit_matches_page.dart';

class MatchesDetailPage extends StatefulWidget {
  final int matchId;
  final int showId;

  const MatchesDetailPage({
    Key? key,
    required this.matchId,
    required this.showId,
  }) : super(key: key);

  @override
  _MatchesDetailPage createState() => _MatchesDetailPage();
}

class _MatchesDetailPage extends State<MatchesDetailPage> {
  late Matches match;
  late Shows show;
  late Stipulations stipulation;
  late Titles title;
  late Superstars s1;
  late Superstars s2;
  late Superstars s3;
  late Superstars s4;
  late Superstars s5;
  late Superstars s6;
  late Superstars s7;
  late Superstars s8;
  late Superstars s9;
  late Superstars s10;
  late Superstars winner;
  late List<Stipulations> stipulationsList;
  late List<Superstars> superstarsList;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshMatches();
  }

  Future refreshMatches() async {
    setState(() => isLoading = true);

    show = await ShowsDatabaseHelper.readShow(widget.showId);
    match = await MatchesDatabaseHelper.readMatch(widget.matchId);
    stipulation = await StipulationsDatabaseHelper.readStipulation(match.stipulation);
    if(match.titleId != 0) title = await TitlesDatabaseHelper.readTitle(match.titleId!);
    s1 = await SuperstarsDatabaseHelper.readSuperstar(match.s1);
    // s2 = await UniverseDatabaseService.instance.readSuperstar(match.s2);
    stipulationsList = await StipulationsDatabaseHelper.readAllStipulations();
    superstarsList = await SuperstarsDatabaseHelper.readAllSuperstars();

    stipulation.type != '10 Man' && stipulation.type != '20 Man' && stipulation.type != '30 Man' ? s2 = await SuperstarsDatabaseHelper.readSuperstar(match.s2) : null;
    stipulation.type != '10 Man' && stipulation.type != '20 Man' && stipulation.type != '30 Man' && stipulation.type != '1v1' ? s3 = await SuperstarsDatabaseHelper.readSuperstar(match.s3) : null;
    stipulation.type != '10 Man' && stipulation.type != '20 Man' && stipulation.type != '30 Man' && stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != 'Handicap 1v2' ? s4 = await SuperstarsDatabaseHelper.readSuperstar(match.s4) : null;
    stipulation.type != '10 Man' && stipulation.type != '20 Man' && stipulation.type != '30 Man' && stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != '2v2' && stipulation.type != 'Fatal 4-Way' && stipulation.type != 'Handicap 1v2' && stipulation.type != 'Handicap 1v3' ? s5 = await SuperstarsDatabaseHelper.readSuperstar(match.s5) : null;
    stipulation.type != '10 Man' && stipulation.type != '20 Man' && stipulation.type != '30 Man' && stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != '2v2' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '5-Way' && stipulation.type != 'Handicap 1v2' && stipulation.type != 'Handicap 1v3' && stipulation.type != 'Handicap 2v3' ? s6 = await SuperstarsDatabaseHelper.readSuperstar(match.s6) : null;
    stipulation.type != '10 Man' && stipulation.type != '20 Man' && stipulation.type != '30 Man' && stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != '2v2' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '5-Way' && stipulation.type != 'Handicap 1v2' && stipulation.type != 'Handicap 1v3' && stipulation.type != 'Handicap 2v3' && stipulation.type != '3v3' && stipulation.type != '3-Way Tag' && stipulation.type != '6-Way' ? s7 = await SuperstarsDatabaseHelper.readSuperstar(match.s7) : null;
    stipulation.type != '10 Man' && stipulation.type != '20 Man' && stipulation.type != '30 Man' && stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != '2v2' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '5-Way' && stipulation.type != 'Handicap 1v2' && stipulation.type != 'Handicap 1v3' && stipulation.type != 'Handicap 2v3' && stipulation.type != '3v3' && stipulation.type != '3-Way Tag' && stipulation.type != '6-Way' ? s8 = await SuperstarsDatabaseHelper.readSuperstar(match.s8) : null;
    winner = await SuperstarsDatabaseHelper.readSuperstar(match.winner);

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
                '${stipulation.type} ${stipulation.stipulation}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(child:(() {
                switch(stipulation.type){
              case '1v1' : 
                return Text('${s1.name} vs ${s2.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              case '2v2' :
                return Text('${s1.name} & ${s2.name} vs ${s3.name} & ${s4.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              case '3v3' : 
                return Text('${s1.name}, ${s2.name}, ${s3.name} vs ${s4.name}, ${s5.name}, ${s6.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              case '4v4' :
                return Text('Team ${s1.name} vs Team ${s6.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              case 'Triple Threat' : 
                return Text('${s1.name} vs ${s2.name} vs ${s3.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              case 'Fatal 4-Way' :
                return Text('${s1.name} vs ${s2.name} vs ${s3.name} vs ${s4.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)); 
              case '5-Way' : 
                return Text('${s1.name} vs ${s2.name} vs ${s3.name} vs ${s4.name} vs ${s5.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)); 
              case '6-Way' :  
                return Text('${s1.name} vs ${s2.name} vs ${s3.name} vs ${s4.name} vs ${s5.name} vs ${s6.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)); 
              case '3-Way Tag' :
                return Text('${s1.name} & ${s2.name} & ${s3.name} vs ${s4.name} & ${s5.name} & ${s6.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)); 
              case '8-Way' :
                return Text('${s1.name} vs ${s2.name} vs ${s3.name} vs ${s4.name} vs ${s5.name} vs ${s6.name} vs ${s7.name} vs ${s8.name}' , textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              case '4-Way Tag' :
                return Text('${s1.name} & ${s2.name} & ${s3.name} vs ${s4.name} & ${s5.name} & ${s6.name} vs ${s7.name} & ${s8.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)); 
              case 'Handicap 1v2' :  
                return Text('${s1.name} vs ${s2.name} & ${s3.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              case 'Handicap 1v3' : 
                return Text('${s1.name} vs ${s2.name} & ${s3.name} & ${s4.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              // case '10 Man' : 
              // case '20 Man' :
              // case '30 Man' :
              //   return Text(winner.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              default :
                return null;
            }
              }())),
              const SizedBox(height: 30,),
              Text('Winner : ${winner.name}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height:8),
              Text('${title.name} Championship',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontStyle: FontStyle.italic
                  ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
  );

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    onPressed: () async {
      if (isLoading) return;

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddEditMatchesPage(match: match, show: show, listStipulations: stipulationsList, listSuperstars: superstarsList),
      ));

    refreshMatches();
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
        await MatchesDatabaseHelper.deleteMatch(widget.matchId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to delete this match ?"),
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