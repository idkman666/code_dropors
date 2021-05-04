import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropors/controller/DBController.dart';
import 'package:dropors/service/authenticationService.dart';
import 'package:dropors/view/addPost.dart';
import 'package:dropors/view/homePage.dart';
import 'package:dropors/view/imageEditing/imageEditingPage.dart';
import 'package:dropors/view/mapsPage.dart';
import 'package:dropors/view/profilePage.dart';
import 'package:dropors/view/signInPage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';



class LandingPage extends StatefulWidget {
  final CameraDescription camera;
  LandingPage({Key key, this.camera}) : super(key: key);

  @override
  _LandingPage createState() => _LandingPage();
}

class _LandingPage extends State<LandingPage> {

  List<Widget> selectedPage;
  int _selectedIndex = 0;
  File imageFile;
  final DBController _dbController = DBController();
  Stream<QuerySnapshot> stream;

  @override
  void initState() {
    super.initState();
    stream = _dbController.getData();
  }

  void onTapHandler(int index) {
    // if(index != 2)
    //   {
    //     setState(() {
    //       _selectedIndex = index;
    //     });
    //   }else
    //     {
    //      _bottomPopAddMenu();
    //     }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _bottomPopAddMenu()
  {
    showModalBottomSheet(context: context, builder: (BuildContext context){
      return Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(onPressed: (){
              _pickImage();
            }, child: Icon(Icons.image)),
            TextButton(onPressed: (){
              _pickCameraImage();
            }, child: Icon(Icons.camera))
          ],
        ),
      );
    });
  }
  Future<Null> _pickImage() async {
    final pickedImage =
    await ImagePicker().getImage(source: ImageSource.gallery);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ImageEditingPage(image: imageFile,)));
    }
  }

  _pickCameraImage()async{
    final pickedImage = await ImagePicker().getImage(source: ImageSource.camera);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ImageEditingPage(image: imageFile,)));
    }
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
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add Post",),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
        currentIndex: _selectedIndex,
        onTap: onTapHandler,
      ),      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
