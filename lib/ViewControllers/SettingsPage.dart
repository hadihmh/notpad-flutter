import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './drower_page.dart';

class SettingsOnePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SettingsOnePageState();
  }
}

class SettingsOnePageState extends State<SettingsOnePage> {
  int selectedFoodVariants = 0;
  int selectedPortionCounts = 0;
  int selectedPortionSize = 0;
  int _themeValue = 0;
  int _fontValue = 0;
  List<String> _fontSize = [
    "Chicken grilled",
    "Pork grilled",
    "Vegetables as is",
    "Cheese as is",
    "Bread tasty"
  ];

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
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),

                  Card(
                    color: Colors.white,
                    elevation: 5.0,
                    child: Column(
                      children: <Widget>[
                        // Container(
                        //   child: _bulidListTiles(),
                        // ),

                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 10),
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
                                  fontWeight: FontWeight.bold, fontSize: 20),
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
                                  onChanged: (int i) =>
                                      setState(() => _themeValue = i),
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
                                          color: Colors.black)),
                                  title: Text("Dark Mode"),
                                  trailing: Radio(
                                    groupValue: _themeValue,
                                    onChanged: (int i) =>
                                        setState(() => _themeValue = i),
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
                                  onChanged: (int i) =>
                                      setState(() => _themeValue = i),
                                  value: 2,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 30, bottom: 13),
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
                                  onChanged: (int i) =>
                                      setState(() => _themeValue = i),
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
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: Column(
                      children: <Widget>[
                        // Container(
                        //   child: _bulidListTiles(),
                        // ),
                        Padding(
                          padding: EdgeInsets.only(top: 10, left: 10),
                          child: ListTile(
                            leading: Icon(
                              Icons.font_download,
                              size: 32,
                            ),
                            title: Text(
                              "Font Size",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
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
                                ),
                                title: Text("Small"),
                                trailing: Radio(
                                  groupValue: _fontValue,
                                  onChanged: (int i) =>
                                      setState(() => _fontValue = i),
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
                                  ),
                                  title: Text(
                                    "Medium",
                                    style: TextStyle(fontSize: 23),
                                  ),
                                  trailing: Radio(
                                    groupValue: _fontValue,
                                    onChanged: (int i) =>
                                        setState(() => _fontValue = i),
                                    value: 1,
                                  ),
                                )),
                            Padding(
                              padding: EdgeInsets.only(left: 23, bottom: 10),
                              child: ListTile(
                                leading: Icon(
                                  Icons.font_download,
                                  size: 35,
                                ),
                                title: Text(
                                  "Large",
                                  style: TextStyle(fontSize: 30),
                                ),
                                trailing: Radio(
                                  groupValue: _fontValue,
                                  onChanged: (int i) => setState(() {
                                        _fontValue = i;
                                        print(_fontValue);
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
              padding: EdgeInsets.only(right: 2, left: 2, bottom: 13),
            )),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child:Scaffold(
      appBar: AppBar(
        leading: IconButton(
              onPressed: _readyToPop,
              icon: Icon(
                MdiIcons.backburger,
                color: Colors.black,
              ),
            ),
        title: Text("Device Settings"),
        backgroundColor: Colors.grey,
      ),
      // appTitle: "Device Settings",
      // showDrawer: false,
      // showFAB: false,
      backgroundColor: Colors.grey.shade300,
      body: bodyData(),
    ) ,onWillPop:() async => Future.value(false) ,); 
  }
void _readyToPop(){
  Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DrawerPage()));
}
  Widget _bulidListTiles() {
    return ExpansionTile(
      title: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          ListTile(
            //onTap: (){},
            // leading: Icon(
            //   Icons.volume_up,
            //   //size: 10,
            //   color: Colors.green,
            // ),
            title: Text(
              _fontSize[selected],
              textAlign: TextAlign.left,
            ),
            //trailing: Icon(Icons.arrow_right),
          ),
        ],
      ),
      children: <Widget>[
        Column(
          children: _buildExpandableContent(_fontSize),
        ),
      ],
    );
  }

  int selected = 0;
  List<Widget> _buildExpandableContent(List fs) {
    List<Widget> columnContent = [];

    for (int i = 0; i < fs.length; i++) {
      columnContent.add(
        ListTile(
          onTap: () {
            setState(() {
              selected = i;
            });
          },
          title: Text(
            fs[i],
            style: TextStyle(fontSize: 18.0),
          ),
          leading: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                selected = i;
              });
            },
          ),
        ),
      );
    }
    return columnContent;
  }
}
