import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Brands/brands_page.dart';
import 'package:wwe_universe/pages/Draft/draft_page.dart';
import 'package:wwe_universe/pages/News/news_page.dart';
import 'package:wwe_universe/pages/Settings/settings_page.dart';
import 'package:wwe_universe/pages/Shows/shows_page.dart';
import 'package:wwe_universe/pages/Storylines/storylines_page.dart';
import 'package:wwe_universe/pages/Superstars/superstars_page.dart';
import 'package:wwe_universe/pages/Teams/teams_page.dart';
import 'package:wwe_universe/pages/Titles/titles_page.dart';


class Navbar extends StatelessWidget{
  const Navbar({super.key});

  @override
  Widget build(BuildContext context){
    return Drawer(
      child: ListView(
        children : [
          ExpansionTile(
            title: const Text('Universe'),
            children: [
              ListTile(
                title : const Text('News'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const NewsPage(),));
                }
              ),
              ListTile(
                title : const Text('Results'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const ShowsPage(),));
                }
              ),
              ListTile(
                title : const Text('Storylines'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const StorylinesPage(),));
                }
              ),
              ListTile(
                title : const Text('Superstars'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const SuperstarsPage(),));
                }
              ),
              ListTile(
                title : const Text('Brands'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const BrandsPage(),));
                }
              ),
              ListTile(
                title : const Text('Titles'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const TitlesPage(),));
                }
              ),
              ListTile(
                title : const Text('Teams'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const TeamsPage(),));
                }
              ),
              ListTile(
                title : const Text('Draft'),
                onTap:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const DraftPage(),));
                }
              ),
            ],
          ),
          // const SizedBox(height: 10,),
          const Divider(thickness: 1, height: 0, color: Colors.grey,),
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