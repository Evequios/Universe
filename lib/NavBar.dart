import 'package:flutter/material.dart';
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
import 'package:wwe_universe/pages/Universe/UniverseTeams/UniverseTeamsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/UniverseTitlesPage.dart';


class Navbar extends StatelessWidget{
  const Navbar({super.key});

  @override
  Widget build(BuildContext context){
    return Drawer(
      child: ListView(
        children : [
          ExpansionTile(
            title: const Text('IRL'),
            children: [
              ListTile(
                title : const Text('News'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const IRLNewsPage(),));
                }
              ),
              ListTile(
                title : const Text('Résultats'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const IRLShowsPage(),));
                }
              ),
              ListTile(
                title : const Text('Storylines'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const IRLStorylinesPage(),));
                }
              ),
              ListTile(
                title : const Text('Superstars'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const IRLSuperstarsPage(),));
                }
              ),
            ],
            ),
          ExpansionTile(
            title: const Text('Universe'),
            children: [
              ListTile(
                title : const Text('News'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const UniverseNewsPage(),));
                }
              ),
              ListTile(
                title : const Text('Results'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const UniverseShowsPage(),));
                }
              ),
              ListTile(
                title : const Text('Storylines'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const UniverseStorylinesPage(),));
                }
              ),
              ListTile(
                title : const Text('Superstars'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const UniverseSuperstarsPage(),));
                }
              ),
              ListTile(
                title : const Text('Brands'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const UniverseBrandsPage(),));
                }
              ),
              ListTile(
                title : const Text('Titles'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const UniverseTitlesPage(),));
                }
              ),
              ListTile(
                title : const Text('Teams'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const UniverseTeamsPage(),));
                }
              ),
            ],
          ),
          const SizedBox(height: 10,),
          const Divider(thickness: 1, height: 10, color: Colors.grey,),
          ListTile(
            title : const Icon(Icons.settings),
            onTap:() {
              Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const SettingsPage(),));
            }
          ),
        ]
      )
    );
  }
}