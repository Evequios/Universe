import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRLNews.dart';
import 'package:wwe_universe/classes/IRLShows.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/IRLNews/AddEditIRLNewsPage.dart';
import 'package:wwe_universe/pages/IRLNews/IRLNewsDetailPage.dart';
import 'package:wwe_universe/pages/IRLShows/AddEditIRLShowsPage.dart';
import 'package:wwe_universe/pages/IRLShows/IRLShowsDetailPage.dart';

class IRLShowsPage extends StatefulWidget{
  @override
  _IRLShowsPage createState() => _IRLShowsPage();
}

class _IRLShowsPage extends State<IRLShowsPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: Navbar(),
        appBar: AppBar(
          title: const Text(
            'Shows',
          ),
          actions: [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body: Center(
          child: StreamBuilder<List<IRLShows>>(
            stream: readAllIRLShows(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final irlShows = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(8),
                children: irlShows.map(buildIRLShows).toList()
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
              MaterialPageRoute(builder: (context) => AddEditIRLShowsPage()),
            );
          },
        ),
      );

      Widget buildIRLShows(IRLShows irlShows) {
        String image = 'assets/${irlShows.nom.toLowerCase()}.png';
        return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => IRLShowsDetailPage(irlShows: irlShows),
              ));},
            child:  Container( 
              height: 100,
              child:Card(
              margin: EdgeInsets.all(12),
              elevation: 4,
              child: Padding(
                padding:  const EdgeInsets.symmetric(vertical:8.0, horizontal: 16),
                child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${irlShows.nom} du ${irlShows.date}', style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                        Spacer(),
                        Image(image: AssetImage(image))
                    ],)
            )
            )
          )
        );
  }
  // Widget buildShows() => ListView.builder(
  //       padding: EdgeInsets.all(8),
  //       itemCount: showsList.length,
  //       itemBuilder: (context, index) {
  //         final show = showsList[index];
  //         String image = 'assets/${show.nom.toLowerCase()}.png';

  //         return GestureDetector(
  //           onTap: () async {
  //             await Navigator.of(context).push(MaterialPageRoute(
  //             builder: (context) => IRLShowsDetailPage(IRLShowsId: show.id!),
  //             ));
  //             refreshShows();},
  //           child: Container(
  //             height: 100,
  //             child: Card(
  //               margin: EdgeInsets.all(12),
  //               elevation: 4,
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(vertical:8.0, horizontal: 16),
  //                 child: Row(
  //                   children: [
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Text('${show.nom} du ${show.date}', style: TextStyle(fontWeight: FontWeight.bold),)
  //                       ],),
  //                       Spacer(),
  //                       Image(image: AssetImage(image))
  //                       // CircleAvatar(backgroundImage: AssetImage('assets/raw.png'),)
  //                   ],))
  //           ),
  //           )
  //         );
  //       },
  //     );

  Stream<List<IRLShows>> readAllIRLShows() => 
    FirebaseFirestore.instance.collection('IRLShows').orderBy('date', descending: true).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => IRLShows.fromJson(doc.data())).toList());
}
