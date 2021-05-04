import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropors/controller/DBController.dart';
import 'package:dropors/service/authenticationService.dart';
import 'package:dropors/view/addPost.dart';
import 'package:dropors/view/homePage.dart';
import 'package:dropors/view/imageEditing/imageEditingPage.dart';
import 'package:dropors/view/landingPage.dart';
import 'package:dropors/view/mapsPage.dart';
import 'package:dropors/view/profilePage.dart';
import 'package:dropors/view/signInPage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
      home: SafeArea(
          child: MultiProvider(
            providers: [
              Provider<AuthenticationService>(
                create: (e) => AuthenticationService(FirebaseAuth.instance),
              ),
              StreamProvider(create: (e) => e.read<AuthenticationService>().authStateChanges)
            ],
            child: AuthenticationWrapper(),
          )
      ),
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

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: MultiProvider(
          providers: [
            Provider<AuthenticationService>(
              create: (e) => AuthenticationService(FirebaseAuth.instance),
            ),
            StreamProvider(create: (e) => e.read<AuthenticationService>().authStateChanges)
          ],
          child: AuthenticationWrapper(),
        )
    );
  }
}
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if(firebaseUser != null)
    {
      return LandingPage();
    }
    return SignInPage();
  }
}