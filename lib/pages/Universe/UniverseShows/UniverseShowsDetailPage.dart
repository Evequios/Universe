import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseMatches/AddEditUniverseMatchesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseMatches/UniverseMatchesDetailPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/AddEditUniverseShowsPage.dart';

class UniverseShowsDetailPage extends StatefulWidget {
  final int showId;

  const UniverseShowsDetailPage({
    Key? key,
    required this.showId,
  }) : super(key: key);

  @override
  _UniverseShowsDetailPage createState() => _UniverseShowsDetailPage();
}

class _UniverseShowsDetailPage extends State<UniverseShowsDetailPage> {
  late UniverseShows show;
  late List<UniverseMatches> matchesList;
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
    matchesList = await UniverseDatabase.instance.readAllMatches(show.id!);
    stipulationsList = await UniverseDatabase.instance.readAllStipulations();
    superstarsList = await UniverseDatabase.instance.readAllSuperstars();
    
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
              side : const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)
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
      backgroundColor: Colors.black,
      child : const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseMatchesPage(show: show, listStipulations: stipulationsList, listSuperstars: superstarsList,)),
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
      final stipulation = stipulationsList.firstWhere((stipulation) => stipulation.id == match.stipulation);
      final s1 = superstarsList.firstWhere((superstar) => superstar.id == match.s1);
      UniverseSuperstars s2 = const UniverseSuperstars(name: '', brand: 0, orientation: '', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
      UniverseSuperstars s3 = const UniverseSuperstars(name: '', brand: 0, orientation: '', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
      UniverseSuperstars s4 = const UniverseSuperstars(name: '', brand: 0, orientation: '', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
      UniverseSuperstars s5 = const UniverseSuperstars(name: '', brand: 0, orientation: '', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
      UniverseSuperstars s6 = const UniverseSuperstars(name: '', brand: 0, orientation: '', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
      UniverseSuperstars s7 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
      UniverseSuperstars s8 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
      if (match.s2 != 0) s2 = superstarsList.firstWhere((superstar) => superstar.id == match.s2);
      if (match.s3 != 0) s3 = superstarsList.firstWhere((superstar) => superstar.id == match.s3);
      if (match.s4 != 0) s4 = superstarsList.firstWhere((superstar) => superstar.id == match.s4);
      if (match.s5 != 0) s5 = superstarsList.firstWhere((superstar) => superstar.id == match.s5);
      if (match.s6 != 0) s6 = superstarsList.firstWhere((superstar) => superstar.id == match.s6);
      if (match.s7 != 0) s7 = superstarsList.firstWhere((superstar) => superstar.id == match.s7);
      if (match.s8 != 0) s8 = superstarsList.firstWhere((superstar) => superstar.id == match.s8);
      final winner = superstarsList.firstWhere((superstar) => superstar.id == match.winner);

      return SizedBox(
      height: 80,
      child: Card(
        shape:RoundedRectangleBorder(
          side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
          borderRadius: BorderRadius.circular(4.0)
        ),
        elevation : 2,
        child: ListTile(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UniverseMatchesDetailPage(matchId: match.id!, showId: show.id!,),
            )).then((value) => refreshMatches());
          },
          
          title:((){
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
        builder: (context) => AddEditUniverseShowsPage(show : show),
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
        await UniverseDatabase.instance.deleteShow(widget.showId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Text("Are you sure you want to delete this show ? All matches associated with this show will get deleted too."),
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




