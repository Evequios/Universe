import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/matches.dart';
import 'package:wwe_universe/classes/shows.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/pages/Matches/add_edit_matches_page.dart';
import 'package:wwe_universe/pages/Matches/matches_detail_page.dart';
import 'package:wwe_universe/pages/Shows/add_edit_shows_page.dart';

class ShowsDetailPage extends StatefulWidget {
  final int showId;

  const ShowsDetailPage({
    super.key,
    required this.showId,
  });

  @override
  ShowsDetailPageState createState() => ShowsDetailPageState();
}

class ShowsDetailPageState extends State<ShowsDetailPage> {
  late Shows show;
  late List<Matches> matchesList;
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
    matchesList = await MatchesDatabaseHelper.readAllMatches(show.id!);
    stipulationsList = await StipulationsDatabaseHelper.readAllStipulations();
    superstarsList = await SuperstarsDatabaseHelper.readAllSuperstars();
    
    setState(() => isLoading = false);  
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Matches',),
      actions: [editButton(), deleteButton()]
    ),
    body: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          alignment:  Alignment.centerLeft,
          child: const Text('Summary : ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),)
        ),
        Container(
          width: double.infinity,
          height: 150,
          padding: const EdgeInsets.all(8),
          child : Card(
            shape: RoundedRectangleBorder(
              side : const BorderSide(color: Color(0xFF30303A)),
              borderRadius: BorderRadius.circular(16.0)
            ),
            elevation: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Text(show.summary),
            )
          )
        ),
        const SizedBox(height: 8,),
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child : const Text('Matches : ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),)
        ),
        Flexible(
          child: isLoading
            ? const CircularProgressIndicator()
            : matchesList.isEmpty
              ? const Text('No created matches')
              : buildUniverseMatches(),
        )
      ]
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child : const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditMatchesPage(show: show, listStipulations: stipulationsList, listSuperstars: superstarsList,)),
        );

        refreshMatches();
      } 
    ),
  );
  
  Widget buildUniverseMatches() => ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount: matchesList.length,
    itemBuilder: (context, index) {
      final match = matchesList[index];
      final stipulation = stipulationsList.firstWhere((stipulation) => stipulation.id == match.stipulation.id);
      final s1 = superstarsList.firstWhere((superstar) => superstar.id == match.s1.id);
      final s2 = superstarsList.firstWhere((superstar) => superstar.id == match.s2.id);
      final winner = superstarsList.firstWhere((superstar) => superstar.id == match.winner.id!);

      return SizedBox(
      height: 80,
      child: Card(
        shape:RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF30303A)),
          borderRadius: BorderRadius.circular(16.0)
        ),
        elevation : 2,
        child: ListTile(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MatchesDetailPage(matchId: match.id!, showId: show.id!,),
            )).then((value) => refreshMatches());
          },
          
          title:((){
            switch(stipulation.type){
              case '1v1' : 
                return Text('${s1.name} vs ${s2.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              case '10 Man' : 
              case '20 Man' :
              case '30 Man' :
                return Text(winner.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
              default : 
                return null;
            }
          }()),
          subtitle: Text('${stipulation.type} ${stipulation.stipulation}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        )
      )
      );
    }
  );

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    onPressed: () async {
      if (isLoading) return;

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddEditShowsPage(show : show),
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
        await ShowsDatabaseHelper.deleteShow(widget.showId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to delete this show ? All matches associated with this show will get deleted too."),
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




