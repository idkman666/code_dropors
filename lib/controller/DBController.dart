import 'package:cloud_firestore/cloud_firestore.dart';

class DBController{

  Stream<QuerySnapshot> getData () {
    return FirebaseFirestore.instance.collection("userPost").snapshots();
  }
}