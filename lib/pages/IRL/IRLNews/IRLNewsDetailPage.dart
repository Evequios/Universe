import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/AddEditIRLNewsPage.dart';

class IRLNewsDetailPage extends StatefulWidget {
  final IRLNews irlNews;

  const IRLNewsDetailPage({
    Key? key,
    required this.irlNews,
  }) : super(key: key);

  @override
  _IRLNewsDetailPage createState() => _IRLNewsDetailPage();
}

class _IRLNewsDetailPage extends State<IRLNewsDetailPage> {
  late IRLNews? irlNews = widget.irlNews;
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
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      irlNews!.titre,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    Text(
                      irlNews!.texte,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    const SizedBox(height: 20,),
                    Row(children: [
                      Text('${irlNews!.createdTime.toDate().day}/${irlNews!.createdTime.toDate().month}/${irlNews!.createdTime.toDate().year}  ${irlNews!.createdTime.toDate().hour}h${irlNews!.createdTime.toDate().minute.toString().padLeft(2, '0')}'
                      , style: const TextStyle(color:Colors.blueGrey, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(irlNews!.categorie, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color:Colors.blueGrey)),
                    ],)
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLNewsPage(irlNews: irlNews),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          final docIRLNews = FirebaseFirestore.instance.collection('IRLNews').doc(irlNews!.id);
          docIRLNews.delete();
          Navigator.of(context).pop();
        },
      );
}