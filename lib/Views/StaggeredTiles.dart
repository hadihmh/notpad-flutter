import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../ViewControllers/NotePage.dart';
import '../Models/Note.dart';
import '../Models/Utility.dart';
import '../Models/PlaceHolder.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import '../Models/SqliteHandler.dart';

class MyStaggeredTile extends StatefulWidget {
  final Note note;
  MyStaggeredTile(this.note);
  @override
  _MyStaggeredTileState createState() => _MyStaggeredTileState();
}

class _MyStaggeredTileState extends State<MyStaggeredTile> {
  GlobalKey btnKey = GlobalKey();
  String _content;
  double _fontSize;
  Color tileColor;
  String title;
  int _isDeleted;
  int _isArchive;
  List<String> theme = PlaceHolder.theme;

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;

    _content = widget.note.content;
    _isDeleted = widget.note.is_deleted;
    _fontSize = _determineFontSizeForContent();
    tileColor = widget.note.note_color;
    title = widget.note.title;
    _isArchive = widget.note.is_archived;

    return GestureDetector(
      key: btnKey,
      onLongPress: () {
        _bulidPopUp();
      },
      onTap: () => _noteTapped(context),
      child: Container(
        decoration: BoxDecoration(
            border: tileColor == Colors.white
                ? Border.all(color: CentralStation.borderColor)
                : null,
            color: tileColor,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        padding: EdgeInsets.all(8),
        child: constructChild(),
      ),
      //child:Text("data"),),
    );
  }

  void _copy() {
    Clipboard.setData(new ClipboardData(text: _content));

    showToast("Note Copied To Clipboard !", gravity: Toast.BOTTOM, duration: 2);
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void _noteTapped(BuildContext ctx) {
    CentralStation.updateNeeded = false;
    Navigator.push(
        ctx, MaterialPageRoute(builder: (ctx) => NotePage(widget.note)));
  }

  void _bulidPopUp() {
    if (PlaceHolder.isPopUp == true) {
    } else if (PlaceHolder.isPopUp == false) {
      customBackground();
    }
  }

  void customBackground() {
    PopupMenu menu;
    if (_isArchive == 0 && _isDeleted == 0) {
      menu = PopupMenu(
        backgroundColor: Color(PlaceHolder.hexToInt(theme[10])),
          lineColor: Colors.white,
          highlightColor: Color(PlaceHolder.hexToInt(theme[2])),
          items: [
            MenuItem(
                title: 'Copy',
                image: Icon(
                  Icons.content_copy,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Open',
                image: Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Delete',
                image: Icon(
                  Icons.delete,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Archive',
                image: Icon(
                  Icons.archive,
                  color: Colors.white,
                )),
          ],
          onClickMenu: onClickMenu,
          onDismiss: onDismiss);
    } else if (_isDeleted == 1) {
      menu = PopupMenu(
        backgroundColor: Color(PlaceHolder.hexToInt(theme[10])),
          lineColor: Colors.white,
          highlightColor: Color(PlaceHolder.hexToInt(theme[2])),
          items: [
            MenuItem(
                title: 'Copy',
                image: Icon(
                  Icons.content_copy,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Open',
                image: Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Delete',
                image: Icon(
                  Icons.delete,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Restore',
                image: Icon(
                  Icons.restore_from_trash,
                  color: Colors.white,
                )),
          ],
          onClickMenu: onClickMenu,
          onDismiss: onDismiss);
    } else if (_isArchive == 1) {
      menu = PopupMenu(
        backgroundColor: Color(PlaceHolder.hexToInt(theme[10])),
          lineColor: Colors.white,
          highlightColor: Color(PlaceHolder.hexToInt(theme[2])),
          items: [
            MenuItem(
                title: 'Copy',
                image: Icon(
                  Icons.content_copy,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Open',
                image: Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Delete',
                image: Icon(
                  Icons.delete,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Unarchive',
                image: Icon(
                  Icons.unarchive,
                  color: Colors.white,
                )),
          ],
          onClickMenu: onClickMenu,
          onDismiss: onDismiss);
    } else if (_isArchive == 1 && _isDeleted == 1) {
      menu = PopupMenu(
        backgroundColor: Color(PlaceHolder.hexToInt(theme[10])),
          lineColor: Colors.white,
          highlightColor: Color(PlaceHolder.hexToInt(theme[2])),
          items: [
            MenuItem(
                title: 'Copy',
                image: Icon(
                  Icons.content_copy,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Open',
                image: Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Delete',
                image: Icon(
                  Icons.delete,
                  color: Colors.white,
                )),
            MenuItem(
                title: 'Restore',
                image: Icon(
                  Icons.restore_from_trash,
                  color: Colors.white,
                )),
          ],
          onClickMenu: onClickMenu,
          onDismiss: onDismiss);
    }
    menu.show(widgetKey: btnKey);

    PlaceHolder.isPopUp = true;
  }

  void onClickMenu(MenuItemProvider item) {
    print('Click menu -> ${item.menuTitle}');
    String itemClick = item.menuTitle;
    if (itemClick == "Copy") {
      _copy();
    } else if (itemClick == "Open") {
      _noteTapped(context);
    } else if (itemClick == "Delete") {
      _deleteNote(context);
    } else if (itemClick == "Archive") {
      _archivePopup();
    } else if (itemClick == "Unarchive") {
      _unArchivePopup();
    } else if (itemClick == "Restore") {
      _unDelete();
    }
  }

  void onDismiss() {
    print('Menu is closed');
    PlaceHolder.isPopUp = false;
  }

  Widget constructChild() {
    List<Widget> contentsOfTiles = [];

    if (widget.note.title.length != 0) {
      contentsOfTiles.add(
        AutoSizeText(
          title,
          style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
          maxLines: widget.note.title.length == 0 ? 1 : 3,
          textScaleFactor: 1.5,
        ),
      );
      contentsOfTiles.add(
        Divider(
          color: Colors.transparent,
          height: 6,
        ),
      );
    }

    contentsOfTiles.add(AutoSizeText(
      _content,
      style: TextStyle(fontSize: _fontSize),
      maxLines: 10,
      textScaleFactor: 1.5,
    ));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: contentsOfTiles);
  }

  double _determineFontSizeForContent() {
    int charCount = _content.length + widget.note.title.length;
    double fontSize = 23.0;
    if (PlaceHolder.fontsize == 13.0) {
      fontSize = 13.0;
      if (charCount > 110) {
        fontSize = 13;
      } else if (charCount > 80) {
        fontSize = 9;
      } else if (charCount > 50) {
        fontSize = 11;
      } else if (charCount > 20) {
        fontSize = 13;
      }
    } else if (PlaceHolder.fontsize == 23.0) {
      fontSize = 23.0;
      if (charCount > 110) {
        fontSize = 17;
      } else if (charCount > 80) {
        fontSize = 19;
      } else if (charCount > 50) {
        fontSize = 21;
      } else if (charCount > 20) {
        fontSize = 23;
      }
    } else if (PlaceHolder.fontsize == 30.0) {
      fontSize = 30.0;
      if (charCount > 110) {
        fontSize = 24;
      } else if (charCount > 80) {
        fontSize = 26;
      } else if (charCount > 50) {
        fontSize = 28;
      } else if (charCount > 20) {
        fontSize = 30;
      }
    }

    return fontSize;
  }

  void _deleteNote(BuildContext context) {
    if (_isDeleted == 0) {
      var noteDB = NotesDBHandler();
      setState(() {
        noteDB.deleteNote(widget.note);
        CentralStation.updateNeeded = true;

        PlaceHolder.sstate();
      });
      showToast("Moved to Trash !", gravity: Toast.BOTTOM, duration: 2);
    } else if (_isDeleted == 1) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm ?"),
              content: Text("This note will be deleted permanently"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      setState(() {
                        var noteDB = NotesDBHandler();

                        noteDB.deleteNote(widget.note);
                        CentralStation.updateNeeded = true;

                        Navigator.of(context).pop();
                        PlaceHolder.tstate();
                      });
                      showToast("Deleted !",
                          gravity: Toast.BOTTOM, duration: 2);
                    },
                    child: Text("Yes")),
                FlatButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: Text("No"))
              ],
            );
          });
    }
  }

  void _archivePopup() {
    setState(() {
      widget.note.is_archived = 1;

      var noteDB = NotesDBHandler();
      noteDB.archiveNote(widget.note);
      CentralStation.updateNeeded = true;
      PlaceHolder.sstate();
    });
    showToast("Archived !", gravity: Toast.BOTTOM, duration: 2);
  }

  void _unArchivePopup() {
    setState(() {
      widget.note.is_archived = 0;

      var noteDB = NotesDBHandler();
      noteDB.archiveNote(widget.note);
      CentralStation.updateNeeded = true;
      PlaceHolder.sstate();
    });
    showToast("Unarchived !", gravity: Toast.BOTTOM, duration: 2);
  }

  void _unDelete() {
    var noteDB = NotesDBHandler();
    setState(() {
      widget.note.is_deleted = 0;

      noteDB.insertNote(widget.note, false);
      CentralStation.updateNeeded = true;
      PlaceHolder.tstate();
    });
    showToast("Restored !", gravity: Toast.BOTTOM, duration: 2);
  }
}
