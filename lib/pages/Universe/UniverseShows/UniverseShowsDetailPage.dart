import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseMatches/AddEditUniverseMatchesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseMatches/UniverseMatchesDetailPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/AddEditUniverseShowsPage.dart';
import 'package:wwe_universe/widget/Universe/UniverseMatchesFormWidget.dart';

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

    this.show = await UniverseDatabase.instance.readShow(widget.showId);
    this.matchesList = await UniverseDatabase.instance.readAllMatches(show.id!);
    this.stipulationsList = await UniverseDatabase.instance.readAllStipulations();
    this.superstarsList = await UniverseDatabase.instance.readAllSuperstars();
    

    setState(() => isLoading = false);  
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Matchs',),
      actions: [editButton(), deleteButton()]
    ),
    body: Column(children: [
      Container(
        padding: EdgeInsets.all(8),
        alignment:  Alignment.centerLeft,
        child: Text('Résumé : ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),)
      ),
      Container(
        width: double.infinity,
        height: 150,
        padding: EdgeInsets.all(8),
        child : Card(
          shape: RoundedRectangleBorder(
            side : new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
            borderRadius: BorderRadius.circular(4.0)
          ),
          elevation: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Text(show.resume != null ? show.resume : ''),
          )
        )
      ),
      SizedBox(height: 8,),
      Container(
        padding: EdgeInsets.all(8),
        alignment: Alignment.centerLeft,
        child : Text('Matchs : ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),)
      ),
      Flexible(
        child: isLoading
          ? const CircularProgressIndicator()
          : matchesList.isEmpty
            ? const Text('No created matches')
            : buildUniverseMatches(),
      )
    ]),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child : const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseMatchesPage(show: show, listStipulations: stipulationsList, listSuperstars: superstarsList,)),
        );

        refreshMatches();
      } ),
  );
  
  Widget buildUniverseMatches() => ListView.builder(
    padding : EdgeInsets.all(8),
    itemCount: matchesList.length,
    itemBuilder: (context, index) {
      final match = matchesList[index];
      final stipulation = stipulationsList.firstWhere((stipulation) => stipulation.id == match.stipulation);
      final s1 = superstarsList.firstWhere((superstar) => superstar.id == match.s1);
      final s2 = superstarsList.firstWhere((superstar) => superstar.id == match.s2);
      UniverseSuperstars s3 = UniverseSuperstars(nom: 'nom', brand: 0, orientation: 'orientation');
      UniverseSuperstars s4 = UniverseSuperstars(nom: 'nom', brand: 0, orientation: 'orientation');
      UniverseSuperstars s5 = UniverseSuperstars(nom: 'nom', brand: 0, orientation: 'orientation');
      UniverseSuperstars s6 = UniverseSuperstars(nom: 'nom', brand: 0, orientation: 'orientation');
      UniverseSuperstars s7 = UniverseSuperstars(nom: 'nom', brand: 0, orientation: 'orientation');
      UniverseSuperstars s8 = UniverseSuperstars(nom: 'nom', brand: 0, orientation: 'orientation');
      if (match.s3 != 0) s3 = superstarsList.firstWhere((superstar) => superstar.id == match.s3);
      if (match.s4 != 0) s4 = superstarsList.firstWhere((superstar) => superstar.id == match.s4);
      if (match.s5 != 0) s5 = superstarsList.firstWhere((superstar) => superstar.id == match.s5);
      if (match.s6 != 0) s6 = superstarsList.firstWhere((superstar) => superstar.id == match.s6);
      if (match.s7 != 0) s7 = superstarsList.firstWhere((superstar) => superstar.id == match.s7);
      if (match.s8 != 0) s8 = superstarsList.firstWhere((superstar) => superstar.id == match.s8);
      final gagnant = superstarsList.firstWhere((superstar) => superstar.id == match.gagnant);

    return Container(
    height: 80,
    child: Card(
      shape:RoundedRectangleBorder(
        side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
        borderRadius: BorderRadius.circular(4.0)
      ),
      elevation : 2,
      child: ListTile(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseMatchesDetailPage(matchId: match.id!, showId: show.id!,),
          )).then((value) => refreshMatches());;
        },
        // title : Text(s1.nom),
        title:((){
          if(stipulation.type == ("1v1")){
            return Text('${s1.nom} vs ${s2.nom}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
          }
          if(stipulation.type == ("2v2")){
            return Text('${s1.nom} & ${s2.nom} vs ${s3.nom} & ${s4.nom}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
          }
          if(stipulation.type == ("3v3")){
            return Text('${s1.nom}, ${s2.nom}, ${s3.nom} vs ${s4.nom}, ${s5.nom}, ${s6.nom}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
          }
          if(stipulation.type == ("4v4")){
            return Text('Team ${s1.nom} vs Team ${s6.nom}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
          }
          if(stipulation.type == ("Triple Threat")){
            return Text('${s1.nom} vs ${s2.nom} vs ${s3.nom}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
          }
          if(stipulation.type == ("Fatal 4-Way")){
            return Text('${s1.nom} vs ${s2.nom} vs ${s3.nom} vs ${s4.nom}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
          }
        }()),
        subtitle: Text('${stipulation.type} ${stipulation.stipulation}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      )
    )
    );
  });

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditUniverseShowsPage(show : show),
        ));

        refreshMatches();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteShow(widget.showId);
          Navigator.of(context).pop();
        },
  );
  
}




