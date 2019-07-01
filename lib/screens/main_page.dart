import 'package:demo_13/ViewControllers/HomePage.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Note"),
        leading: IconButton(
          //alignment: Alignment.topLeft,
          color: Colors.black,
          icon: Icon(MdiIcons.menuOpen),

          iconSize: 25,
          onPressed: () {
            widget.onMenuPressed();
          },
        ),
        // actions: <Widget>[
        //   IconButton(

        //     alignment: Alignment.topLeft,
        //     color: Colors.black,
        //         icon: Icon(Icons.account_circle),
        //         iconSize: 37,
        //         onPressed: () {
        //           widget.onMenuPressed();
        //         },
        //       )
        // ],
      ),
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

  Widget searchCard() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(Icons.search),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Find our product"),
                  ),
                ),
                Icon(Icons.menu),
              ],
            ),
          ),
        ),
      );
}
