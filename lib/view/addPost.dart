import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropors/view/cameraPreviewPage.dart';
import 'package:dropors/view/imageEditing/imageEditingPage.dart';
import 'package:dropors/view/imageEditing/tempDrawOverImg.dart';

import 'package:flutter/material.dart';
import 'package:location/location.dart';

class AddPost extends StatefulWidget {
  AddPost({Key key}) : super(key: key);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final TextEditingController textEditingController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userPostText;
  Future<void> _initializeControllerFuture;
  bool _isTakePicture = false;
  Location _location = Location();
  double userXCoordinate;
  double userYCoordinate;

  //temp:
  double x_coordinate;
  double y_coordinate;

  @override
  void initState() {
    super.initState();

    textEditingController.addListener(onUserPostTextChange);
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
    LocationData pos = await _location.getLocation();
    setState(() {
      userXCoordinate = pos.latitude;
      userYCoordinate = pos.longitude;
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void onUserPostTextChange() {
    setState(() {
      userPostText = textEditingController.text;
    });
  }

  Future<void> handlePost() async {
    try {
      await firestore.collection("userPost").doc().set({
        "userName": "test_User",
        "content": userPostText,
        "pic": "",
        "postDate": DateTime.now(),
        "x-coordinate": x_coordinate,
        "y-coordinate": y_coordinate
      });
    } catch (e) {
      print("error while uploading");
    }
    //handles success
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Flexible(
            flex: 2,
            child: Card(
              elevation: 8.0,
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.65,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextField(
                        cursorColor: Colors.black,
                        controller: textEditingController,
                        onChanged: (e) {
                          onUserPostTextChange();
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Say something',
                        ),
                      ),
                      TextField(
                        cursorColor: Colors.black,
                        onChanged: (e) {
                          setState(() {
                            x_coordinate = double.parse(e);
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'X_Coordinate',
                        ),
                      ),
                      TextField(
                        cursorColor: Colors.black,
                        onChanged: (e) {
                          setState(() {
                            y_coordinate = double.parse(e);
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Y_Coordinate',
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            handlePost();
                          },
                          child: Text("Post")),
                      ElevatedButton(onPressed: () {}, child: Text("Add Pic")),
                      ElevatedButton(
                        child: Icon(Icons.camera_alt_outlined),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CropPage()));
                        },
                      ),
                      ElevatedButton(
                        child: Icon(Icons.image),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ImageEditingPage()));
                        },
                      )
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}
