import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropors/view/components/userPostCard.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PageController _controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 8.0,
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width,
              child:profileArea("username47"),
            ),
          ),
        ),
        userPostsHistory()
      ],
    );
  }

  //top half of profile page
  Widget profileArea(userName)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        profileDetail(userName),
        profilePic("assets/dog.jpg"),
      ],
    );
  }

  //profile pick builder
  Widget profilePic(imageString)
  {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        height: 100,
        width: 100,
        child: CircleAvatar(
          radius: 50,
          backgroundImage: ExactAssetImage('assets/dog.jpg'),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: new Border.all(
            color: Colors.white12,
            width: 6.0
          )
        ),
      ),
    );
  }

  //details of the user
  // likes, favourites, distance covered
  Widget profileDetail(userName)
  {
    return FittedBox(
      child: Card(
        elevation: 8.0,
        child: Container(
          height: 500,
          width: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              userNameBuilder(userName),
              Card(
                child: ListTile(
                    leading: Icon(Icons.star),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.location_on_sharp),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //username text
  Widget userNameBuilder(userName)
  {
    return AutoSizeText(userName,
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      maxLines: 1,
    );
  }

  //all user posts
  Widget userPostsHistory()
  {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        children: [
          //data from stream should be passed to UserPostCard
          UserPostCard(),
          UserPostCard(),
          UserPostCard()
        ],
      ),
    );
  }
}
