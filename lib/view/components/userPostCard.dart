import 'package:flutter/material.dart';

class UserPostCard extends StatefulWidget {
  @override
  _UserPostCardState createState() => _UserPostCardState();
}

class _UserPostCardState extends State<UserPostCard> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Card(
        elevation: 8.0,
        child: SizedBox(
          height: 100,
          child: Image.asset("assets/dog.jpg", fit: BoxFit.contain,),
        ),
      ),
    );
  }
}
