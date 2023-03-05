import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTeams.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseTeams/AddEditUniverseTeamsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTeams/UniverseTeamsDetailPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/AddEditUniverseTitlesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/UniverseTitlesDetailPage.dart';



class UniverseTeamsPage extends StatefulWidget{
  @override
  _UniverseTeamsPageState createState() => _UniverseTeamsPageState();
}

class _UniverseTeamsPageState extends State<UniverseTeamsPage> {
  UniverseSuperstars defaultSuperstar = UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  late List<UniverseSuperstars> superstarsList;
  late List<UniverseTeams> teamsList;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshTeams();
  }

  Future refreshTeams() async {
    setState(() => isLoading = true);

    this.teamsList = await UniverseDatabase.instance.readAllTeams();
    this.superstarsList = await UniverseDatabase.instance.readAllSuperstars();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: Navbar(),
    appBar: AppBar(
      title: const Text(
        'Teams',
      ),
    ),
    body: Center(
      child: isLoading
        ? const CircularProgressIndicator()
        : teamsList.isEmpty
          ? const Text(
            'No created teams'
          )
        : buildUniverseTeams(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseTeamsPage(listSuperstars: superstarsList)),
        );

        refreshTeams();
      },
    ),
  );

  Widget buildUniverseTeams() => ListView.builder(
    padding : EdgeInsets.all(8),
    itemCount: teamsList.length,
    itemBuilder: (context, index){
      final team = teamsList[index];
      final m1 = superstarsList.firstWhere((m1) => m1.id == team.member1);
      final m2 = superstarsList.firstWhere((m2) => m2.id == team.member2);
      if (team.member3 != 0) final m3 = superstarsList.firstWhere((m1) => m1.id == team.member3);
      if (team.member4 != 0) final m4 = superstarsList.firstWhere((m2) => m2.id == team.member4);
      if (team.member5 != 0) final m5 = superstarsList.firstWhere((m1) => m1.id == team.member5);
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseTeamsDetailPage(teamId: team.id!, m1Id: team.member1, m2Id: team.member2, m3Id: team.member3, m4Id: team.member4, m5Id: team.member5,),
          )).then((value) => refreshTeams());
        },
        child :Container(
          height: 100,
          child : Card(
            shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)
            ),
              // margin: EdgeInsets.all(12),
            elevation: 2,
            child: Padding(    
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${team.nom}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      alignment: Alignment.centerLeft, 
                    )
                  ),
                ]),
              )
            )
          )
      );
    }
  );
}