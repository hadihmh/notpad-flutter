import 'package:flutter/material.dart';
import '../Models/PlaceHolder.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../ViewControllers/drower_page.dart';
import 'dart:io';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> theme = PlaceHolder.theme;

    return WillPopScope(
        child: Scaffold(
          backgroundColor: Color(PlaceHolder.hexToInt(theme[1])),
          appBar: AppBar(
            title: Text(
              "Help & Feedback Page",
              style: TextStyle(
                  color: Color(
                PlaceHolder.hexToInt(theme[1]),
              )),
            ),
            backgroundColor: Color(
              PlaceHolder.hexToInt(theme[0]),
            ),
            leading: IconButton(
              onPressed: () {
                _backToHome(context);
              },
              icon: Icon(
                MdiIcons.backburger,
                color: Color(PlaceHolder.hexToInt(theme[1])),
              ),
            ),
          ),
          body: Center(
            child: Container(
              child: Text(
                "There is nothing to show !!",
                style: TextStyle(
                    fontSize: 20,
                    color: Color(
                      PlaceHolder.hexToInt(theme[10]),
                    )),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          Future.value(false);
          _backToHome(context);
        });
  }

  void _backToHome(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DrawerPage()));
  }
}
