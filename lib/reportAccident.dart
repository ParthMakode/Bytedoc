import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'updateRI.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
class reportAccident extends StatefulWidget {
  const reportAccident({Key? key}) : super(key: key);

  @override
  _reportAccidentState createState() => _reportAccidentState();
}

class _reportAccidentState extends State<reportAccident> {
  final user = FirebaseAuth.instance.currentUser!;
  Map<String,int> updater={'case':0};

  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _threatController = TextEditingController();

  String currAddr = 'MyAddr';
  String? currPin = '0';
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
        "${place.name},${place.street},${place.administrativeArea},${place
            .locality},${place.postalCode},${place.country}";
        currPin = place.postalCode;
      });
    } catch (e) {
      print(e);
    }
    return currPos;
  }

  List<String> docId = [];

  Future reAcc() async {
    await FirebaseFirestore.instance.collection('riskindex').get().then((
        snapshot)   =>
        snapshot.docs.forEach((document) async{
          print(document.reference);
          docId.add(document.reference.id);
          if(currPin == document.data()['pincode']){
            int c=document.data()['case'];
            c++;
            await DatabaseService(uid:document.reference.id).updateUserdata(c,currPin);
            print(document.data()['case']);
          }
          Fluttertoast.showToast(msg: "Report Added");
        }));

    // DocumentReference document=collection.doc(widget.ncase['doc_id']);
    // document.update(updater);

    // var collection = FirebaseFirestore.instance.collection('riskindex');
    // for(int i=0;i<docId.length;i++){
    //   int cases=collection.doc(docId[i]).data()['case']+1;
    //   collection
    //       .doc(docId[i])
    //       .update({'case' : }) // <-- Updated data
    //       .then((_) => print('Success'))
    //       .catchError((error) => print('Failed: $error'));
    // }
    // collection
    //     .doc('doc_id')
    //     .update({'case' : 'value'}) // <-- Updated data
    //     .then((_) => print('Success'))
    //     .catchError((error) => print('Failed: $error'));

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[500],
      appBar: AppBar(elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Report Accident"),
        centerTitle: true,),
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
              child: Column(
                  children: [
                    Text(
                      currAddr,
                      style: TextStyle(
                        fontSize: 25,
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
                    Center(
                      child: TextButton(
                          onPressed: () {
                            _detPos();
                          },
                          child: Text(
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.orangeAccent,
                              ),
                              "    Locate me")),
                    ),

                  ]),
            ),
          ),
    Container(
      padding: EdgeInsets.only(top: 300),
      child: SingleChildScrollView(
      child: Container(
              margin: const EdgeInsets.only(left: 35, right: 35, top: 0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: _typeController,
                    style: const TextStyle(),

                    decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: "Type of Dog",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: _threatController,
                    style: const TextStyle(),

                    decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: "Threat Level(high or low)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ' Report Accident',
                        style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xff4c505b),
                        child: IconButton(
                            color: Colors.white,
                            onPressed: () {
                              if (currPos.latitude == 0 &&
                                  currPos.longitude == 0) {
                                Fluttertoast.showToast(
                                    msg: "Your location is needed. Please reconsider.");
                              } else {
                                reAcc();
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_forward,
                            )),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                ],
              ),
            )
      ),
    )

        ],
      ),
    );
  }
}