import 'package:flutter/material.dart';
import 'package:wwe_universe/main.dart';
import 'package:wwe_universe/pages/IRLNews/IRLNewsPage.dart';
import 'package:wwe_universe/pages/IRLShows/IRLShowsPage.dart';
import 'package:wwe_universe/pages/IRLStorylines/IRLStorylinesPage.dart';
import 'package:wwe_universe/pages/IRLSuperstars/IRLSuperstarsPage.dart';

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
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => Unews(),));
                }
              ),
              ListTile(
                title : Text('Résultats'),
                onTap:() {
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => Uresults(),));
                }
              ),
              ListTile(
                title : Text('Storylines'),
                onTap:() {
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => Ustorylines(),));
                }
              ),
              ListTile(
                title : Text('Superstars'),
                onTap:() {
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => Usuperstars(),));
                }
              ),
            ],
            )
        ]
      )
    );
  }
}