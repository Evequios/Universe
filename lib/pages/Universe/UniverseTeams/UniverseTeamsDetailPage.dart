import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTeams.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseTeams/AddEditUniverseTeamsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/AddEditUniverseTitlesPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseTeamsDetailPage extends StatefulWidget {
  final int teamId;
  final int? m1Id;
  final int? m2Id;
  final int? m3Id;
  final int? m4Id;
  final int? m5Id;


  const UniverseTeamsDetailPage({
    Key? key,
    required this.teamId,
    this.m1Id,
    this.m2Id,
    this.m3Id,
    this.m4Id,
    this.m5Id,

  }) : super(key: key);

  @override
  _UniverseTeamsDetailPage createState() => _UniverseTeamsDetailPage();
}

class _UniverseTeamsDetailPage extends State<UniverseTeamsDetailPage> {
  UniverseTeams team = UniverseTeams(nom: 'nom', member1: 0, member2: 0, member3: 0, member4: 0, member5: 0);
  UniverseSuperstars m1 = UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars m2 = UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars m3 = UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars m4 = UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars m5 = UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  // late List<UniverseSuperstars> superstarsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshTeam();
  }

  Future refreshTeam() async {
    setState(() => isLoading = true);

    team = await UniverseDatabase.instance.readTeam(widget.teamId);
    m1 = await UniverseDatabase.instance.readSuperstar(widget.m1Id!);
    m2 = await UniverseDatabase.instance.readSuperstar(widget.m2Id!);
    if(widget.m3Id != 0) m3 = await UniverseDatabase.instance.readSuperstar(widget.m3Id!);
    if(widget.m4Id != 0) m4 = await UniverseDatabase.instance.readSuperstar(widget.m4Id!);
    if(widget.m5Id != 0) m5 = await UniverseDatabase.instance.readSuperstar(widget.m5Id!);

    setState(() => isLoading = false);  
  }

  
  int getNbMembres(){
    int n = 2;
    if(widget.m3Id != 0)
      n++;
    if(widget.m4Id != 0)
      n++;
    if(widget.m5Id != 0)
      n++;
    return n;
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
                      team.nom,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text("Members : ${m1.name}, ${m2.name}" + (getNbMembres() >= 3 ? ", ${m3.name}" : "") + (getNbMembres() >= 4 ? ", ${m4.name}" : "") + (getNbMembres() == 5 ? ", ${m5.name}" : ""),
                      style: TextStyle(color: Colors.black, fontSize: 18)
                    ),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseTeamsPage(team: team,),
        ));

        refreshTeam();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteTeam(widget.teamId);
          Navigator.of(context).pop();
        },
      );
}