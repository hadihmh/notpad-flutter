import 'dart:convert';

import 'package:demo_13/Models/Note.dart';
import 'package:demo_13/Models/Utility.dart';

import 'package:demo_13/ViewControllers/StaggeredView.dart';

import 'package:demo_13/Views/StaggeredTiles.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../Models/SqliteHandler.dart';
import '../ViewControllers/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MainPage extends KFDrawerContent {
  MainPage({
    Key key,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var noteDB = NotesDBHandler();
  List<Map<String, dynamic>> _allNotesInQueryResult = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: searchCard(),
      ),
      body: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                Expanded(child: HomePage()),
              ],
            ),
          ),
        ),
      ),
    );
  }
// #region old search

  // Widget searchCard() => Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Card(
  //         elevation: 2.0,
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: <Widget>[
  //               Icon(Icons.search),
  //               SizedBox(
  //                 width: 10.0,
  //               ),
  //               Expanded(
  //                 child: TextField(
  //                   decoration: InputDecoration(
  //                       border: InputBorder.none, hintText: "Find our product"),
  //                 ),
  //               ),
  //               Icon(Icons.menu),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );

// #endregion

  Widget searchCard() => Padding(
        padding: const EdgeInsets.all(1.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  color: Colors.black,
                  icon: Icon(MdiIcons.menuOpen),
                  iconSize: 25,
                  onPressed: () {
                    widget.onMenuPressed();
                  },
                ),
                InkWell(
                  onTap: _neverSatisfied,
                  child: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Expanded(

                  child: TextField(
                    onChanged: (text) {
                      StaggeredGridPage(
                        searchQuery: text,
                      );
                      // print('dddddddddssfa322');
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search your notes..."),
                  ),
                ),

              ],
            ),
          ),
        ),
      );

// #region AlertBox
  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rewind and remember'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You will never be satisfied.'),
                Text('You\’re like me. I’m never satisfied.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Regret'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// #endregion
}
