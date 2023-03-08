import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLMatches.dart';
import 'package:wwe_universe/classes/IRL/IRLShows.dart';
import 'package:wwe_universe/pages/IRL/IRLMatches/AddEditIRLMatchesPage.dart';

class IRLMatchesDetailPage extends StatefulWidget {
  final IRLMatches irlMatches;
  final IRLShows irlShows;

  const IRLMatchesDetailPage({
    Key? key,
    required this.irlMatches, 
    required this.irlShows,
  }) : super(key: key);

  @override
  _IRLMatchesDetailPage createState() => _IRLMatchesDetailPage();
}

class _IRLMatchesDetailPage extends State<IRLMatchesDetailPage> {
  late IRLMatches? irlMatches = widget.irlMatches;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading ? 
      const Center(child: CircularProgressIndicator())
      : Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Text(
                irlMatches!.stipulation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,              
                ),
              ),
              const SizedBox(height: 8),
              Container(child:(() {
                if(irlMatches!.stipulation.contains("1v1")){
                  return Text('${irlMatches!.s1.trim()} vs ${irlMatches!.s2.trim()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(irlMatches!.stipulation.contains("2v2")){
                  return Text('${irlMatches!.s1.trim()} & ${irlMatches!.s2.trim()} vs ${irlMatches!.s3.trim()} & ${irlMatches!.s4.trim()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(irlMatches!.stipulation.contains("3v3")){
                  return Text('${irlMatches!.s1.trim()}, ${irlMatches!.s2.trim()}, ${irlMatches!.s3.trim()} vs ${irlMatches!.s4.trim()}, ${irlMatches!.s5.trim()}, ${irlMatches!.s6.trim()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(irlMatches!.stipulation.contains("4v4")){
                  return Text('${irlMatches!.s1.trim()}, ${irlMatches!.s2.trim()}, ${irlMatches!.s3.trim()}, ${irlMatches!.s4.trim()} vs ${irlMatches!.s5.trim()}, ${irlMatches!.s6.trim()}, ${irlMatches!.s7.trim()}, ${irlMatches!.s8.trim()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(irlMatches!.stipulation.contains("5v5")){
                  return Text('${irlMatches!.s1.trim()}, ${irlMatches!.s2.trim()}, ${irlMatches!.s3.trim()}, ${irlMatches!.s4.trim()}, ${irlMatches!.s5.trim()} vs ${irlMatches!.s6.trim()}, ${irlMatches!.s7.trim()}, ${irlMatches!.s8.trim()}, ${irlMatches!.s9.trim()}, ${irlMatches!.s10.trim()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(irlMatches!.stipulation.contains("Triple Threat")){
                  return Text('${irlMatches!.s1.trim()} vs ${irlMatches!.s2.trim()} vs ${irlMatches!.s3.trim()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
                if(irlMatches!.stipulation.contains("Fatal 4-Way")){
                  return Text('${irlMatches!.s1.trim()} vs ${irlMatches!.s2.trim()} vs ${irlMatches!.s3.trim()} vs ${irlMatches!.s4.trim()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18));
                }
              }())),
              const SizedBox(height: 30,),
              Text('Gagnant : ${irlMatches!.gagnant}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center
              )      
            ],
          ),
        ),
  );

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    onPressed: () async {
      if (isLoading) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddEditIRLMatchesPage(irlMatches: irlMatches, irlShows: widget.irlShows,),
      ));
    });

  Widget deleteButton() => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () {
      final docIRLMatches= FirebaseFirestore.instance.collection('IRLMatches').doc(irlMatches!.id);
      docIRLMatches.delete();
      Navigator.of(context).pop();
    },
  );
}