import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLSuperstars.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/AddEditIRLNewsPage.dart';
import 'package:wwe_universe/pages/IRL/IRLSuperstars/AddEditIRLSuperstarsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class IRLSuperstarsDetailPage extends StatefulWidget {
  final IRLSuperstars? irlSuperstars;

  const IRLSuperstarsDetailPage({
    Key? key,
    required this.irlSuperstars,
  }) : super(key: key);

  @override
  _IRLSuperstarsDetailPage createState() => _IRLSuperstarsDetailPage();
}

class _IRLSuperstarsDetailPage extends State<IRLSuperstarsDetailPage> {
  late IRLSuperstars? irlSuperstars = widget.irlSuperstars;
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
              children: [
              Container(
                child: ((){ if(irlSuperstars!.show != 'Aucun') return Image(image: AssetImage('assets/banners/${irlSuperstars!.show.toLowerCase()}.jpg'));}()),
              ),
              SizedBox(height: 10,),
              Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text('${irlSuperstars!.prenom} ${irlSuperstars!.nom}', style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold),),
                SizedBox(height:8),
                Text('${irlSuperstars!.orientation}', style: TextStyle(color: Colors.black, fontSize: 18))]),
            ]),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLSuperstarsPage(irlSuperstars: irlSuperstars),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docIRLSuperstars= FirebaseFirestore.instance.collection('IRLSuperstars').doc(irlSuperstars!.id);
          docIRLSuperstars.delete();
          Navigator.of(context).pop();
        },
  );
}