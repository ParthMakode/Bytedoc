import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material2.dart';

import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[200],
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/login.jpg"), fit: BoxFit.cover),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 35, top: 50),
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
              padding: const EdgeInsets.only(left: 35, top: 120),
              child: Row(
                children: [
                  const Text(
                      "If not you ,then                                 ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 200, 30, 0),
            child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.deepPurple[300],
                child: Container(
                  padding: EdgeInsets.all(25),
                  height: 160,
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          "If you are bit by a dog then please find nearest hospital ",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'findH');
                            },
                            child: Text("Find Hospital",
                                style: TextStyle(fontSize: 20)))
                      ],
                    ),
                  ),
                )),
          ),
          // const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 400, 30, 0),
            child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.deepPurple[400],
                child: Container(
                  padding: EdgeInsets.all(25),
                  height: 160,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "Report Accident from your locality.",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'rAcci');
                            },
                            child: Text("Report Accident",
                                style: TextStyle(fontSize: 20)))
                      ],
                    ),
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 600, 30, 0),
            child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.deepPurple[500],
                child: Container(
                  padding: EdgeInsets.all(25),
                  height: 160,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "You can see the risk index of your area.",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'riskI');
                            },
                            child: Text("Risk Index",
                                style: TextStyle(fontSize: 20)))
                      ],
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
