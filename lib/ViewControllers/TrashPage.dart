import 'package:flutter/material.dart';
import './StaggeredView.dart';
import '../Models/Utility.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './drower_page.dart';
import 'dart:io';
import '../Models/PlaceHolder.dart';

class TrashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TrashPageState();
  }
}

class TrashPageState extends State<TrashPage> {
  
  List<String> theme=PlaceHolder.theme;
  var notesViewType;

  @override
  void initState() {
    CentralStation.updateNeeded = true;
    notesViewType = 0;
  }

  @override
  Widget build(BuildContext context) {
    PlaceHolder.tstate=_trashSState;
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                color: Color(PlaceHolder.hexToInt(theme[1])),
                icon: Icon(
                  notesViewType == 1
                      ? Icons.developer_board
                      : Icons.view_headline,
                  color: Color(PlaceHolder.hexToInt(theme[1])),
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
            leading: IconButton(
              onPressed: _backToHome,
              icon: Icon(
                MdiIcons.backburger,
                color: Color(PlaceHolder.hexToInt(theme[1])),
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Color(PlaceHolder.hexToInt(theme[0])),
            centerTitle: true,
            title: Text("Trash Page",style: TextStyle(color: Color(PlaceHolder.hexToInt(theme[1]))),),
          ),
          backgroundColor: Color(PlaceHolder.hexToInt(theme[1])),
          body: SafeArea(
            child: _body(),
            right: true,
            left: true,
            top: true,
            bottom: true,
          ),
        ),
        onWillPop: () async {
          Future.value(false);
          _backToHome();
          // Navigator.of(context).pop(true);
          //exit(0);
        });
    ;
  }

  Widget _body() {
    return Container(
        child: StaggeredGridPage(
      isTrash: true,
      notesViewType: notesViewType,
    ));
  }

  void _backToHome() {
    CentralStation.updateNeeded = true;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DrawerPage()));
  }
void _trashSState(){
  setState(() {
   int a=0; 
  });
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
}
