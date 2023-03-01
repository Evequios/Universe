import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseBrands/AddEditUniverseBrandsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseBrandsDetailPage extends StatefulWidget {
  final int brandId;

  const UniverseBrandsDetailPage({
    Key? key,
    required this.brandId,
  }) : super(key: key);

  @override
  _UniverseBrandsDetailPage createState() => _UniverseBrandsDetailPage();
}

class _UniverseBrandsDetailPage extends State<UniverseBrandsDetailPage> {
  late UniverseBrands brand;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshBrand();
  }

  Future refreshBrand() async {
    setState(() => isLoading = true);

    this.brand = await UniverseDatabase.instance.readBrand(widget.brandId);

    setState(() => isLoading = false);  
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(12),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      brand.nom,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        // if (isLoading) return;

        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseBrandsPage(brand: brand),)
        );

        refreshBrand();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteBrand(widget.brandId);
          Navigator.of(context).pop();
        },
      );
}