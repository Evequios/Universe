import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseBrands/AddEditUniverseBrandsPage.dart';

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

    brand = await UniverseDatabase.instance.readBrand(widget.brandId);

    setState(() => isLoading = false);  
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      brand.nom,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseBrandsPage(brand: brand),)
        );

        refreshBrand();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteBrand(widget.brandId);
          if (context.mounted) Navigator.of(context).pop();
        },
      );
}