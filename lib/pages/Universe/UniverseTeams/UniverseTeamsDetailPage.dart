import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTeams.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseTeams/AddEditUniverseTeamsPage.dart';

class UniverseTeamsDetailPage extends StatefulWidget {
  final int teamId;


  const UniverseTeamsDetailPage({
    Key? key,
    required this.teamId,

  }) : super(key: key);

  @override
  _UniverseTeamsDetailPage createState() => _UniverseTeamsDetailPage();
}

class _UniverseTeamsDetailPage extends State<UniverseTeamsDetailPage> {
  UniverseTeams team = const UniverseTeams(nom: 'nom', member1: 0, member2: 0, member3: 0, member4: 0, member5: 0);
  UniverseSuperstars m1 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars m2 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars m3 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars m4 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars m5 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshTeam();
  }

  Future refreshTeam() async {
    setState(() => isLoading = true);

    team = await UniverseDatabase.instance.readTeam(widget.teamId);
    m1 = await UniverseDatabase.instance.readSuperstar(team.member1);
    m2 = await UniverseDatabase.instance.readSuperstar(team.member2);
    if(team.member3 != 0) m3 = await UniverseDatabase.instance.readSuperstar(team.member3);
    if(team.member4 != 0) m4 = await UniverseDatabase.instance.readSuperstar(team.member4);
    if(team.member5 != 0) m5 = await UniverseDatabase.instance.readSuperstar(team.member5);

    setState(() => isLoading = false);  
  }

  
  int getNbMembres(){
    int n = 2;
    if(team.member3 != 0) {
      n++;
    }
    if(team.member4 != 0) {
      n++;
    }
    if(team.member5 != 0) {
      n++;
    }
    return n;
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
                      team.nom,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    Text("Members : ${m1.name}, ${m2.name}${getNbMembres() >= 3 ? ", ${m3.name}" : ""}${getNbMembres() >= 4 ? ", ${m4.name}" : ""}${getNbMembres() == 5 ? ", ${m5.name}" : ""}",
                      style: const TextStyle(color: Colors.black, fontSize: 18)
                    ),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseTeamsPage(team: team,),
        ));

        refreshTeam();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteTeam(widget.teamId);
          if(context.mounted) Navigator.of(context).pop();
        },
      );
}