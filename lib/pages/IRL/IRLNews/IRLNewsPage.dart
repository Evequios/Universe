import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/AddEditIRLNewsPage.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/IRLNewsDetailPage.dart';



class IRLNewsPage extends StatefulWidget{
  const IRLNewsPage({super.key});

  @override
  _IRLNewsPageState createState() => _IRLNewsPageState();
}

class _IRLNewsPageState extends State<IRLNewsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: const Navbar(),
        appBar: AppBar(
          title: const Text(
            'News',
          ),
        ),
        body: Center(
          child: StreamBuilder<List<IRLNews>>(
            stream: readAllIRLNews(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final irlNews = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: irlNews.map(buildIRLNews).toList()
              ,);
            }
            else{
              return const CircularProgressIndicator();
            }
          }),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddEditIRLNewsPage()),
            );
          },
        ),
      );

  Widget buildIRLNews(IRLNews irlNews) {
  return Card(
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => IRLNewsDetailPage(irlNews: irlNews),
              ));
              },
              title: Text(irlNews.titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Row(
                children: [
                  Text('${irlNews.createdTime.toDate().day}/${irlNews.createdTime.toDate().month}/${irlNews.createdTime.toDate().year}  ${irlNews.createdTime.toDate().hour}h${irlNews.createdTime.toDate().minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color:Colors.blueGrey)
                  ),
                  const Spacer(),
                  Text(irlNews.categorie, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color:Colors.blueGrey)),
                ]),
              // subtitle: Text('${irlNews.createdTime.toDate().day}/${irlNews.createdTime.toDate().month}/${irlNews.createdTime.toDate().year}  ${irlNews.createdTime.toDate().hour}h${irlNews.createdTime.toDate().minute.toString().padLeft(2, '0')}                                      ${irlNews.categorie}'),
              ));
  }

  Stream<List<IRLNews>> readAllIRLNews() => 
  FirebaseFirestore.instance.collection('IRLNews').orderBy('time', descending: true).snapshots().map((snapshot) => 
    snapshot.docs.map((doc) => IRLNews.fromJson(doc.data())).toList());
}