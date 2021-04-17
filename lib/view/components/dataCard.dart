import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropors/view/mapsPage.dart';
import 'package:flutter/material.dart';


class DataCard extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  DataCard({this.documentSnapshot});

  @override
  _DataCardState createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {

  double calculateDistance(xCoordinate, yCoordinate, userXCoordinate, userYCoordinate)
  {
    return sqrt(pow((xCoordinate - userXCoordinate),2) + pow((yCoordinate - userYCoordinate),2));
  }

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot _documentSnapshot = widget.documentSnapshot;
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(6.0),
      child: Container(
        height:  MediaQuery.of(context).size.height*0.10,
        child: ListTile(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapsPage(longitude: _documentSnapshot["y-coordinate"], latitude: _documentSnapshot["x-coordinate"],)),
            );
          },
            leading: FlutterLogo(size: 72.0),
            title: Text(_documentSnapshot["content"]),
          subtitle:Text("Show distance here!!") ,
        ),
      ),
    );
  }
}
