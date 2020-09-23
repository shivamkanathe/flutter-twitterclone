import 'package:flutter/material.dart';
import 'package:food/src/pages/profile.dart';
import 'package:food/src/pages/seach.dart';
import 'package:food/src/pages/tweet.dart';
// import 'package:food/src/models/category-model.dart';
// import 'package:food/src/widgets/category.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int page = 0;

  List pageOption = [
    TweetPage(),
    SearchPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageOption[page],
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              page = index;
            });
          },
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.black,
          currentIndex: page,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 28,
                ),
                title: Text("Tweet")),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  size: 28,
                ),
                title: Text("Search")),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 28,
                ),
                title: Text("Profile")),
          ]),
    );
  }
}
