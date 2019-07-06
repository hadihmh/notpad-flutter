import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './drower_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/PlaceHolder.dart';

class SettingsOnePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SettingsOnePageState();
  }
}

class SettingsOnePageState extends State<SettingsOnePage> {
  int _themeValue = PlaceHolder.ts;
  int _fontValue = PlaceHolder.fs;

  Widget bodyData() => SingleChildScrollView(
        child: Theme(
            data: ThemeData(fontFamily: "Roboto"),
            child: Padding(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //1
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Theme Setting",
                      style: TextStyle(
                          color: Color(PlaceHolder.hexToInt(theme[10]))),
                    ),
                  ),

                  Card(
                    color: Color(PlaceHolder.hexToInt(theme[2])),
                    elevation: 5.0,
                    child: Column(
                      children: <Widget>[
                        // Container(
                        //   child: _bulidListTiles(),
                        // ),

                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 18),
                          child: ListTile(
                            leading: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromRGBO(76, 175, 80, 1),
                                    Color.fromRGBO(244, 67, 54, 1),
                                    Color.fromRGBO(253, 216, 53, 1)
                                  ],
                                  //colors: [Colors.green],
                                  tileMode: TileMode.repeated,
                                ),
                              ),
                            ),
                            title: Text(
                              "Theme",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color:
                                      Color(PlaceHolder.hexToInt(theme[10]))),
                            ),
                            trailing: Icon(Icons.arrow_drop_down),
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: ListTile(
                                leading: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromRGBO(66, 66, 66, 1),
                                          Color.fromRGBO(250, 250, 250, 1),
                                        ],
                                        //colors: [Colors.green],
                                        tileMode: TileMode.repeated,
                                      ),
                                    )),
                                title: Text("Grey"),
                                trailing: Radio(
                                  groupValue: _themeValue,
                                  onChanged: (int i) => setState(() {
                                        _themeValue = i;
                                        _bulidTheme().then((_) {
                                          setState(() {
                                            PlaceHolder.theme =
                                                PlaceHolder.theme1;
                                            theme = PlaceHolder.theme1;
                                            PlaceHolder.ts = 0;
                                          });
                                        });
                                      }),
                                  value: 0,
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: ListTile(
                                  leading: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: Colors.blueGrey)),
                                  title: Text("Blue Grey"),
                                  trailing: Radio(
                                    groupValue: _themeValue,
                                    onChanged: (int i) => setState(() {
                                          _themeValue = i;
                                          _bulidTheme().then((_) {
                                            setState(() {
                                              PlaceHolder.theme =
                                                  PlaceHolder.theme2;
                                              theme = PlaceHolder.theme2;
                                              PlaceHolder.ts = 1;
                                            });
                                          });
                                        }),
                                    value: 1,
                                  ),
                                )),
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: ListTile(
                                leading: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromRGBO(21, 101, 192, 1),
                                          Color.fromRGBO(144, 202, 249, 1),
                                        ],
                                        //colors: [Colors.green],
                                        tileMode: TileMode.repeated,
                                      ),
                                    )),
                                title: Text("Blue"),
                                trailing: Radio(
                                  groupValue: _themeValue,
                                  onChanged: (int i) => setState(() {
                                        _themeValue = i;
                                        _bulidTheme().then((_) {
                                          setState(() {
                                            PlaceHolder.theme =
                                                PlaceHolder.theme3;
                                            theme = PlaceHolder.theme3;
                                            PlaceHolder.ts = 2;
                                          });
                                        });
                                      }),
                                  value: 2,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 30, bottom: 18),
                              child: ListTile(
                                leading: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromRGBO(46, 125, 50, 1),
                                          Color.fromRGBO(220, 231, 117, 1),
                                        ],
                                        //colors: [Colors.green],
                                        tileMode: TileMode.repeated,
                                      ),
                                    )),
                                title: Text("Green"),
                                trailing: Radio(
                                  groupValue: _themeValue,
                                  onChanged: (int i) => setState(() {
                                        _themeValue = i;
                                        _bulidTheme().then((_) {
                                          setState(() {
                                            PlaceHolder.theme =
                                                PlaceHolder.theme4;
                                            theme = PlaceHolder.theme4;
                                            PlaceHolder.ts = 3;
                                          });
                                        });
                                      }),
                                  value: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  //2
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Font",
                      style: TextStyle(
                          color: Color(PlaceHolder.hexToInt(theme[10]))),
                    ),
                  ),
                  Card(
                    color: Color(PlaceHolder.hexToInt(theme[2])),
                    elevation: 5.0,
                    child: Column(
                      children: <Widget>[
                        // Container(
                        //   child: _bulidListTiles(),
                        // ),
                        Padding(
                          padding: EdgeInsets.only(top: 15, left: 10),
                          child: ListTile(
                            leading: Icon(
                              Icons.font_download,
                              size: 32,
                              color: Color(PlaceHolder.hexToInt(theme[10])),
                            ),
                            title: Text(
                              "Font Size",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color:
                                      Color(PlaceHolder.hexToInt(theme[10]))),
                            ),
                            trailing: Icon(Icons.arrow_drop_down),
                          ),
                        ),

                        Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 23),
                              child: ListTile(
                                leading: Icon(
                                  Icons.font_download,
                                  size: 25,
                                  color: Color(PlaceHolder.hexToInt(theme[10])),
                                ),
                                title: Text("Small"),
                                trailing: Radio(
                                  groupValue: _fontValue,
                                  onChanged: (int i) => setState(() {
                                        _fontValue = i;
                                        _bulidTheme().then((_) {
                                          setState(() {
                                            PlaceHolder.fontsize =
                                                PlaceHolder.fontsize1;

                                            PlaceHolder.fs = 0;
                                          });
                                        });
                                      }),
                                  value: 0,
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 23),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.font_download,
                                    size: 30,
                                    color:
                                        Color(PlaceHolder.hexToInt(theme[10])),
                                  ),
                                  title: Text(
                                    "Medium",
                                    style: TextStyle(fontSize: 23),
                                  ),
                                  trailing: Radio(
                                    groupValue: _fontValue,
                                    onChanged: (int i) => setState(() {
                                          _fontValue = i;
                                          _bulidTheme().then((_) {
                                            setState(() {
                                              PlaceHolder.fontsize =
                                                  PlaceHolder.fontsize2;

                                              PlaceHolder.fs = 1;
                                            });
                                          });
                                        }),
                                    value: 1,
                                  ),
                                )),
                            Padding(
                              padding: EdgeInsets.only(left: 23, bottom: 15),
                              child: ListTile(
                                leading: Icon(
                                  Icons.font_download,
                                  size: 35,
                                  color: Color(PlaceHolder.hexToInt(theme[10])),
                                ),
                                title: Text(
                                  "Large",
                                  style: TextStyle(fontSize: 30),
                                ),
                                trailing: Radio(
                                  groupValue: _fontValue,
                                  onChanged: (int i) => setState(() {
                                        _fontValue = i;
                                        _bulidTheme().then((_) {
                                          setState(() {
                                            PlaceHolder.fontsize =
                                                PlaceHolder.fontsize3;

                                            PlaceHolder.fs = 2;
                                          });
                                        });
                                      }),
                                  value: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              padding: EdgeInsets.only(right: 2, left: 2, bottom: 18),
            )),
      );
  List<String> theme;
  @override
  void initState() {
    theme = PlaceHolder.theme ?? PlaceHolder.theme1;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _readyToPop,
            icon: Icon(
              MdiIcons.backburger,
              color: Color(PlaceHolder.hexToInt(theme[1])),
            ),
          ),
          title: Text(
            "Device Settings",
            style: TextStyle(color: Color(PlaceHolder.hexToInt(theme[1]))),
          ),
          backgroundColor: Color(PlaceHolder.hexToInt(theme[0])),
        ),
        // appTitle: "Device Settings",
        // showDrawer: false,
        // showFAB: false,
        backgroundColor: Color(PlaceHolder.hexToInt(theme[1])),
        body: bodyData(),
      ),
      onWillPop: () async => Future.value(false),
    );
  }

  void _readyToPop() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DrawerPage()));
  }

  _bulidTheme() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    if (_fontValue == 0) {
      pref.setString("fontsize", "f1");
    } else if (_fontValue == 1) {
      pref.setString("fontsize", "f2");
    } else if (_fontValue == 2) {
      pref.setString("fontsize", "f3");
    }

    if (_themeValue == 0) {
      pref.setString("theme", "t1");
    } else if (_themeValue == 1) {
      pref.setString("theme", "t2");
    } else if (_themeValue == 2) {
      pref.setString("theme", "t3");
    } else if (_themeValue == 3) {
      pref.setString("theme", "t4");
    }
  }
}
