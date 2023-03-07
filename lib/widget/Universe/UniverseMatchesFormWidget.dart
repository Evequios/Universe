import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';

UniverseStipulations defaultStip = const UniverseStipulations(type: 'type', stipulation: 'stipulation');
UniverseSuperstars defaultSup = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
UniverseStipulations stip = const UniverseStipulations(type: 'type', stipulation: 'stipulation');
Future getDetails(id) async {
  stip = await UniverseDatabase.instance.readStipulation(id);
  
}

bool disable(int nb){
  switch(nb){
    case 1 : 
      return false;
    case 2 :
      return false;
    case 3 :
      return stip.type == '1v1' ? true : false;
    case 4 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' ? true : false;
    case 5 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' ? true : false;
    case 6 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' || stip.type == '5-Way' ? true : false;
    case 7 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' || stip.type == '5-Way' || stip.type == '3v3' || stip.type == '2v2v2' || stip.type == '6-Way' ? true : false;
    case 8 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' || stip.type == '5-Way' || stip.type == '3v3' || stip.type == '2v2v2' || stip.type == '6-Way' ? true : false;
    default :
      return true;
    
  }
}


class UniverseMatchesFormWidget extends StatelessWidget {
  final List<UniverseStipulations>? listStipulations;
  final List<UniverseSuperstars>? listSuperstars;
  final int? stipulation;
  final int? s1;
  final int? s2;
  final int? s3;
  final int? s4;
  final int? s5;
  final int? s6;
  final int? s7;
  final int? s8;
  final int? winner;
  final int? order;
  final int? showId;
  final ValueChanged<int?> onChangedStipulation;
  final ValueChanged<int?> onChangedS1;
  final ValueChanged<int?> onChangedS2;
  final ValueChanged<int?> onChangedS3;
  final ValueChanged<int?> onChangedS4;
  final ValueChanged<int?> onChangedS5;
  final ValueChanged<int?> onChangedS6;
  final ValueChanged<int?> onChangedS7;
  final ValueChanged<int?> onChangedS8;
  final ValueChanged<int?> onChangedWinner;
  final ValueChanged<String?> onChangedOrder;

  const UniverseMatchesFormWidget({
    Key? key,
    required this.listStipulations,
    required this.listSuperstars,
    this.stipulation,
    this.s1,
    this.s2,
    this.s3,
    this.s4,
    this.s5,
    this.s6,
    this.s7,
    this.s8,
    this.winner,
    this.order,
    this.showId,

    required this.onChangedStipulation,
    required this.onChangedS1,
    required this.onChangedS2,
    required this.onChangedS3,
    required this.onChangedS4,
    required this.onChangedS5,
    required this.onChangedS6,
    required this.onChangedS7,
    required this.onChangedS8,
    required this.onChangedWinner,
    required this.onChangedOrder,
  }) : super(key: key);
  
  bool validateWinner() {
    switch (stip.type){
    case '1v1' : 
      if(winner != s1 && winner != s2) {
        return false;
      } else {
        return true;
      }
    case 'Triple Threat':
      if(winner != s1 && winner != s2 && winner != s3) {
        return false;
      } else {
        return true;
      }
    case '2v2' :
      if(winner != s1 && winner != s2 && winner != s3 && winner != s4) {
        return false;
      } else {
        return true;
      }
    case 'Fatal 4-Way' :
      if(winner != s1 && winner != s2 && winner != s3 && winner != s4) {
        return false;
      } else {
        return true;
      }
    case '5-Way' :
      if(winner != s1 && winner != s2 && winner != s3 && winner != s4 && winner != s5) {
        return false;
      } else {
        return true;
      }
    case '3v3' :
      if(winner != s1 && winner != s2 && winner != s3 && winner != s4 && winner != s5 && winner != s6) {
        return false;
      } else {
        return true;
      }
    case '2v2v2' :
      if(winner != s1 && winner != s2 && winner != s3 && winner != s4 && winner != s5 && winner != s6) {
        return false;
      } else {
        return true;
      }
    case '6-Way' :
      if(winner != s1 && winner != s2 && winner != s3 && winner != s4 && winner != s5 && winner != s6) {
        return false;
      } else {
        return true;
      }
    case '8-Way' :
      if(winner != s1 && winner != s2 && winner != s3 && winner != s4 && winner != s5 && winner != s6 && winner != s7 && winner != s8) {
        return false;
      } else {
        return true;
      }
    default :
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context){
  return Scaffold(
    body: SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildStipulation(),
              const SizedBox(height: 8,),
              buildS1(),
              const SizedBox(height: 8,),
              buildS2(),
              const SizedBox(height: 8,),
              buildS3(),
              const SizedBox(height: 8,),
              buildS4(),
              const SizedBox(height: 8,),
              buildS5(),
              const SizedBox(height: 8,),
              buildS6(),
              const SizedBox(height: 8,),
              buildS7(),
              const SizedBox(height: 8,),
              buildS8(),
              const SizedBox(height: 8,),
              buildWinner(),
              const SizedBox(height: 8,),
              buildOrder(),
            ],
          ),
        ),
      )
    )
  );
  }

  Widget buildStipulation() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Stipulation: ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Stipulation"),
        value: stipulation != 0 ? stipulation : defaultStip.id,
        onChanged: onChangedStipulation,
        items: listStipulations!.map((stipulation){
        return DropdownMenuItem(
          value: stipulation.id,
          child: Text('${stipulation.type} ${stipulation.stipulation}'),
        );
      }).toList(),
      validator: (stipulation) =>
           stipulation == null ? "Please choose a match type" : null
      ),
    );


  Widget buildS1() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Superstar 1 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Superstar 1"),
        value: s1 != 0 ? s1 : defaultSup.id,
        onChanged: onChangedS1,
        items: disable(1) ? null : listSuperstars!.map((s1){
        return DropdownMenuItem(
          value: s1.id,
          child: Text(s1.name));
      }).toList(),
      validator: (s1) =>
           s1 == null ? "Please choose a superstar" : null
      ),
    );

  Widget buildS2() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Superstar 2 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Superstar 2"),
        value: s2 != 0 ? s2 : defaultSup.id,
        onChanged: onChangedS2,
        items: disable(2) ? null : listSuperstars!.map((s2){
        return DropdownMenuItem(
          value: s2.id,
          child: Text(s2.name));
      }).toList(),
      validator: (s2) =>
           s2 == null ? "Please choose a superstar" : null
      ),
    );


    Widget buildS3() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Superstar 3 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Superstar 3"),
        onChanged: onChangedS3,
        items: disable(3) ? null : listSuperstars!.map((s3){
        return DropdownMenuItem(
          value: s3.id,
          child: Text(s3.name));
      }).toList(),
      ),
    );

    Widget buildS4() =>
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Superstar 4 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Superstar 4"),
        onChanged: onChangedS4,
        items: disable(4) ? null : listSuperstars!.map((s4){
        return DropdownMenuItem(
          value: s4.id,
          child: Text(s4.name));
      }).toList(),
      ),
    );

  Widget buildS5() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Superstar 5 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Superstar 5"),
        onChanged: onChangedS5,
        items: disable(5) ? null : listSuperstars!.map((s5){
        return DropdownMenuItem(
          value: s5.id,
          child: Text(s5.name));
      }).toList(),
      ),
    );

      Widget buildS6() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Superstar 6 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Superstar 6"),
        onChanged: onChangedS6,
        items: disable(6) ? null : listSuperstars!.map((s6){
        return DropdownMenuItem(
          value: s6.id,
          child: Text(s6.name));
      }).toList(),
      ),
    );

    Widget buildS7() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Superstar 7 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Superstar 7"),
        onChanged: onChangedS7,
        items: disable(7) ? null : listSuperstars!.map((s7){
        return DropdownMenuItem(
          value: s7.id,
          child: Text(s7.name));
      }).toList(),
      ),
    );

    Widget buildS8() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Superstar 8 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Superstar 8"),
        onChanged: onChangedS8,
        items: disable(8) ? null : listSuperstars!.map((s8){
        return DropdownMenuItem(
          value: s8.id,
          child: Text(s8.name));
      }).toList(),
      ),
    );

  Widget buildWinner() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Winner : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Winner"),
        value: winner != 0 ? winner : defaultSup.id,
        onChanged: onChangedWinner,
        items: listSuperstars!.map((winner){
        return DropdownMenuItem(
          value: winner.id,
          child: Text(winner.name));
      }).toList(),
      validator: (winner) => validateWinner() ? null : "The winner must be in the match",
      ),
    );

   Widget buildOrder() => TextFormField(
      initialValue: order.toString(),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18
      ),
      decoration: const InputDecoration(
        labelText: 'Order : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
        border: InputBorder.none,
        hintText: 'Match n°',
      ),
      validator: (order) =>
          order!.isEmpty ? "The order can't be empty" : null,
      onChanged: onChangedOrder,
    );
}