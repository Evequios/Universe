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

    this.show = await UniverseDatabase.instance.readShow(widget.showId);
    this.match = await UniverseDatabase.instance.readMatch(widget.matchId);
    this.stipulation = await UniverseDatabase.instance.readStipulation(this.match.stipulation);
    this.s1 = await UniverseDatabase.instance.readSuperstar(this.match.s1);
    this.s2 = await UniverseDatabase.instance.readSuperstar(this.match.s2);
    this.stipulationsList = await UniverseDatabase.instance.readAllStipulations();
    this.superstarsList = await UniverseDatabase.instance.readAllSuperstars();

    stipulation.type != '1v1' ? this.s3 = await UniverseDatabase.instance.readSuperstar(this.match.s3) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' ? this.s4 = await UniverseDatabase.instance.readSuperstar(this.match.s4) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '2v2' ? this.s5 = await UniverseDatabase.instance.readSuperstar(this.match.s5) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '2v2' ? this.s6 = await UniverseDatabase.instance.readSuperstar(this.match.s6) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '2v2' && stipulation.type != '3v3' && stipulation.type != '2v2v2' ? this.s7 = await UniverseDatabase.instance.readSuperstar(this.match.s7) : null;
    stipulation.type != '1v1' && stipulation.type != 'Triple Threat' && stipulation.type != 'Fatal 4-Way' && stipulation.type != '2v2' && stipulation.type != '3v3' && stipulation.type != '2v2v2' ?this.s8 = await UniverseDatabase.instance.readSuperstar(this.match.s8) : null;
    this.gagnant = await UniverseDatabase.instance.readSuperstar(this.match.gagnant);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading 
      ? Center(child: CircularProgressIndicator())
      : Padding(
          padding: EdgeInsets.all(12),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 8),
            children: [
              Text(
                '${stipulation.type} ${stipulation.stipulation}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Container(child:(() {
                if(stipulation.type == ("1v1")){
                  return Text('${s1.name} vs ${s2.name}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("2v2")){
                  return Text('${s1.name} & ${s2.name} vs ${s3.name} & ${s4.name}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("3v3")){
                  return Text('${s1.name}, ${s2.name}, ${s3.name} vs ${s4.name}, ${s5.name}, ${s6.name}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("4v4")){
                  return Text('${s1.name}, ${s2.name}, ${s3.name}, ${s4.name} vs ${s5.name}, ${s6.name}, ${s7.name}, ${s8.name}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("Triple Threat")){
                  return Text('${s1.name} vs ${s2.name} vs ${s3.name}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18));
                }
                if(stipulation.type == ("Fatal 4-Way")){
                  return Text('${s1.name} vs ${s2.name} vs ${s3.name} vs ${s4.name}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18));
                }
              }())),
              SizedBox(height: 30,),
              Text('Gagnant : ${gagnant.name}',
                style: TextStyle(
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
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditUniverseMatchesPage(match: match, show: show, listStipulations: stipulationsList, listSuperstars: superstarsList),
        ));

        refreshMatches();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteMatch(widget.matchId);

          Navigator.of(context).pop();
        },
  );
}