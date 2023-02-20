import 'package:cloud_firestore/cloud_firestore.dart';
import 'reportAccident.dart';
class DatabaseService
{
   final String uid;
   DatabaseService({required this.uid});
   CollectionReference collection=FirebaseFirestore.instance.collection('riskindex');
   Future updateUserdata(int cases,String? pinc) async{
     return await collection.doc(uid).set({
       'case':cases,
       'pincode':pinc
     }
     );
   }
}