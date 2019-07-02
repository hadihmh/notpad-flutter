import 'dart:convert';

import 'package:demo_13/Models/Note.dart';
import 'package:demo_13/Models/Utility.dart';
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
  
  
  List<StaggeredTile> _tilesForView() {
    // Generate staggered tiles for the view based on the current preference.
    return List.generate(_allNotesInQueryResult.length, (index) {
      return StaggeredTile.fit(1);
    });
  }

  EdgeInsets _paddingForView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding;
    double top_bottom = 8;
    if (width > 500) {
      padding = (width) * 0.05; // 5% padding of width on both side
    } else {
      padding = 8;
    }
    return EdgeInsets.only(
        left: padding, right: padding, top: top_bottom, bottom: top_bottom);
  }

  MyStaggeredTile _tileGenerator(int i) {
    return MyStaggeredTile(Note(
        _allNotesInQueryResult[i]["id"],
        _allNotesInQueryResult[i]["title"] == null
            ? ""
            : utf8.decode(_allNotesInQueryResult[i]["title"]),
        _allNotesInQueryResult[i]["content"] == null
            ? ""
            : utf8.decode(_allNotesInQueryResult[i]["content"]),
        DateTime.fromMillisecondsSinceEpoch(
            _allNotesInQueryResult[i]["date_created"] * 1000),
        DateTime.fromMillisecondsSinceEpoch(
            _allNotesInQueryResult[i]["date_last_edited"] * 1000),
        Color(_allNotesInQueryResult[i]["note_color"])));
  }

  void retrieveAllNotesFromDatabase() {
    // queries for all the notes from the database ordered by latest edited note. excludes archived notes.
    var _testData = noteDB.selectAllNotes();
    _testData.then((value) {
      setState(() {
        this._allNotesInQueryResult = value;
        CentralStation.updateNeeded = false;
      });
    });
  }
}
