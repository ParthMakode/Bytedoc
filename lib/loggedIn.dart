import 'package:fireapp/hospital.dart';
import 'package:fireapp/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoggedIn extends StatefulWidget {
  const LoggedIn({Key? key}) : super(key: key);

  @override
  _LoggedInState createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return Hospital();
          }else {
            return MyLogin();
          }

        },
       ), //  Container(
      //     decoration: const BoxDecoration(
      //   image: DecorationImage(
      //       image: AssetImage('assets/hospi.png'), fit: BoxFit.cover),
      // )),
    );
  }
}
