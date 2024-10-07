import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wwe_universe/classes/matches.dart';
import 'package:wwe_universe/classes/shows.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
// import 'package:wwe_universe/widget/Universe/UniverseMatchesFormWidget.dart';

class AddEditMatchesPage extends StatefulWidget {
  final Matches? match;
  final Shows? show;
  final List<Stipulations>? listStipulations;
  final List<Superstars>? listSuperstars;

  const AddEditMatchesPage({
      super.key,
      this.match,
      this.show,
      this.listStipulations,
      this.listSuperstars});
  @override
  AddEditMatchesPageState createState() => AddEditMatchesPageState();
}

class AddEditMatchesPageState extends State<AddEditMatchesPage> {
  final _formKey = GlobalKey<FormState>();
  late List<Stipulations> listStipulations = [];
  late List<Superstars> listSuperstars = [];
  late List<int> participantsID = [];
  late List<Superstars> listParticipants = [];
  late List<Titles> listTitles = [];
  late int stipulation;
  late int s1;
  late int s2;
  late int s3;
  late int s4;
  late int s5;
  late int s6;
  late int s7;
  late int s8;
  late int winner;
  late int order;
  late int showId;
  late int titleId;
  late ValueChanged<int?> onChangedStipulation;
  late ValueChanged<int?> onChangedS1;
  late ValueChanged<int?> onChangedS2;
  late ValueChanged<int?> onChangedS3;
  late ValueChanged<int?> onChangedS4;
  late ValueChanged<int?> onChangedS5;
  late ValueChanged<int?> onChangedS6;
  late ValueChanged<int?> onChangedS7;
  late ValueChanged<int?> onChangedS8;
  late ValueChanged<int?> onChangedWinner;
  late ValueChanged<String?> onChangedOrder;
  late ValueChanged<int?> onChangedTitleId;
  Titles defaultTitle =
      const Titles(name: 'name', tag: 0, brand: 0, holder1: 0, holder2: 0);
  Stipulations defaultStip =
      const Stipulations(type: 'type', stipulation: 'stipulation');
  Superstars defaultSup = const Superstars(
      name: 'nom',
      brand: 0,
      orientation: 'orientation',
      ally1: 0,
      ally2: 0,
      ally3: 0,
      ally4: 0,
      ally5: 0,
      rival1: 0,
      rival2: 0,
      rival3: 0,
      rival4: 0,
      rival5: 0,
      division: 0);
  Stipulations stip =
      const Stipulations(type: 'type', stipulation: 'stipulation');
  List<String> soloType = [
    '1v1',
    'Triple Threat',
    'Fatal 4-Way',
    '5-Way',
    '6-Way',
    '8-Way',
    '10 Man',
    '20 Man',
    '30 Man'
  ];
  List<String> tagType = [
    '2v2',
    '3v3',
    '4v4',
    '3-Way Tag',
    '4-Way Tag',
    'Handicap 1v2',
    'Handicap 1v3',
    'Handicap 2v3'
  ];
  List<int> team1 = [];
  List<int> team2 = [];
  List<int> team3 = [];
  List<int> team4 = [];
  bool disable2 = false;
  bool disable3 = true;
  bool disable4 = true;
  bool disable5 = true;
  bool disable6 = true;
  bool disable7 = true;
  bool disable8 = true;
  bool isLoading = false;
  bool checkedValue = false;
  late Titles title;

  @override
  void initState() {
    super.initState();

    stipulation = widget.match?.stipulation ?? 0;
    s1 = widget.match?.s1 ?? 0;
    s2 = widget.match?.s2 ?? 0;
    s3 = widget.match?.s3 ?? 0;
    s4 = widget.match?.s4 ?? 0;
    s5 = widget.match?.s5 ?? 0;
    s6 = widget.match?.s6 ?? 0;
    s7 = widget.match?.s7 ?? 0;
    s8 = widget.match?.s8 ?? 0;
    winner = widget.match?.winner ?? 0;
    order = widget.match?.matchOrder ?? 0;
    showId = widget.match?.showId ?? 0;
    titleId = widget.match?.titleId ?? 0;
    listStipulations = widget.listStipulations!;
    listSuperstars = widget.listSuperstars!;
    onChangedStipulation =
        (stipulation) => setState(() => this.stipulation = stipulation!);
    onChangedS1 = (s1) => setState(() {
          for (int s in participantsID) {
            if (s1 == s) {
              participantsID.remove(s);
            }
          }
          this.s1 = s1!;
          participantsID.add(s1);
        });
    onChangedS2 = (s2) => setState(() => this.s2 = s2!);
    onChangedS3 = (s3) => setState(() => this.s3 = s3!);
    onChangedS4 = (s4) => setState(() => this.s4 = s4!);
    onChangedS5 = (s5) => setState(() => this.s5 = s5!);
    onChangedS6 = (s6) => setState(() => this.s6 = s6!);
    onChangedS7 = (s7) => setState(() => this.s7 = s7!);
    onChangedS8 = (s8) => setState(() => this.s8 = s8!);
    onChangedWinner = (winner) => setState(() => this.winner = winner!);
    onChangedOrder = (order) => setState(() => this.order = int.parse(order!));
    onChangedTitleId = (titleId) => setState(() => this.titleId = titleId!);

    // if(stipulation != 0) getDetails(stipulation);
    // winner = 0;
    refreshFields();
  }

  Future refreshFields() async {
    setState(() => isLoading = true);
    listTitles = await TitlesDatabaseHelper.readAllTitles();
    if (stipulation != 0) await getDetails(stipulation);
    winner = 0;
    disable2 = await disable(2);
    disable3 = await disable(3);
    disable4 = await disable(4);
    disable5 = await disable(5);
    disable6 = await disable(6);
    disable7 = await disable(7);
    disable8 = await disable(8);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildStipulation(),
                          const SizedBox(
                            height: 8,
                          ),
                          buildS1(),
                          const SizedBox(
                            height: 8,
                          ),
                          // if (!disable2) buildS2(),
                          // const SizedBox(
                          //   height: 8,
                          // ),
                          // if (!disable3) buildS3(),
                          // const SizedBox(
                          //   height: 8,
                          // ),
                          // if (!disable4) buildS4(),
                          // const SizedBox(
                          //   height: 8,
                          // ),
                          // if (!disable5) buildS5(),
                          // const SizedBox(
                          //   height: 8,
                          // ),
                          // if (!disable6) buildS6(),
                          // const SizedBox(
                          //   height: 8,
                          // ),
                          // if (!disable7) buildS7(),
                          // const SizedBox(
                          //   height: 8,
                          // ),
                          // if (!disable8) buildS8(),
                          // const SizedBox(
                          //   height: 8,
                          // ),
                          // buildWinner(),
                          const SizedBox(
                            height: 8,
                          ),
                          buildOrder(),
                          const SizedBox(height: 8),
                          buildTitleCheckBox(),
                          const SizedBox(
                            height: 8,
                          ),
                          if (checkedValue) buildTitle(),
                        ],
                      ),
                    ),
            ))),
      );

  Widget buildButton() {
    final isFormValid = stipulation != 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseMatches,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseMatches() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.match != null;

      if (isUpdating) {
        await updateUniverseMatches();
      } else {
        await addUniverseMatches();
      }

      if (mounted) Navigator.of(context).pop();
    }
  }

  Future updateUniverseMatches() async {
    final match = widget.match!.copy(
        stipulation: stipulation,
        s1: s1,
        s2: s2,
        s3: s3,
        s4: s4,
        s5: s5,
        s6: s6,
        s7: s7,
        s8: s8,
        winner: winner,
        matchOrder: order,
        showId: widget.show!.id,
        titleId: titleId);

    await MatchesDatabaseHelper.updateMatches(match);

    if (checkedValue) {
      title = await TitlesDatabaseHelper.readTitle(match.titleId!);
      List<int> winners = await getWinnersList();
    }
  }

  Future addUniverseMatches() async {
    final stip = await StipulationsDatabaseHelper.readStipulation(stipulation);
    final match = Matches(
        stipulation: stipulation,
        s1: s1,
        s2: s2,
        s3: stip.type == '1v1' ? 0 : s3,
        s4: stip.type == '1v1' || stip.type == 'Triple Threat' ? 0 : s4,
        s5: stip.type == '1v1' ||
                stip.type == 'Triple Threat' ||
                stip.type == '2v2' ||
                stip.type == 'Fatal 4-Way'
            ? 0
            : s5,
        s6: stip.type == '1v1' ||
                stip.type == 'Triple Threat' ||
                stip.type == '2v2' ||
                stip.type == 'Fatal 4-Way' ||
                stip.type == '5-Way'
            ? 0
            : s6,
        s7: stip.type == '1v1' ||
                stip.type == 'Triple Threat' ||
                stip.type == '2v2' ||
                stip.type == 'Fatal 4-Way' ||
                stip.type == '5-Way' ||
                stip.type == '3v3' ||
                stip.type == '2v2v2' ||
                stip.type == '6-Way'
            ? 0
            : s7,
        s8: stip.type == '1v1' ||
                stip.type == 'Triple Threat' ||
                stip.type == '2v2' ||
                stip.type == 'Fatal 4-Way' ||
                stip.type == '5-Way' ||
                stip.type == '3v3' ||
                stip.type == '2v2v2' ||
                stip.type == '6-Way'
            ? 0
            : s8,
        winner: winner,
        matchOrder: order,
        showId: widget.show!.id,
        titleId: titleId);

    await MatchesDatabaseHelper.createMatch(match);
    if (checkedValue) {
      title = await TitlesDatabaseHelper.readTitle(match.titleId!);
      List<int> winners = await getWinnersList();
      TitlesDatabaseHelper.setChampion(title, winners);
    }
  }

  Widget buildStipulation() => ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Stipulation',
              labelStyle: TextStyle(
                  color: Colors.black87.withOpacity(0.5), fontSize: 18),
              border: const OutlineInputBorder(),
            ),
            value: stipulation != 0 ? stipulation : defaultStip.id,
            onChanged: (stipulation) {
              setState(() {
                this.stipulation = stipulation!;
                refreshFields();
              });
            },
            items: listStipulations.map((stipulation) {
              return DropdownMenuItem(
                value: stipulation.id,
                child: Text('${stipulation.type} ${stipulation.stipulation}'),
              );
            }).toList(),
            validator: (stipulation) =>
                stipulation == null ? "Please choose a match type" : null),
      );

  Widget buildS1() => DropdownSearch<int>(
        popupProps: PopupProps.menu(
          showSelectedItems: false,
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: "Superstar 2",
              labelStyle: TextStyle(
                  color: Colors.black87.withOpacity(0.5), fontSize: 18),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ),
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: "Superstar 1",
            labelStyle:
                TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
            border: const OutlineInputBorder(),
          ),
        ),
        itemAsString: (int? id) {
          final superstar = listSuperstars.firstWhere((s1) => s1.id == id);
          return superstar.name;
        },
        onChanged: (int? value) {
          onChangedS1(value);
        },
        validator: (int? s1) => s1 == null ? "Please choose a superstar" : null,
      );

//   Widget buildS2() => DropdownSearch<int>(
//         popupProps: PopupProps.menu(
//           showSelectedItems: false,
//           showSearchBox: true,
//           searchFieldProps: TextFieldProps(
//             decoration: InputDecoration(
//               labelText: "Superstar 2",
//               labelStyle: TextStyle(
//                   color: Colors.black87.withOpacity(0.5), fontSize: 18),
//               border: const OutlineInputBorder(),
//             ),
//             autofocus: true,
//           ),
//         ),
//         items: listSuperstars.map((s2) => s2.id!).toList(),
//         dropdownDecoratorProps: DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//             labelText: "Superstar 2",
//             labelStyle:
//                 TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
//             border: const OutlineInputBorder(),
//           ),
//         ),
//         itemAsString: (int? id) {
//           final superstar = listSuperstars.firstWhere((s2) => s2.id == id);
//           return superstar.name;
//         },
//         onChanged: (int? value) {
//           onChangedS2(value);
//         },
//         validator: (int? s2) => s2 == null ? "Please choose a superstar" : null,
//       );

//  Widget buildS3() => DropdownSearch<int>(
//         popupProps: PopupProps.menu(
//           showSelectedItems: false,
//           showSearchBox: true,
//           searchFieldProps: TextFieldProps(
//             decoration: InputDecoration(
//               labelText: "Superstar 3",
//               labelStyle: TextStyle(
//                   color: Colors.black87.withOpacity(0.5), fontSize: 18),
//               border: const OutlineInputBorder(),
//             ),
//             autofocus: true,
//           ),
//         ),
//         items: listSuperstars.map((s3) => s3.id!).toList(),
//         dropdownDecoratorProps: DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//             labelText: "Superstar 3",
//             labelStyle:
//                 TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
//             border: const OutlineInputBorder(),
//           ),
//         ),
//         itemAsString: (int? id) {
//           final superstar = listSuperstars.firstWhere((s3) => s3.id == id);
//           return superstar.name;
//         },
//         onChanged: (int? value) {
//           onChangedS3(value);
//         },
//         validator: (int? s3) => s3 == null ? "Please choose a superstar" : null,
//       );

//   Widget buildS4() => DropdownSearch<int>(
//         popupProps: PopupProps.menu(
//           showSelectedItems: false,
//           showSearchBox: true,
//           searchFieldProps: TextFieldProps(
//             decoration: InputDecoration(
//               labelText: "Superstar 4",
//               labelStyle: TextStyle(
//                   color: Colors.black87.withOpacity(0.5), fontSize: 18),
//               border: const OutlineInputBorder(),
//             ),
//             autofocus: true,
//           ),
//         ),
//         items: listSuperstars.map((s4) => s4.id!).toList(),
//         dropdownDecoratorProps: DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//             labelText: "Superstar 4",
//             labelStyle:
//                 TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
//             border: const OutlineInputBorder(),
//           ),
//         ),
//         itemAsString: (int? id) {
//           final superstar = listSuperstars.firstWhere((s4) => s4.id == id);
//           return superstar.name;
//         },
//         onChanged: (int? value) {
//           onChangedS4(value);
//         },
//         validator: (int? s4) => s4 == null ? "Please choose a superstar" : null,
//       );

//   Widget buildS5() => DropdownSearch<int>(
//         popupProps: PopupProps.menu(
//           showSelectedItems: false,
//           showSearchBox: true,
//           searchFieldProps: TextFieldProps(
//             decoration: InputDecoration(
//               labelText: "Superstar 5",
//               labelStyle: TextStyle(
//                   color: Colors.black87.withOpacity(0.5), fontSize: 18),
//               border: const OutlineInputBorder(),
//             ),
//             autofocus: true,
//           ),
//         ),
//         items: listSuperstars.map((s5) => s5.id!).toList(),
//         dropdownDecoratorProps: DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//             labelText: "Superstar 5",
//             labelStyle:
//                 TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
//             border: const OutlineInputBorder(),
//           ),
//         ),
//         itemAsString: (int? id) {
//           final superstar = listSuperstars.firstWhere((s5) => s5.id == id);
//           return superstar.name;
//         },
//         onChanged: (int? value) {
//           onChangedS5(value);
//         },
//         validator: (int? s5) => s5 == null ? "Please choose a superstar" : null,
//       );

//   Widget buildS6() => DropdownSearch<int>(
//         popupProps: PopupProps.menu(
//           showSelectedItems: false,
//           showSearchBox: true,
//           searchFieldProps: TextFieldProps(
//             decoration: InputDecoration(
//               labelText: "Superstar 6",
//               labelStyle: TextStyle(
//                   color: Colors.black87.withOpacity(0.5), fontSize: 18),
//               border: const OutlineInputBorder(),
//             ),
//             autofocus: true,
//           ),
//         ),
//         items: listSuperstars.map((s6) => s6.id!).toList(),
//         dropdownDecoratorProps: DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//             labelText: "Superstar 6",
//             labelStyle:
//                 TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
//             border: const OutlineInputBorder(),
//           ),
//         ),
//         itemAsString: (int? id) {
//           final superstar = listSuperstars.firstWhere((s6) => s6.id == id);
//           return superstar.name;
//         },
//         onChanged: (int? value) {
//           onChangedS6(value);
//         },
//         validator: (int? s6) => s6 == null ? "Please choose a superstar" : null,
//       );

//   Widget buildS7() => DropdownSearch<int>(
//         popupProps: PopupProps.menu(
//           showSelectedItems: false,
//           showSearchBox: true,
//           searchFieldProps: TextFieldProps(
//             decoration: InputDecoration(
//               labelText: "Superstar 7",
//               labelStyle: TextStyle(
//                   color: Colors.black87.withOpacity(0.5), fontSize: 18),
//               border: const OutlineInputBorder(),
//             ),
//             autofocus: true,
//           ),
//         ),
//         items: listSuperstars.map((s7) => s7.id!).toList(),
//         dropdownDecoratorProps: DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//             labelText: "Superstar 7",
//             labelStyle:
//                 TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
//             border: const OutlineInputBorder(),
//           ),
//         ),
//         itemAsString: (int? id) {
//           final superstar = listSuperstars.firstWhere((s7) => s7.id == id);
//           return superstar.name;
//         },
//         onChanged: (int? value) {
//           onChangedS7(value);
//         },
//         validator: (int? s7) => s7 == null ? "Please choose a superstar" : null,
//       );

//   Widget buildS8() => DropdownSearch<int>(
//         popupProps: PopupProps.menu(
//           showSelectedItems: false,
//           showSearchBox: true,
//           searchFieldProps: TextFieldProps(
//             decoration: InputDecoration(
//               labelText: "Superstar 8",
//               labelStyle: TextStyle(
//                   color: Colors.black87.withOpacity(0.5), fontSize: 18),
//               border: const OutlineInputBorder(),
//             ),
//             autofocus: true,
//           ),
//         ),
//         items: listSuperstars.map((s8) => s8.id!).toList(),
//         dropdownDecoratorProps: DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//             labelText: "Superstar 8",
//             labelStyle:
//                 TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
//             border: const OutlineInputBorder(),
//           ),
//         ),
//         itemAsString: (int? id) {
//           final superstar = listSuperstars.firstWhere((s8) => s8.id == id);
//           return superstar.name;
//         },
//         onChanged: (int? value) {
//           onChangedS8(value);
//         },
//         validator: (int? s8) => s8 == null ? "Please choose a superstar" : null,
//       );

//   Widget buildWinner() => DropdownSearch<int>(
//         popupProps: PopupProps.menu(
//           showSelectedItems: false,
//           showSearchBox: true,
//           searchFieldProps: TextFieldProps(
//             decoration: InputDecoration(
//               labelText: "Winner",
//               labelStyle: TextStyle(
//                   color: Colors.black87.withOpacity(0.5), fontSize: 18),
//               border: const OutlineInputBorder(),
//             ),
//             autofocus: true,
//           ),
//         ),
//         items: listSuperstars.map((winner) => winner.id!).toList(),
//         dropdownDecoratorProps: DropDownDecoratorProps(
//           dropdownSearchDecoration: InputDecoration(
//             labelText: "Superstar 8",
//             labelStyle:
//                 TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
//             border: const OutlineInputBorder(),
//           ),
//         ),
//         itemAsString: (int? id) {
//           final superstar = listSuperstars.firstWhere((winner) => winner.id == id);
//           return superstar.name;
//         },
//         onChanged: (int? value) {
//           onChangedWinner(value);
//         },
//         validator: (winner) => validateWinner() ? null : "The winner must be in the match",
//       );

  Widget buildOrder() => TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        initialValue: order == 0 ? '' : order.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        decoration: InputDecoration(
          labelText: 'Order',
          labelStyle:
              TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
          border: const OutlineInputBorder(),
        ),
        validator: (order) =>
            order == null || order.isEmpty ? "The order can't be empty" : null,
        onChanged: onChangedOrder,
      );

  Widget buildTitleCheckBox() => CheckboxListTile(
      title: const Text("Championship match ?"),
      activeColor: Colors.blueGrey,
      value: checkedValue,
      onChanged: (newValue) async {
        setState(() {
          checkedValue ? checkedValue = false : checkedValue = true;
        });
      });

  Widget buildTitle() => ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            labelText: 'Title',
            labelStyle:
                TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
            border: const OutlineInputBorder(),
          ),
          value: titleId != 0 ? titleId : defaultTitle.id,
          onChanged: onChangedTitleId,
          items: listTitles.map((title) {
            return DropdownMenuItem(value: title.id, child: Text(title.name));
          }).toList(),
          validator: (title) =>
              validateWinner() ? null : "The winner must be in the match",
        ),
      );

  Future<List<int>> getWinnersList() async {
    List<int> winners = [];
    if (soloType.contains(stip.type)) {
      return winners = [winner];
    } else {
      switch (stip.type) {
        case '2v2':
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s1))
                  .id!);
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s2))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s3))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s4))
                  .id!);
          break;
        case '3v3':
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s1))
                  .id!);
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s2))
                  .id!);
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s3))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s4))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s5))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s6))
                  .id!);
          break;
        case '4v4':
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s1))
                  .id!);
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s2))
                  .id!);
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s3))
                  .id!);
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s4))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s5))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s6))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s7))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s8))
                  .id!);
          break;
        case '3-Way Tag':
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s1))
                  .id!);
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s2))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s3))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s4))
                  .id!);
          team3.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s5))
                  .id!);
          team3.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s6))
                  .id!);
          break;
        case '4-Way Tag':
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s1))
                  .id!);
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s2))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s3))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s4))
                  .id!);
          team3.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s5))
                  .id!);
          team3.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s6))
                  .id!);
          team4.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s7))
                  .id!);
          team4.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s8))
                  .id!);
          break;
        case 'Handicap 1v2':
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s1))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s2))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s3))
                  .id!);
          break;
        case 'Handicap 1v3':
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s1))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s2))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s3))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s4))
                  .id!);
          break;
        case 'Handicap 2v3':
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s1))
                  .id!);
          team1.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s2))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s3))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s4))
                  .id!);
          team2.add(
              (await SuperstarsDatabaseHelper.readSuperstar(widget.match!.s5))
                  .id!);
          break;
        default:
          break;
      }

      if (team1.contains(widget.match!.winner)) {
        winners = team1;
      } else if (team2.contains(widget.match!.winner)) {
        winners = team2;
      } else if (team3.contains(widget.match!.winner)) {
        winners = team3;
      } else if (team4.contains(widget.match!.winner)) {
        winners = team4;
      }
    }
    return winners;
  }

  bool validateWinner() {
    switch (stip.type) {
      case '10 Man':
      case '20 Man':
      case '30 Man':
        if (winner != s1) {
          return false;
        } else {
          return true;
        }
      case '1v1':
        if (winner != s1 && winner != s2) {
          return false;
        } else {
          return true;
        }
      case 'Triple Threat':
      case 'Handicap 1v2':
        if (winner != s1 && winner != s2 && winner != s3) {
          return false;
        } else {
          return true;
        }
      case '2v2':
      case 'Fatal 4-Way':
      case 'Handicap 1v3':
        if (winner != s1 && winner != s2 && winner != s3 && winner != s4) {
          return false;
        } else {
          return true;
        }
      case '5-Way':
      case 'Handicap 2v3':
        if (winner != s1 &&
            winner != s2 &&
            winner != s3 &&
            winner != s4 &&
            winner != s5) {
          return false;
        } else {
          return true;
        }
      case '3v3':
      case '3-Way Tag':
      case '6-Way':
        if (winner != s1 &&
            winner != s2 &&
            winner != s3 &&
            winner != s4 &&
            winner != s5 &&
            winner != s6) {
          return false;
        } else {
          return true;
        }
      case '8-Way':
      case '4v4':
      case '4-Way Tag':
        if (winner != s1 &&
            winner != s2 &&
            winner != s3 &&
            winner != s4 &&
            winner != s5 &&
            winner != s6 &&
            winner != s7 &&
            winner != s8) {
          return false;
        } else {
          return true;
        }
      default:
        return false;
    }
  }

  Future getDetails(id) async {
    setState(() => isLoading = true);

    stip = await StipulationsDatabaseHelper.readStipulation(id);

    setState(() => isLoading = false);
  }

  Future<bool> disable(int nb) async {
    bool disable = false;
    setState(() => isLoading = true);
    switch (nb) {
      case 1:
        disable = false;
        break;
      case 2:
        stip.type == '10 Man' || stip.type == '20 Man' || stip.type == '30 Man'
            ? disable = true
            : disable = false;
        break;
      case 3:
        stip.type == '10 Man' ||
                stip.type == '20 Man' ||
                stip.type == '30 Man' ||
                stip.type == '1v1'
            ? disable = true
            : disable = false;
        break;
      case 4:
        stip.type == '10 Man' ||
                stip.type == '20 Man' ||
                stip.type == '30 Man' ||
                stip.type == '1v1' ||
                stip.type == 'Triple Threat' ||
                stip.type == 'Handicap 1v2'
            ? disable = true
            : disable = false;
        break;
      case 5:
        stip.type == '10 Man' ||
                stip.type == '20 Man' ||
                stip.type == '30 Man' ||
                stip.type == '1v1' ||
                stip.type == 'Triple Threat' ||
                stip.type == '2v2' ||
                stip.type == 'Fatal 4-Way' ||
                stip.type == 'Handicap 1v2' ||
                stip.type == 'Handicap 1v3'
            ? disable = true
            : disable = false;
        break;
      case 6:
        stip.type == '10 Man' ||
                stip.type == '20 Man' ||
                stip.type == '30 Man' ||
                stip.type == '1v1' ||
                stip.type == 'Triple Threat' ||
                stip.type == '2v2' ||
                stip.type == 'Fatal 4-Way' ||
                stip.type == '5-Way' ||
                stip.type == 'Handicap 1v2' ||
                stip.type == 'Handicap 1v3' ||
                stip.type == 'Handicap 2v3'
            ? disable = true
            : disable = false;
        break;
      case 7:
        stip.type == '10 Man' ||
                stip.type == '20 Man' ||
                stip.type == '30 Man' ||
                stip.type == '1v1' ||
                stip.type == 'Triple Threat' ||
                stip.type == '2v2' ||
                stip.type == 'Fatal 4-Way' ||
                stip.type == '5-Way' ||
                stip.type == 'Handicap 1v2' ||
                stip.type == 'Handicap 1v3' ||
                stip.type == 'Handicap 2v3' ||
                stip.type == '3v3' ||
                stip.type == '3-Way Tag' ||
                stip.type == '6-Way'
            ? disable = true
            : disable = false;
        break;
      case 8:
        stip.type == '10 Man' ||
                stip.type == '20 Man' ||
                stip.type == '30 Man' ||
                stip.type == '1v1' ||
                stip.type == 'Triple Threat' ||
                stip.type == '2v2' ||
                stip.type == 'Fatal 4-Way' ||
                stip.type == '5-Way' ||
                stip.type == 'Handicap 1v2' ||
                stip.type == 'Handicap 1v3' ||
                stip.type == 'Handicap 2v3' ||
                stip.type == '3v3' ||
                stip.type == '3-Way Tag' ||
                stip.type == '6-Way'
            ? disable = true
            : disable = false;
        break;
      default:
        return false;
    }
    return disable;
  }

  Future getListParticipants() async {
    for (int i in participantsID) {
      for (Superstars s in listSuperstars) {
        if (s.id == i) {
          listParticipants.add(s);
          break;
        }
      }
    }
  }

  Future<List<int>> fetchSuperstarIds() async {
  return listSuperstars.map((s1) => s1.id!).toList();
}
}
