import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ViewControllers/drower_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../Models/PlaceHolder.dart';

class ProfileOnePage extends StatelessWidget {
  var deviceSize;
  List<String> theme;

  //Column1
  Widget profileColumn() => Container(
        height: deviceSize.height * 0.24,
        child: FittedBox(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                //SizedBox(height: 20,),
                Column(
                  children: <Widget>[
                    Text(
                      "H M H",
                      style: TextStyle(fontWeight: FontWeight.bold,color: Color(
                      PlaceHolder.hexToInt(theme[10]),
                    )),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Developer",
                      style: TextStyle(fontSize: 10,color: Color(
                      PlaceHolder.hexToInt(theme[10]),
                    )),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.chat),
                        color: Color(
                      PlaceHolder.hexToInt(theme[10]),
                    ),
                        onPressed: () {
                          _textMe();
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              new BorderRadius.all(new Radius.circular(40.0)),
                          border: new Border.all(
                            color: Color(
                      PlaceHolder.hexToInt(theme[10]),
                    ),
                            width: 2.0,
                          ),
                        ),
                        child: CircleAvatar(
                          // backgroundImage: NetworkImage(
                          //     "https://avatars0.githubusercontent.com/u/12619420?s=460&v=4"),
                          backgroundImage: AssetImage("Assets/prof.jpg"),
                          foregroundColor:  Color(
                      PlaceHolder.hexToInt(theme[10]),
                    ),
                          radius: 30.0,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.call),
                        color: Color(
                      PlaceHolder.hexToInt(theme[10]),
                    ),
                        onPressed: () {
                          _launchcaller();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );

  //column2
  _textMe() async {
    // Android
    const uri = 'sms:+98 930 720 8270';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      const uri = 'sms:0098-930-720-8270';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }

  _launchcaller() async {
    const url = "tel:+989307208270";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //column3
  Widget descColumn() => Container(
        height: deviceSize.height * 0.13,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Text(
              "",
              style: TextStyle(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLines: 3,
              softWrap: true,
            ),
          ),
        ),
      );
  //column4
  Widget accountColumn() =>  Container(
          height: deviceSize.height * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(width: 20,),
              Column(
                children: <Widget>[
                  Text("Website",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Color(
                      PlaceHolder.hexToInt(theme[10]),
                    ))),
                  IconButton(
                    icon: Icon(Icons.language,color: Color(
                      PlaceHolder.hexToInt(theme[9]),
                    )),
                    onPressed: () {
                      launch('https://github.com/hadihmh');
                    },
                  )
                ],
              ),
              
              Column(
                children: <Widget>[
                  Text("Email", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Color(
                      PlaceHolder.hexToInt(theme[10]),
                    ))),
                  IconButton(
                      icon: Icon(Icons.mail,color: Color(
                      PlaceHolder.hexToInt(theme[9]),
                    )),
                      onPressed: () {
                        launch("mailto:hmhnexus5x@gmail.com");
                      })
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Myket",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Color(
                      PlaceHolder.hexToInt(theme[10]),
                    ))),
                  IconButton(
                      icon: Image.asset("Assets/myket.png",scale: 40,),
                      onPressed: () {
                        launch('myket://details?id=com.hmh.note');
                      })
                ],
              ),
              SizedBox(width: 20,),
            ],
          ),
        
      );

  Widget bodyData() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          profileColumn(),
          //CommonDivider(),
          //followColumn(deviceSize),
          //CommonDivider(),
          descColumn(),
          Divider(
            
                  color: Color(
                PlaceHolder.hexToInt(theme[9]),
              )
          ),
          SizedBox(
            height: 50,
          ),
          accountColumn()
        ],
      ),
    );
  }

  Widget _scaffold(BuildContext context) => WillPopScope(
        child:Scaffold(
          backgroundColor: Color(PlaceHolder.hexToInt(theme[1])),
          
        appBar: AppBar(
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
          title: Text("Help & Feedback Page",style: TextStyle(
                  color: Color(
                PlaceHolder.hexToInt(theme[1]),
              ))),
        ),
        body: bodyData(),
      ),onWillPop: () async {
          Future.value(false);
          _backToHome(context);
        },);

  @override
  Widget build(BuildContext context) {
    theme = PlaceHolder.theme;
    deviceSize = MediaQuery.of(context).size;
    return _scaffold(context);
  }
}
void _backToHome(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DrawerPage()));
  }

// Widget followColumn(Size deviceSize) => Container(
//       height: deviceSize.height * 0.13,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           Column(children: <Widget>[Text("YouTube"),Text("youtube.com/mtechviral")],
//             title: "1.5K",
//             subtitle: "Posts",
//           ),
//           Column(children: <Widget>[Text("YouTube"),Text("youtube.com/mtechviral")],
//             title: "2.5K",
//             subtitle: "Followers",
//           ),
//           Column(children: <Widget>[Text("YouTube"),Text("youtube.com/mtechviral")],
//             title: "10K",
//             subtitle: "Comments",
//           ),
//           Column(children: <Widget>[Text("YouTube"),Text("youtube.com/mtechviral")],
//             title: "1.2K",
//             subtitle: "Following",
//           )
//         ],
//       ),
//     );
