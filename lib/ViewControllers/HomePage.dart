import 'package:demo_13/Models/PlaceHolder.dart';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'StaggeredView.dart';
import '../Models/Note.dart';
import 'NotePage.dart';
import '../Models/Utility.dart';
import '../Models/FabBottomAppBar.dart';

enum viewType { List, Staggered }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchviewlis = new TextEditingController();
  _HomePageState() {
    searchviewlis.addListener(() {
      if (searchviewlis.text.isEmpty) {
        setState(() {
          CentralStation.updateNeeded = true;
          searchval = null;
          //HomePage("ok");
        });
      } else {
        setState(() {
          String ser = searchviewlis.text;

          CentralStation.updateNeeded = true;
          searchval = ser;
          //HomePage("ok");
        });
      }
    });
  }

  var notesViewType;
  String searchval;
  bool isArchive;
  String _lastSelected = 'TAB: 0';
  @override
  void initState() {
    notesViewType = viewType.Staggered;
  }

  @override
  Widget build(BuildContext context) {
    PlaceHolder.homePageContext = context;
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          // appBar: AppBar(
          //   brightness: Brightness.light,
          //   //actions: _appBarActions(),
          //   // actions: <Widget>[RaisedButton(onPressed: (){onpresswid();},child: Icon(Icons.add),)],

          //   elevation: 1,
          //   backgroundColor: Colors.white,
          //   centerTitle: true,
          //   title: Text("Notes"),
          // ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.grey,
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
          //bottomSheet: _bottomBar(),
          //floatingActionButtonLocation: FloatingActionButtonLocation.endTop
          bottomNavigationBar: _bulidBottomNavBar(),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          //floatingActionButton: _buildFab(context),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.create),
            backgroundColor: Colors.black,
            onPressed: () {
              _newNoteTapped(context);
            },
          ),
        ),
        onWillPop: () async => Future.value(false));
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

  Widget _bottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(30),
          child: FloatingActionButton(
            onPressed: () {
              _newNoteTapped(context);
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.grey,
          ),
        ),

        //FlatButton(

        // child: Text(
        //   "New Note\n",
        //   style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        // ),
        //onPressed: () => _newNoteTapped(context),
        // )
      ],
    );
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = 'FAB: $index';
      print("---------------------------------$index");
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
      height: 40,
      iconSize: 19,
      backgroundColor: Colors.grey,

      //centerItemText: 'A',
      color: Colors.white,
      selectedColor: Colors.black,
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
    var emptyNote =
        new Note(-1, "", "", DateTime.now(), DateTime.now(), Colors.white, 0);
    Navigator.push(
        ctx, MaterialPageRoute(builder: (ctx) => NotePage(emptyNote)));
  }

  void _toggleViewType() {
    setState(() {
      CentralStation.updateNeeded = true;
      if (notesViewType == viewType.List) {
        notesViewType = viewType.Staggered;
      } else {
        notesViewType = viewType.List;
      }
    });
  }

  List<Widget> _appBarActions() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => _toggleViewType(),
            child: Icon(
              notesViewType == viewType.List
                  ? Icons.developer_board
                  : Icons.view_headline,
              color: CentralStation.fontColor,
            ),
          ),
        ),
      ),
    ];
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
                    //widget.onMenuPressed();
                    //SearchArg.onpress=widget.onMenuPressed;
                    PlaceHolder.onpress();
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
                    controller: searchviewlis,
                    // onChanged: (text) {
                    //   StaggeredGridPage(
                    //     notesViewType: viewType.Staggered,
                    //     searchview: searchview,
                    //   );
                    // print('dddddddddssfa322');
                    // },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search your notes..."),
                  ),
                ),
                IconButton(
                  color: Colors.black,
                  icon: Icon(
                    notesViewType == viewType.List
                        ? Icons.developer_board
                        : Icons.view_headline,
                    color: CentralStation.fontColor,
                  ),
                  iconSize: 25,
                  onPressed: () {
                    _toggleViewType();
                    //widget.onMenuPressed();
                    //SearchArg.onpress=widget.onMenuPressed;
                    //SearchArg.onpress();
                  },
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
}
