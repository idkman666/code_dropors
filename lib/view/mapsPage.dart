import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:location/location.dart';

class MapsPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  MapsPage({this.latitude, this.longitude});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  List<Marker> markers = [];
  final Location _location = Location();
  double userXCoordinate;
  double userYCoordinate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermission();
    setMarkers();
  }

  void getPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (serviceEnabled == false) {
      await _location.requestPermission();
    } else {
      await getLocation();
    }
  }

  Future<void> getLocation() async {
    //check permission here
    if (widget.latitude == null || widget.longitude == null) {
      LocationData pos = await _location.getLocation();
      setState(() {
        userXCoordinate = pos.latitude;
        userYCoordinate = pos.longitude;
      });
      //selectedPage = <Widget>[HomePage(stream: stream), MapsPage(latitude: userXCoordinate, longitude: userYCoordinate,),AddPost(camera: widget.camera,),ProfilePage()];
    }
  }

  void setMarkers() {
    Stream<QuerySnapshot> stream =
        FirebaseFirestore.instance.collection("userPost").snapshots();
    stream.forEach((element) {
      element.docs.forEach((doc) {
        //add to marker list
        var docData = doc.data();
        print(docData["content"]);
        markers.add(
            customMarker(docData["x-coordinate"], docData["y-coordinate"]));
      });
    });
  }

  Marker customMarker(x, y) {
    return Marker(
      width: 40.0,
      height: 40.0,
      point: latLng.LatLng(x, y),
      builder: (ctx) => Container(
        child: FlutterLogo(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var x = widget.latitude;
    var y = widget.longitude;
    return Scaffold(
      appBar: AppBar(
        title: Text("DropOrs Map"),
      ),
      body: SafeArea(
          child: x != null || y != null
              ? map(x, y)
              : userXCoordinate == null || userYCoordinate == null
                  ? loadingPage()
                  : map(x, y)),
    );
  }

  Widget map(x, y) {
    return FlutterMap(
      options: new MapOptions(
          center: new latLng.LatLng(x ?? userXCoordinate, y ?? userYCoordinate),
          minZoom: 10.0),
      layers: [
        new TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        MarkerLayerOptions(markers: markers)
      ],
    );
  }

  Widget loadingPage() {
    return Center(
      child: SpinKitCircle(
        color: Colors.black,
        size: 50.0,
      ),
    );
  }
}
