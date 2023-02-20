import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material2.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class findHospital extends StatefulWidget {
  const findHospital({Key? key}) : super(key: key);

  @override
  _findHospitalState createState() => _findHospitalState();
}

class _findHospitalState extends State<findHospital> {
  final user = FirebaseAuth.instance.currentUser!;
  String nameh1='';
  String nameh2='';
  String nameh3='';
  int inven1=0;
  int inven2=0;
  int inven3=0;
  double loch1x=0;
  double loch1y=0;
  double loch2x=0;
  double loch2y=0;
  double loch3x=0;
  double loch3y=0;
  double disth1=0;
  double disth2=0;
  double disth3=0;

  CollectionReference hospi = FirebaseFirestore.instance.collection('hospital');
  String currAddr = 'MyAddr';
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
      });
    } catch (e) {
      print(e);
    }
    return currPos;
  }

  List<double> distL = [];
  List<String> docId = [];

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('hospital')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              print(document.reference);
              docId.add(document.reference.id);
            }));
  }

  Future getDist() async {
    List<double> dhu = [];
    List<double> vacl = [];
    List<int> vacl1 = [];

    await FirebaseFirestore.instance
        .collection('hospital')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              // print(document.data());
              var obj = document.data();
              double lat = obj['loc'].latitude;
              double lon = obj['loc'].longitude;
              // print(lat);
              double distanceUH = Geolocator.distanceBetween(
                  currPos.latitude, currPos.longitude, lat, lon);
              print(distanceUH);
              dhu.add(distanceUH / 1000);
              // Dist.add(document.reference.id[]);

              // distL.add()
            }));

    final lower = dhu.reduce(min);
    final upper = dhu.reduce(max);
    final List<double> normalized = [];

    dhu.forEach((element) => element < 0
        ? normalized.add(-(element / lower))
        : normalized.add(element / upper));
    dhu = normalized;
    print(normalized);
    int i = 0;
    await FirebaseFirestore.instance
        .collection('hospital')
        .get()
        .then((snap) => snap.docs.forEach((doc) {
              // print(document.data());
              var obj = doc.data();
              int vac = obj['vaccine'];
              print(i);
              i = i + 1;
              print(vac);
              vacl1.add(vac);
            }));
    print(vacl);
    print("vaccine normalized list");

    final int lo = vacl1.reduce(min);
    final int up = vacl1.reduce(max);
    final List<double> normalizedV = [];

    vacl1.forEach((element1) => element1 < 0
        ? normalizedV.add(-(element1 / lo))
        : normalizedV.add(element1 / up));
    vacl = normalizedV;
    print(vacl);
    for (var i = 0; i < vacl.length; i++) {
      distL.add(vacl[i] + 2.5 - (2.5*dhu[i]));
    }
    print(distL);
    Map<double, String> mymap = {};
    for (var i = 0; i < distL.length; i = i + 1) {
      mymap[distL[i]] = docId[i];
    }
    print(mymap);
    distL.sort();
    print(distL);
    List<double> copydistl=distL  ;
    distL= new List.from(copydistl.reversed);
    print(distL);
    String? id1 = mymap[distL[0]];
    String? id2 = mymap[distL[1]];
    String? id3 = mymap[distL[2]];

    print(id1);
    print(id2);
    print(id3);
    // hospicardData mydata = hospicardData();
    await FirebaseFirestore.instance
        .collection('hospital')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              var obj = document.data();
              if (id1 == document.reference.id) {
                nameh1 = obj['name'];
                inven1 = obj['vaccine'];
                loch1x = obj['loc'].latitude;
                loch1y = obj['loc'].longitude;
                disth1=Geolocator.distanceBetween(currPos.latitude, currPos.longitude, loch1x, loch1y);
                double d1c=disth1;
                disth1=d1c.truncateToDouble();
                disth1=disth1/1000;


              } else if (id2 == document.reference.id) {
                nameh2 = obj['name'];
                inven2 = obj['vaccine'];
                loch2x = obj['loc'].latitude;
                loch2y = obj['loc'].longitude;
                disth2=Geolocator.distanceBetween(currPos.latitude, currPos.longitude, loch2x, loch2y);
                double d1c=disth2;
                disth2=d1c.truncateToDouble();
                disth2=disth2/1000;

              } else if (id3 == document.reference.id) {
                nameh3 = obj['name'];
                inven3 = obj['vaccine'];
                loch3x = obj['loc'].latitude;
                loch3y = obj['loc'].longitude;
                disth3=Geolocator.distanceBetween(currPos.latitude, currPos.longitude, loch3x, loch3y);
                double d1c=disth3;
                disth3=d1c.truncateToDouble();
                disth3=disth3/1000;

              } else {}
            }));


  }

  double wide = 250;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text("Find Hospital"),
          centerTitle: true,
        ),
        backgroundColor: Colors.deepPurple[500],
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/login.jpg"), fit: BoxFit.cover),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 35, top: 30),
            child: Text(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              'Signed in as:\n' + user.email!,
            ),
          ),
          SizedBox(height: 10),
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

                      setState(() {});

                    },
                    child: Text(
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.orangeAccent,
                        ),
                        "    Locate me")),
                TextButton(
                    onPressed: () {
                      // getDocId();
                      // getDist();
                      getDist();
                      setState(() {});

                    },
                    child: Container(
                      child: Text(
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.orangeAccent,
                          ),
                          "    Find me a hospital"),
                    ))
              ]),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
                left: 10, top: 300, bottom: 20, right: 10),
            child: ListView(
              // This next line does the trick.
              scrollDirection: Axis.horizontal,
              children: [
                hospitalCard(
                  name: nameh1,
                  inventory: inven1,
                  loc_x: loch1x,
                  loc_y: loch1y,
                  dist: disth1,
                ),
                hospitalCard(
                  name: nameh2,
                  inventory: inven2,
                  loc_x: loch2x,
                  loc_y: loch2y,
                  dist: disth2,
                ),
                hospitalCard(
                  name: nameh3,
                  inventory: inven3,
                  loc_x: loch3x,
                  loc_y: loch3y,
                  dist: disth3,
                ),
              ],
            ),
          ),
        ]));
  }
}

class hospitalCard extends StatelessWidget {
  hospitalCard(
      {Key? key,
      required this.name,
      required this.inventory,
      required this.loc_x,
      required this.loc_y,required this.dist})
      : super(key: key);
  String name = 'HOSPITAL';
  int inventory = 0;
  double dist = 0;
  String Address = 'address';
  double loc_x = 0;
  double loc_y = 0;
  String loc = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
      child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.deepPurple[600],

          child: Container(
            padding: EdgeInsets.all(0),
            // height: 200,
            width: 340,
            child:  Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //
                  Image.asset(
                    'assets/hospit.png',
                    fit: BoxFit.cover,
                    height: 150,
                  ),
                  Text(
                    "Name : " + name,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    "Inventory : " + inventory.toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    "Distance from user : " + dist.toString() + 'km',
                    style: TextStyle(fontSize: 20),
                  ),

                  GestureDetector(
                      child: new Text(
                        'Get Hospital ',
                        style: TextStyle(fontSize: 30),
                      ),
                      onTap: () async {
                        loc = loc_x.toString() + ',' + loc_y.toString();
                        print(loc);
                        String pamth = 'maps/search/';
                        String limk = 'api=1&query=' + loc;
                        print(limk);
                        Uri link = Uri(
                            scheme: 'https',
                            host: 'google.com',
                            path: pamth,
                            query: limk);
                        print(link);
                        launchUrl(
                          link,
                          mode: LaunchMode.externalApplication,
                        );
                      }),
                ],
              ),
            ),
          ),
    );
  }
}

class TypesHelper {
  static int toInte(num val) {
    try {
      if (val == null) {
        return 0;
      }
      if (val is int) {
        return val;
      } else {
        return val.toInt();
      }
    } catch (error) {
      print('Error');
      return 0;
    }
  }
}

// FutureBuilder (future: getDist(),builder: (context,snapshot){
// return
// class hospicardData {
//   final user = FirebaseAuth.instance.currentUser!;
//   String nameh1 = '';
//   String nameh2 = '';
//   String nameh3 = '';
//   int inven1 = 0;
//   int inven2 = 0;
//   int inven3 = 0;
//   double loch1x = 0;
//   double loch1y = 0;
//   double loch2x = 0;
//   double loch2y = 0;
//   double loch3x = 0;
//   double loch3y = 0;
//
// }

// FutureBuilder(future: getDist(),builder: (context,snapshot){
// if(snapshot.connectionState==ConnectionState.waiting){
// return CircularProgressIndicator();
// }else{
// return
