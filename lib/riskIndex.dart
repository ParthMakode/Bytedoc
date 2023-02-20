import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material2.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class riskIndex extends StatefulWidget {
  const riskIndex({Key? key}) : super(key: key);

  @override
  _riskIndexState createState() => _riskIndexState();
}

class _riskIndexState extends State<riskIndex> {
  final user = FirebaseAuth.instance.currentUser!;
  String currAddr = 'MyAddr';
  String? currPin = '0';
  double index=0;
  Position currPos = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.utc(1969, 7, 20, 20, 18, 04),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  Future<Position> _detPos() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please turn on your location.");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Location Permission is denied so we cant procede further");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location Permission is denied forever");
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        currPos = position;
        currAddr =
            "${place.name},${place.street},${place.administrativeArea},${place.locality},${place.postalCode},${place.country}";
        currPin = place.postalCode;
      });
    } catch (e) {
      print(e);
    }
    return currPos;
  }

  List<String> docId = [];
  List<int> casL=[];
  List<double> casesL=[];
  List<String> pinL=[];
  Map<double, String> mymap = {};
  int currCase=0;
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('riskindex')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              print(document.reference);
              docId.add(document.reference.id);
            }));
    await FirebaseFirestore.instance
        .collection('riskindex')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
      print(document.reference);
      var obj = document.data();
      int vac=obj['case'];
      print(vac);
      casL.add(vac);
      String pinco=obj['pincode'];
      pinL.add(pinco);
      if(pinco==currPin){
        currCase=vac;
      }



    }));

    print("vaccine normalized list");
    print(mymap[casL[1]]);
    final int lo = casL.reduce(min);
    final int up = casL.reduce(max);
    final List<double> norm=[];

    casL.forEach((element1) => element1 < 0
        ? norm.add(-(element1 / lo))
        : norm.add(element1 / up));
    casesL=norm;
    print(casesL);
    // casesL.sort();

    for (var i = 0; i < casL.length; i = i + 1) {
      mymap[casesL[i]] = pinL[i];
    }
    for(var i = 0; i < casesL.length; i = i + 1) {
      if(mymap[casesL[i]]==currPin){
        index=casesL[i];
      }
    }

    index=index*1000;
    index=index.truncateToDouble();
    index=index/100;
    setState(() {

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[500],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Risk Index"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/login.jpg"), fit: BoxFit.cover),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 35, top: 20),
            child: Text(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              'Signed in as:\n' + user.email!,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(left: 35, top: 125),
            child: Container(
              child: Column(children: [
                Text(
                  currAddr,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                currPos != null
                    ? Text(
                        "Latitude = " + currPos.latitude.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      )
                    : Container(),
                currPos != null
                    ? Text(
                        "  Longitude = " + currPos.longitude.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      )
                    : Container(),
                TextButton(
                    onPressed: () {
                      _detPos();
                      getDocId();
                      // getDist();
                      setState(() {});
                    },
                    child: Text(
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.orangeAccent,
                        ),
                        "    Locate me")),
              ]),
            ),
          ),
          Container(padding: EdgeInsets.only(top:340,left: 20),
            child: Text(
              'Your Area pincode is :                     ${currPin} ',
              style: TextStyle(
                fontSize:20,fontWeight:FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(padding: EdgeInsets.only(top:390,left: 20),
            child: Text(
              'No.of cases in your Area is :          ${currCase} ',
              style: TextStyle(
                fontSize: 20,fontWeight:FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(padding: EdgeInsets.only(top:450,left: 20),
            child: Text(
              'Risk Index of your Area is :\n\n                   ( ${index} / 10 )',
              style: TextStyle(
                fontSize: 20,fontWeight:FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
