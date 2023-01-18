import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/UniverseNewsDetailPage.dart';



class UniverseNewsPage extends StatefulWidget{
  @override
  _UniverseNewsPageState createState() => _UniverseNewsPageState();
}

class _UniverseNewsPageState extends State<UniverseNewsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // backgroundColor: Color.fromARGB(227, 242, 237, 237),
        drawer: Navbar(),
        appBar: AppBar(
          title: const Text(
            'News',
            // style : TextStyle(fontWeight: FontWeight.bold,fontSize: 22)
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
          
        ),
        body: Center(
          child: StreamBuilder<List<UniverseNews>>(
            stream: readAllUniverseNews(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final universeNews = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(12),
                children: universeNews.map(buildUniverseNews).toList()
              ,);
            }
            else{
              return CircularProgressIndicator();
            }
          }),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditUniverseNewsPage()),
            );
          },
        ),
      );

  Widget buildUniverseNews(UniverseNews universeNews) {
  return Card(
            shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UniverseNewsDetailPage(universeNews: universeNews),
              ));
              },
              title: Text(universeNews.titre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Row(
                children: [
                  Text('${universeNews.createdTime.toDate().day}/${universeNews.createdTime.toDate().month}/${universeNews.createdTime.toDate().year}  ${universeNews.createdTime.toDate().hour}h${universeNews.createdTime.toDate().minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color:Colors.blueGrey)
                  ),
                  const Spacer(),
                  Text(universeNews.categorie, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color:Colors.blueGrey)),
                ]),
              // subtitle: Text('${irlNews.createdTime.toDate().day}/${irlNews.createdTime.toDate().month}/${irlNews.createdTime.toDate().year}  ${irlNews.createdTime.toDate().hour}h${irlNews.createdTime.toDate().minute.toString().padLeft(2, '0')}                                      ${irlNews.categorie}'),
              ));
  }

  Stream<List<UniverseNews>> readAllUniverseNews() => 
  FirebaseFirestore.instance.collection('UniverseNews').orderBy('time', descending: true).snapshots().map((snapshot) => 
    snapshot.docs.map((doc) => UniverseNews.fromJson(doc.data())).toList());
}