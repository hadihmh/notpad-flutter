import 'package:flutter/material.dart';
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
  
  var notesViewType;
  String _lastSelected = 'TAB: 0';
  @override
  void initState() {
    notesViewType = viewType.Staggered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floatingActionButton: _buildFab(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        backgroundColor: Colors.black,
        onPressed: () {
          _newNoteTapped(context);
        },
      ),
    );
  }

  Widget _body() {
    print(notesViewType);
    return Container(
        child: StaggeredGridPage(
      notesViewType: notesViewType,
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
        //FABBottomAppBarItem(iconData: Icons.settings),
        // FABBottomAppBarItem(iconData: Icons.restore_from_trash, text: 'Trash'),
        FABBottomAppBarItem(iconData: Icons.archive),
         FABBottomAppBarItem(iconData: Icons.receipt),
        
      ],
    );
  }

  void _newNoteTapped(BuildContext ctx) {
    // "-1" id indicates the note is not new
    var emptyNote =
        new Note(-1, "", "", DateTime.now(), DateTime.now(), Colors.white);
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
}
