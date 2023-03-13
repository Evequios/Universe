import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseMatches/AddEditUniverseMatchesPage.dart';

class UniverseMatchesDetailPage extends StatefulWidget {
  final int matchId;
  final int showId;

  const UniverseMatchesDetailPage({
    Key? key,
    required this.matchId,
    required this.showId,
  }) : super(key: key);

  @override
  _UniverseMatchesDetailPage createState() => _UniverseMatchesDetailPage();
}

class _UniverseMatchesDetailPage extends State<UniverseMatchesDetailPage> {
  late UniverseMatches match;
  late UniverseShows show;
  late UniverseStipulations stipulation;
  late UniverseSuperstars s1;
  late UniverseSuperstars s2;
  late UniverseSuperstars s3;
  late UniverseSuperstars s4;
  late UniverseSuperstars s5;
  late UniverseSuperstars s6;
  late UniverseSuperstars s7;
  late UniverseSuperstars s8;
  late UniverseSuperstars s9;
  late UniverseSuperstars s10;
  late UniverseSuperstars gagnant;
  late List<UniverseStipulations> stipulationsList;
  late List<UniverseSuperstars> superstarsList;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshMatches();
  }

  Future refreshMatches() async {
    setState(() => isLoading = true);

    show = await UniverseDatabase.instance.readShow(widget.showId);
    match = await UniverseDatabase.instance.readMatch(widget.matchId);
    stipulation = await UniverseDatabase.instance.readStipulation(match.stipulation);
    s1 = await UniverseDatabase.instance.readSuperstar(match.s1);
    s2 = await UniverseDatabase.instance.readSuperstar(match.s2);
    stipulationsList = await UniverseDatabase.instance.readAllStipulations();
    superstarsList = await UniverseDatabase.instance.readAllSuperstars();

    stipulation.type != '1v1' ? s3 = await UniverseDatabase.instance.readSuperstar(match.s3) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' ? s4 = await UniverseDatabase.instance.readSuperstar(match.s4) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '2v2' ? s5 = await UniverseDatabase.instance.readSuperstar(match.s5) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '2v2' ? s6 = await UniverseDatabase.instance.readSuperstar(match.s6) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '2v2' && stipulation.type != '3v3' && stipulation.type != '2v2v2' ? s7 = await UniverseDatabase.instance.readSuperstar(match.s7) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '2v2' && stipulation.type != '3v3' && stipulation.type != '2v2v2' ?s8 = await UniverseDatabase.instance.readSuperstar(match.s8) : null;
    gagnant = await UniverseDatabase.instance.readSuperstar(match.winner);

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
                if(stipulation.type == ("1v1")){
                  return Text('${s1.name} vs ${s2.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("2v2")){
                  return Text('${s1.name} & ${s2.name} vs ${s3.name} & ${s4.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("3v3")){
                  return Text('${s1.name}, ${s2.name}, ${s3.name} vs ${s4.name}, ${s5.name}, ${s6.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("4v4")){
                  return Text('${s1.name}, ${s2.name}, ${s3.name}, ${s4.name} vs ${s5.name}, ${s6.name}, ${s7.name}, ${s8.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("Triple Threat")){
                  return Text('${s1.name} vs ${s2.name} vs ${s3.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("Fatal 4-Way")){
                  return Text('${s1.name} vs ${s2.name} vs ${s3.name} vs ${s4.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
              }())),
              const SizedBox(height: 30,),
              Text('Winner : ${gagnant.name}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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
        builder: (context) => AddEditUniverseMatchesPage(match: match, show: show, listStipulations: stipulationsList, listSuperstars: superstarsList),
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
        await UniverseDatabase.instance.deleteMatch(widget.matchId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Text("Are you sure you want to delete this match ?"),
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