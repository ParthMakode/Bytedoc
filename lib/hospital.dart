import 'package:flutter/material.dart';

class Hospital extends StatefulWidget {
  const Hospital({Key? key}) : super(key: key);

  @override
  _HospitalState createState() => _HospitalState();
}

class _HospitalState extends State<Hospital> {
  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/hospi.png'), fit: BoxFit.cover),
      ),


    );
  }
}
