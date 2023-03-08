import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/IRL/IRLStipulationsPage.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/Universe/UniverseStipulationsPage.dart';
// import 'package:wwe_universe/pages/Settings/Titles/Universe/UniverseTitlesPage.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

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
    drawer: const Navbar(),
    appBar: AppBar(
      title: const Text(
        'Settings',
      ),
    ),
    body: Center(
      child : ListView(
        padding: const EdgeInsets.all(8),
        children: [
          GestureDetector( 
            onTap: () async {
              await Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const IRLStipulationsPage(),));
            },
            child :SizedBox(
              height: 100,
              child : Card(
                shape:RoundedRectangleBorder(
                side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
                borderRadius: BorderRadius.circular(4.0)),
                margin: const EdgeInsets.all(12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Row(
                    children: const [
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
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UniverseStipulationsPage()),
            );
            },
            child :SizedBox(
              height: 100,
              child : Card(
                shape:RoundedRectangleBorder(
                side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
                borderRadius: BorderRadius.circular(4.0)),
                margin: const EdgeInsets.all(12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Row(
                    children: const [
                      Text('Universe Stipulations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    ],
                  )
                )
              )
            )
          ),
        ]
      )
    ),
  );
}