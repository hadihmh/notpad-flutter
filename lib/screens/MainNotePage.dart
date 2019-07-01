import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';

class MainNotePage extends KFDrawerContent {
  MainNotePage({
    Key key,
  });

  @override
  _MainNotePageState createState() => _MainNotePageState();
}

class _MainNotePageState extends State<MainNotePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  child: Material(
                    shadowColor: Colors.transparent,
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                      onPressed: widget.onMenuPressed,
                    ),
                  ),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
