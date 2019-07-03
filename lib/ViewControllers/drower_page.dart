import 'package:demo_13/Models/Note.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';

import '../screens/auth_page.dart';
import '../screens/calendar_page.dart';
import '../screens/main_page.dart';
import '../utils/class_builder.dart';
import './HomePage.dart';
import '../Models/PlaceHolder.dart';
import 'NotePage.dart';

class DrawerPage extends StatefulWidget {
  DrawerPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> with TickerProviderStateMixin {
  KFDrawerController _drawerController;

  @override
  void initState() {
    super.initState();
    _drawerController = KFDrawerController(
      initialPage: ClassBuilder.fromString('MainPage'),
      items: [
        KFDrawerItem.initWithPage(
          text: Text('New Note', style: TextStyle(color: Colors.white)),
          icon: Icon(Icons.note, color: Colors.black),
          page: MainPage(),
          onPressed: (){
            _newNoteTapped(PlaceHolder.homePageContext);},
        ),
        KFDrawerItem.initWithPage(
          text: Text(
            'Trash',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(Icons.restore_from_trash, color: Colors.black),
          page: CalendarPage(),
        ),
        KFDrawerItem.initWithPage(
          text: Text(
            'Settins',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(Icons.settings, color: Colors.black),
          page: ClassBuilder.fromString('SettingsPage'),
        ),
      ],
    );
  }
void _newNoteTapped(BuildContext ctx) {
    // "-1" id indicates the note is not new
    var emptyNote =
        new Note(-1, "", "", DateTime.now(), DateTime.now(), Colors.white,0);
    Navigator.push(
        ctx, MaterialPageRoute(builder: (ctx) => NotePage(emptyNote)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: KFDrawer(
//        borderRadius: 0.0,
//        shadowBorderRadius: 0.0,
//        menuPadding: EdgeInsets.all(0.0),
//        scrollable: true,
        controller: _drawerController,
        header: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            width: MediaQuery.of(context).size.width * 0.6,
            child: Image.asset(
              "Assets/logo2.png",
              height: 150,
              width: 150,
            ),
            //   child:CircleAvatar(backgroundImage: AssetImage(
            //     'Assets/logo.jpg',

            //     //alignment: Alignment.centerLeft,
            //   ),minRadius: 50,
            // maxRadius: 90,)
          ),
        ),
        footer: KFDrawerItem(
          text: Text(
            'Help & Feedback',
            style: TextStyle(color: Colors.black),
          ),
          icon: Icon(
            Icons.help_outline,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).push(CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (BuildContext context) {
                return AuthPage();
              },
            ));
          },
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(191, 204, 194, 1.0),
              Color.fromRGBO(85, 85, 85, 1.0)
            ],
            //colors: [Colors.green],
            tileMode: TileMode.repeated,
          ),
        ),
      ),
    );
  }
}
