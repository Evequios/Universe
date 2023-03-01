import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLStipulations.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/AddEditIRLNewsPage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/IRLNewsDetailPage.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/IRL/IRLStipulationsPage.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/Universe/UniverseStipulationsPage.dart';
import 'package:wwe_universe/pages/Settings/Titles/IRL/IRLTitlesPage.dart';
// import 'package:wwe_universe/pages/Settings/Titles/Universe/UniverseTitlesPage.dart';

class SettingsPage extends StatefulWidget{
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
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
        'Settings',
      ),
    // actions: const [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child : ListView(
        padding: EdgeInsets.all(8),
        children: [
          GestureDetector( 
            onTap: () async {
              await Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => IRLStipulationsPage(),));
            },
            child :Container(
              height: 100,
              child : Card(
                shape:RoundedRectangleBorder(
                side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
                borderRadius: BorderRadius.circular(4.0)),
                margin: EdgeInsets.all(12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Row(
                    children: [
                      Text('IRL Stipulations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    ],
                  )
                )
              )
            )
          ),


          GestureDetector( 
            onTap: () {
              // await Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => UniverseStipulationsPage(),));
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UniverseStipulationsPage()),
            );
            },
            child :Container(
              height: 100,
              child : Card(
                shape:RoundedRectangleBorder(
                side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
                borderRadius: BorderRadius.circular(4.0)),
                margin: EdgeInsets.all(12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Row(
                    children: [
                      Text('Universe Stipulations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    ],
                  )
                )
              )
            )
          ),

          GestureDetector( 
            onTap: () async {
              await Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => IRLTitlesPage(),));
            },
            child :Container(
              height: 100,
              child : Card(
                shape:RoundedRectangleBorder(
                side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
                borderRadius: BorderRadius.circular(4.0)),
                margin: EdgeInsets.all(12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Row(
                    children: [
                      Text('IRL Titles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    ],
                  )
                )
              )
            )
          ),

          // GestureDetector( 
          //   onTap: () async {
          //     await Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => UniverseTitlesPage(),));
          //   },
          //   child :Container(
          //     height: 100,
          //     child : Card(
          //       shape:RoundedRectangleBorder(
          //       side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
          //       borderRadius: BorderRadius.circular(4.0)),
          //       margin: EdgeInsets.all(12),
          //       elevation: 2,
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          //         child: Row(
          //           children: [
          //             Text('Universe Titles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
          //           ],
          //         )
          //       )
          //     )
          //   )
          // ),
        ]
      )
    ),
  );
}



// child: GestureDetector( 
//             onTap: () async {
//               // await Navigator.of(context).push(
//               //   MaterialPageRoute(builder: (context) => AddEditSettingsPage()),
//               // );
//             },
//             child :Container(
//               height: 100,
//               child : Card(
//                 shape:RoundedRectangleBorder(
//                 side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
//                 borderRadius: BorderRadius.circular(4.0)),
//                 margin: EdgeInsets.all(12),
//                 elevation: 2,
//                 child: Text('test')
//               )
//             ),
//           )