import 'package:flutter/material.dart';
import './StaggeredView.dart';
import '../Models/Utility.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './drower_page.dart';



class TrashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TrashPageState();
  }
}

class TrashPageState extends State<TrashPage> {
  var notesViewType;

  @override
  void initState() {
    CentralStation.updateNeeded = true;
    notesViewType = 0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            actions: <Widget>[
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
                color: Colors.black,
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.grey,
            centerTitle: true,
            title: Text("Trash Page"),
          ),
          body: SafeArea(
            child: _body(),
            right: true,
            left: true,
            top: true,
            bottom: true,
          ),
        ),
        onWillPop: () async => Future.value(false));
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
