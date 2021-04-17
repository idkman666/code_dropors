import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropors/view/addPost.dart';
import 'package:dropors/view/components/dataCard.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  Stream<QuerySnapshot> stream;
  HomePage({this.stream});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _stream = widget.stream;
    //handle stream here
    return StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  List<QueryDocumentSnapshot> docs = snapshot.data.docs;
                  return DataCard(
                    documentSnapshot: docs[index]
                  );
                });
          }
          if(snapshot.connectionState == ConnectionState.waiting)
            {
              return Text("Loading");
            }
          return Text("Loading");
        });
  }

  Widget tempWidget() {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPost()),
            );
          },
          child: Text("Add post")),
    );
  }
}
