import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropors/controller/DBController.dart';
import 'package:dropors/view/addPost.dart';
import 'package:dropors/view/homePage.dart';
import 'package:dropors/view/mapsPage.dart';
import 'package:dropors/view/profilePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;
  MyHomePage({Key key, this.camera}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Widget> selectedPage;
  int _selectedIndex = 0;

  final DBController _dbController = DBController();
  Stream<QuerySnapshot> stream;

  @override
  void initState() {
    super.initState();
    stream = _dbController.getData();
  }

  void onTapHandler(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedPage = <Widget>[HomePage(stream: stream), MapsPage(),AddPost(),ProfilePage()];
    return Scaffold(
      appBar: AppBar(
        title: Text("DropOrs"),
      ),
      body: selectedPage == null ? SafeArea(child: HomePage(stream: stream,)) : SafeArea(child: selectedPage[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.red,
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
        currentIndex: _selectedIndex,
        onTap: onTapHandler,
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
