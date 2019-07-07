import '../ViewControllers/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';
import '../Models/PlaceHolder.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';



class MainPage extends KFDrawerContent {
  MainPage({
    Key key,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    PlaceHolder.onpress=widget.onMenuPressed;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   title: Text("Note"),
      //   leading: IconButton(
      //     //alignment: Alignment.topLeft,
      //     color: Colors.black,
      //     icon: Icon(MdiIcons.menuOpen),

      //     iconSize: 25,
      //     onPressed: () {
      //       widget.onMenuPressed();
      //     },
      //   ),
      //   // actions: <Widget>[
      //   //   IconButton(

      //   //     alignment: Alignment.topLeft,
      //   //     color: Colors.black,
      //   //         icon: Icon(Icons.account_circle),
      //   //         iconSize: 37,
      //   //         onPressed: () {
      //   //           widget.onMenuPressed();
      //   //         },
      //   //       )
      //   // ],
      // ),
      body: SafeArea(
        child: Center(
          child: Column(
            
            children: <Widget>[
              
              // Row(
              //   children: <Widget>[
              //     ClipRRect(
              //       borderRadius: BorderRadius.all(Radius.circular(32.0)),
              //       child: Material(
              //         shadowColor: Colors.transparent,
              //         color: Colors.transparent,
              //         child: IconButton(
              //           icon: Icon(
              //             Icons.menu,
              //             color: Colors.black,
              //           ),
              //           onPressed: widget.onMenuPressed,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              Expanded(child: HomePage()),
            ],
          ),
        ),
      ),
    );
  }

  
}
