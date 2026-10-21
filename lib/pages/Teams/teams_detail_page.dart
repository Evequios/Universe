import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/pages/Teams/add_edit_teams_page.dart';

class TeamsDetailPage extends StatefulWidget {
  final int teamId;


  const TeamsDetailPage({
    super.key,
    required this.teamId,
  });

  @override
  TeamsDetailPageState createState() => TeamsDetailPageState();
}

class TeamsDetailPageState extends State<TeamsDetailPage> {
  late Teams team;
  late List<Superstars> superstarList;
  Superstars m1 = const Superstars(name: 'name', brand: null, orientation: 'orientation', ally1: null, ally2: null, ally3: null, ally4: null, ally5: null, rival1: null, rival2: null, rival3: null, rival4: null, rival5: null, division: null);
  Superstars m2 = const Superstars(name: 'name', brand: null, orientation: 'orientation', ally1: null, ally2: null, ally3: null, ally4: null, ally5: null, rival1: null, rival2: null, rival3: null, rival4: null, rival5: null, division: null);
  Superstars m3 = const Superstars(name: 'name', brand: null, orientation: 'orientation', ally1: null, ally2: null, ally3: null, ally4: null, ally5: null, rival1: null, rival2: null, rival3: null, rival4: null, rival5: null, division: null);
  Superstars m4 = const Superstars(name: 'name', brand: null, orientation: 'orientation', ally1: null, ally2: null, ally3: null, ally4: null, ally5: null, rival1: null, rival2: null, rival3: null, rival4: null, rival5: null, division: null);
  Superstars m5 = const Superstars(name: 'name', brand: null, orientation: 'orientation', ally1: null, ally2: null, ally3: null, ally4: null, ally5: null, rival1: null, rival2: null, rival3: null, rival4: null, rival5: null, division: null);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshTeam();
  }

  Future refreshTeam() async {
    setState(() => isLoading = true);

    superstarList = await SuperstarsDatabaseHelper.readAllSuperstars();
    team = await TeamsDatabaseHelper.readTeam(widget.teamId);
    m1 = await SuperstarsDatabaseHelper.readSuperstar(team.member1.id!);
    m2 = await SuperstarsDatabaseHelper.readSuperstar(team.member2.id!);
    m3 = await SuperstarsDatabaseHelper.readSuperstar(team.member3.id!);
    m4 = await SuperstarsDatabaseHelper.readSuperstar(team.member4.id!);
    m5 = await SuperstarsDatabaseHelper.readSuperstar(team.member5.id!);

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
                  team.name,
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
        MaterialPageRoute(builder: (context) => AddEditTeamsPage(team: team, listSuperstars: superstarList,),
      ));

      refreshTeam();
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
        await TeamsDatabaseHelper.deleteTeam(widget.teamId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to delete this team ?"),
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