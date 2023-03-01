import 'package:flutter/material.dart';
import 'package:wwe_universe/main.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/IRLNewsPage.dart';
import 'package:wwe_universe/pages/IRL/IRLShows/IRLShowsPage.dart';
import 'package:wwe_universe/pages/IRL/IRLStorylines/IRLStorylinesPage.dart';
import 'package:wwe_universe/pages/IRL/IRLSuperstars/IRLSuperstarsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseBrands/UniverseBrandsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/UniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/UniverseShowsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/UniverseStorylinesPage.dart';
import 'package:wwe_universe/pages/Settings/SettingsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/UniverseSuperstarsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/UniverseTitlesPage.dart';

class Navbar extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Drawer(
      child: ListView(
        children : [
          ExpansionTile(
            title: const Text('IRL'),
            children: [
              ListTile(
                title : Text('News'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => IRLNewsPage(),));
                }
              ),
              ListTile(
                title : Text('Résultats'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => IRLShowsPage(),));
                }
              ),
              ListTile(
                title : Text('Storylines'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => IRLStorylinesPage(),));
                }
              ),
              ListTile(
                title : Text('Superstars'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => IRLSuperstarsPage(),));
                }
              ),
            ],
            ),
          ExpansionTile(
            title: Text('Universe'),
            children: [
              ListTile(
                title : Text('News'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => UniverseNewsPage(),));
                }
              ),
              ListTile(
                title : Text('Résultats'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => UniverseShowsPage(),));
                }
              ),
              ListTile(
                title : Text('Storylines'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => UniverseStorylinesPage(),));
                }
              ),
              ListTile(
                title : Text('Superstars'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => UniverseSuperstarsPage(),));
                }
              ),
              ListTile(
                title : Text('Brands'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => UniverseBrandsPage(),));
                }
              ),
              ListTile(
                title : Text('Titles'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => UniverseTitlesPage(),));
                }
              ),
            ],
          ),
          const SizedBox(height: 10,),
          const Divider(thickness: 1, height: 10, color: Colors.grey,),
          ListTile(
            title : Icon(Icons.settings),
            onTap:() {
              Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => SettingsPage(),));
            }
          ),
        ]
      )
    );
  }
}