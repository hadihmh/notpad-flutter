import 'package:flutter/material.dart';
import 'StaggeredView.dart';
import '../Models/Note.dart';
import 'NotePage.dart';
import '../Models/Utility.dart';

enum viewType { List, Staggered }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var notesViewType;

  Widget appBarTitle = new Text(
    "Search Sample",
    style: new TextStyle(color: Colors.white),
  );
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQueryController =
      new TextEditingController();
  List<String> _list;
  bool _isSearching;
  String _searchText = "";

  @override
  void initState() {
    notesViewType = viewType.Staggered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        brightness: Brightness.light,
        // leading: IconButton(
        //   onPressed: (){
        //     showSearch(context: context,delegate: SearchNote());
        //   },
        //   icon: Icon(Icons.search,color: Colors.black,),
        // ),
        actions: _appBarActions(),
        elevation: 1,
        //backgroundColor: Colors.white,
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
      bottomSheet: _bottomBar(),
    );
  }

  Widget searchCard() => Padding(
        padding: const EdgeInsets.all(1.0),
        child: Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1,horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search your notes ..."),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildAppbar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: actionIcon,
          onPressed: () {
            setState(() {
              if (actionIcon == Icon(Icons.search)) {
                actionIcon = Icon(
                  Icons.clear,
                  color: Colors.black,
                );
                appBarTitle = TextField(
                  controller: _searchQueryController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...',
                  ),
                );
              }
            });
          },
        )
      ],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          child: Text(
            "New Note\n",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _newNoteTapped(context),
        )
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
