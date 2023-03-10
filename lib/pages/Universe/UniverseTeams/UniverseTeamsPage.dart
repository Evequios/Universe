import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTeams.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseTeams/AddEditUniverseTeamsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTeams/UniverseTeamsDetailPage.dart';



class UniverseTeamsPage extends StatefulWidget{
  const UniverseTeamsPage({super.key});

  @override
  _UniverseTeamsPageState createState() => _UniverseTeamsPageState();
}

class _UniverseTeamsPageState extends State<UniverseTeamsPage> {
  UniverseSuperstars defaultSuperstar = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
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

    teamsList = await UniverseDatabase.instance.readAllTeams();
    superstarsList = await UniverseDatabase.instance.readAllSuperstars();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const Navbar(),
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
    padding : const EdgeInsets.all(8),
    itemCount: teamsList.length,
    itemBuilder: (context, index){
      final team = teamsList[index];
      // final m1 = superstarsList.firstWhere((m1) => m1.id == team.member1);
      // final m2 = superstarsList.firstWhere((m2) => m2.id == team.member2);
      // if (team.member3 != 0) final m3 = superstarsList.firstWhere((m1) => m1.id == team.member3);
      // if (team.member4 != 0) final m4 = superstarsList.firstWhere((m2) => m2.id == team.member4);
      // if (team.member5 != 0) final m5 = superstarsList.firstWhere((m1) => m1.id == team.member5);
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseTeamsDetailPage(teamId: team.id!),
          )).then((value) => refreshTeams());
        },
        child :SizedBox(
          height: 100,
          child : Card(
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)
            ),
            elevation: 2,
            child: Padding(    
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
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