import '../Models/PlaceHolder.dart';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'StaggeredView.dart';
import '../Models/Note.dart';
import 'NotePage.dart';
import '../Models/Utility.dart';
import '../Models/FabBottomAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:popup_menu/popup_menu.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences pref;
  TextEditingController searchviewlis = new TextEditingController();
  _HomePageState() {
    searchviewlis.addListener(() {
      if (searchviewlis.text.isEmpty) {
        setState(() {
          CentralStation.updateNeeded = true;
          searchval = null;
        });
      } else {
        setState(() {
          String ser = searchviewlis.text;

          CentralStation.updateNeeded = true;
          searchval = ser;
        });
      }
    });
  }
  List<String> theme;
  var notesViewType;
  String searchval;
  bool isArchive;

  @override
  void initState() {
    CentralStation.updateNeeded = true;
    notesViewType = 0;
    theme = PlaceHolder.theme ?? PlaceHolder.theme1;
    onchange().then((_) {
      setState(() {
        theme = PlaceHolder.theme ?? PlaceHolder.theme1;
      });
    });
  }

  onchange() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String fontsize = pref.getString("fontsize");
    String theme = pref.getString("theme");

    if (fontsize == null) {
      pref.setString("fontsize", "f2");
      PlaceHolder.fontsize = PlaceHolder.fontsize2;
      PlaceHolder.fs = 1;
    }
    if (theme == null) {
      pref.setString("theme", "t2");
      PlaceHolder.theme = PlaceHolder.theme2;
      PlaceHolder.ts = 1;
    }
    if (fontsize != null && theme != null) {
      setState(() {
        String ttype = pref.getString("theme");
        String ftype = pref.getString("fontsize");

        if (ttype == "t1") {
          PlaceHolder.theme = PlaceHolder.theme1;
          PlaceHolder.ts = 0;
        } else if (ttype == "t2") {
          PlaceHolder.theme = PlaceHolder.theme2;
          PlaceHolder.ts = 1;
        } else if (ttype == "t3") {
          PlaceHolder.theme = PlaceHolder.theme3;
          PlaceHolder.ts = 2;
        } else if (ttype == "t4") {
          PlaceHolder.theme = PlaceHolder.theme4;
          PlaceHolder.ts = 3;
        }
        if (ftype == "f1") {
          PlaceHolder.fontsize = PlaceHolder.fontsize1;
          PlaceHolder.fs = 0;
        } else if (ftype == "f2") {
          PlaceHolder.fontsize = PlaceHolder.fontsize2;
          PlaceHolder.fs = 1;
        } else if (ftype == "f3") {
          PlaceHolder.fontsize = PlaceHolder.fontsize3;
          PlaceHolder.fs = 2;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    PlaceHolder.sstate = _homeSState;
    PopupMenu.context = context;
    PlaceHolder.homePageContext = context;
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Color(PlaceHolder.hexToInt(theme[1])),
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color(PlaceHolder.hexToInt(theme[0])),
            centerTitle: true,
            title: searchCard(),
          ),
          body: SafeArea(
            child: _body(),
            right: true,
            left: true,
            top: true,
            bottom: true,
          ),
          bottomNavigationBar: _bulidBottomNavBar(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.create),
            backgroundColor: Color(PlaceHolder.hexToInt(theme[10])),
            onPressed: () {
              _newNoteTapped(context);
            },
          ),
        ),
        onWillPop: () async {
          Future.value(false);
          exit(0);
        });
  }

  void _homeSState() {
    setState(() {
      int a = 0;
    });
  }

  Widget _body() {
    print(notesViewType);
    return Container(
        child: StaggeredGridPage(
      notesViewType: notesViewType,
      searchview: searchval,
      isArchive: PlaceHolder.isArch,
    ));
  }

  void _selectedFab(int index) {
    setState(() {
      CentralStation.updateNeeded = true;
      if (index == 1) {
        PlaceHolder.isArch = false;
      }
      if (index == 0) {
        PlaceHolder.isArch = true;
      }
    });
  }

  Widget _bulidBottomNavBar() {
    return FABBottomAppBar(
      height: 45,
      iconSize: 19,
      backgroundColor: Color(PlaceHolder.hexToInt(theme[4])),

      //centerItemText: 'A',
      color: Colors.white,
      selectedColor: Color(PlaceHolder.hexToInt(theme[9])),
      notchedShape: CircularNotchedRectangle(),
      onTabSelected: _selectedFab,
      items: [
        // FABBottomAppBarItem(iconData: Icons.settings),
        // FABBottomAppBarItem(iconData: Icons.restore_from_trash, text: 'Trash'),
        FABBottomAppBarItem(iconData: Icons.archive),
        FABBottomAppBarItem(iconData: Icons.receipt),
      ],
    );
  }

  void _newNoteTapped(BuildContext ctx) {
    // "-1" id indicates the note is not new
    var emptyNote = new Note(
        -1, "", "", DateTime.now(), DateTime.now(), Colors.white, 0, 0);
    Navigator.push(
        ctx, MaterialPageRoute(builder: (ctx) => NotePage(emptyNote)));
  }

  void _toggleViewType() {
    setState(() {
      CentralStation.updateNeeded = true;
      if (notesViewType == 1) {
        notesViewType = 0;
      } else {
        notesViewType = 1;
      }
    });
  }

  Widget searchCard() => Padding(
        padding: const EdgeInsets.all(1.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
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
                    PlaceHolder.onpress();
                  },
                ),
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: TextField(
                    controller: searchviewlis,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search your notes..."),
                  ),
                ),
                IconButton(
                  color: Colors.black,
                  icon: Icon(
                    notesViewType == 1
                        ? Icons.developer_board
                        : Icons.view_headline,
                    color: CentralStation.fontColor,
                  ),
                  iconSize: 25,
                  onPressed: () {
                    _toggleViewType();
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
