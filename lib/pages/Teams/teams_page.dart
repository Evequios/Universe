import 'package:wwe_universe/navbar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/pages/Teams/add_edit_teams_page.dart';
import 'package:wwe_universe/pages/Teams/teams_detail_page.dart';



class TeamsPage extends StatefulWidget{
  const TeamsPage({super.key});

  @override
  TeamsPageState createState() => TeamsPageState();
}

class TeamsPageState extends State<TeamsPage> with AutomaticKeepAliveClientMixin {
  Superstars defaultSuperstar = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  late List<Superstars> superstarsList;
  late List<Teams> teamsList;
  bool isLoading = false;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Teams');
  String searchString = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    refreshTeams();
  }

  Future refreshTeams() async {
    setState(() => isLoading = true);

    teamsList = await TeamsDatabaseHelper.readAllTeams();
    superstarsList = await SuperstarsDatabaseHelper.readAllSuperstars();

    setState(() => isLoading = false);
  }

  void setTeamsList(String search) async {
    setState(() => isLoading = true);

    teamsList = await TeamsDatabaseHelper.readAllTeamsSearch(search);
  
    setState(() => isLoading = false); 
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(
      title: customSearchBar,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (customIcon.icon == Icons.search) {
                customIcon = const Icon(Icons.cancel);
                customSearchBar =  ListTile(
                  leading: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 28,
                  ),
                  title: TextFormField(
                    initialValue: searchString,
                    decoration: const InputDecoration(
                      hintText: "type in team's name...",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    onChanged: (searchString) => ((){this.searchString = searchString; setTeamsList(searchString);}()),
                  ),
                );
              } else {
                  searchString = '';
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Teams');
                  setTeamsList(searchString);
              }
            });
          },
          icon : customIcon,
        ),
      ],
      centerTitle: true,
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
          MaterialPageRoute(builder: (context) => AddEditTeamsPage(listSuperstars: superstarsList)),
        );

        refreshTeams();
      },
    ),
  );
  }

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
            builder: (context) => TeamsDetailPage(teamId: team.id!),
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