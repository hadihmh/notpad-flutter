import 'package:demo_13/ViewControllers/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../Models/Note.dart';
import '../Models/SqliteHandler.dart';
import 'dart:async';
import '../Models/Utility.dart';
import '../Views/MoreOptionsSheet.dart';
import 'package:share/share.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

import 'drower_page.dart';

class NotePage extends StatefulWidget {
  final Note noteInEditing;

  NotePage(this.noteInEditing);
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  var note_color;
  bool _isNewNote = false;
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();

  String _titleFrominitial;
  String _contentFromInitial;
  DateTime _lastEditedForUndo;
  int _isArchive;

  //BuildContext contextForSnak;

  var _editableNote;

  // the timer variable responsible to call persistData function every 5 seconds and cancel the timer when the page pops.
  Timer _persistenceTimer;

  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _editableNote = widget.noteInEditing;
    _titleController.text = _editableNote.title;
    _contentController.text = _editableNote.content;
    note_color = _editableNote.note_color;
    _lastEditedForUndo = widget.noteInEditing.date_last_edited;

    _titleFrominitial = widget.noteInEditing.title;
    _contentFromInitial = widget.noteInEditing.content;
    _isArchive = widget.noteInEditing.is_archived;

    if (widget.noteInEditing.id == -1) {
      _isNewNote = true;
    }
    _persistenceTimer = new Timer.periodic(Duration(seconds: 5), (timer) {
      // call insert query here
      print("5 seconds passed");
      print("editable note id: ${_editableNote.id}");
      _persistData();
    });
  }

  @override
  Widget build(BuildContext context) {
    //contextForSnak=context;

    //final key = new GlobalKey<ScaffoldState>();
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    if (_editableNote.id == -1 && _editableNote.title.isEmpty) {
      FocusScope.of(context).requestFocus(_contentFocus);
    }

    return WillPopScope(
        child: Scaffold(
          //resizeToAvoidBottomInset: false,
          key: _globalKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            brightness: Brightness.light,
            leading: IconButton(
              onPressed: _readyToPop,
              icon: Icon(
                MdiIcons.backburger,
                color: Colors.black,
              ),
            ),
            actions: _archiveAction(context),
            elevation: 1,
            backgroundColor: note_color,
            title: _pageTitle(),
          ),
          body: _body(context, deviceHeight, deviceWidth),
        ),
        onWillPop: () async => Future.value(false)
        // Navigator.push(
        // context, MaterialPageRoute(builder: (context) => DrawerPage()));

        );
  }

  Widget _body(BuildContext ctx, double deviceHeight, double deviceWidth) {
    return Container(
        color: note_color,
        padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
        child: SafeArea(
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5),
//          decoration: BoxDecoration(border: Border.all(color: CentralStation.borderColor,width: 1 ),borderRadius: BorderRadius.all(Radius.circular(10)) ),
                child: TextFormField(
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Title"),
                  onSaved: (str) => {updateNoteObject()},
                  maxLines: null,
                  controller: _titleController,
                  focusNode: _titleFocus,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  cursorColor: Colors.blue,
                  // backgroundCursorColor: Colors.blue
                ),
                //color: Colors.white,

                //sdfdheight: 100,
              ),
              Divider(
                color: CentralStation.borderColor,
              ),
              Container(
                  //height: 100,
                  //color:Colors.black,

                  padding: EdgeInsets.all(5),
//    decoration: BoxDecoration(border: Border.all(color: CentralStation.borderColor,width: 1),borderRadius: BorderRadius.all(Radius.circular(10)) ),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Note",
                        fillColor: Colors.white),
                    onSaved: (str) => {updateNoteObject()},
                    maxLines: null, // line limit extendable later
                    controller: _contentController,
                    focusNode: _contentFocus,

                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    //backgroundCursorColor: Colors.red,
                    cursorColor: Colors.blue,
                  ))
            ],
          ),
          left: true,
          right: true,
          top: false,
          bottom: false,
        ));
  }

  Widget _pageTitle() {
    return Text(_editableNote.id == -1 ? "New Note" : "Edit Note");
  }

  List<Widget> _archiveAction(BuildContext context) {
    List<Widget> actions = [];
    if (widget.noteInEditing.id != -1) {
      actions.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => _undo(),
            child: Icon(
              Icons.undo,
              color: CentralStation.fontColor,
            ),
          ),
        ),
      ));
    }
    if (widget.noteInEditing.id != -1) {
      actions.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: InkWell(
            child: GestureDetector(
              onTap: () => _archivePopup(context),
              child: Icon(
                Icons.archive,
                color: CentralStation.fontColor,
              ),
            ),
          ),
        ),
      );
    }
    actions += [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => bottomSheet(context),
            // onTap: () => _showWarningDailog(context),
            child: Icon(
              Icons.more_vert,
              color: CentralStation.fontColor,
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => {_saveAndStartNewNote(context)},
            child: Icon(
              Icons.add,
              color: CentralStation.fontColor,
            ),
          ),
        ),
      )
    ];
    return actions;
  }

  void bottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return MoreOptionsSheet(
            color: note_color,
            callBackColorTapped: _changeColor,
            callBackOptionTapped: bottomSheetOptionTappedHandler,
            date_last_edited: _editableNote.date_last_edited,
          );
        });
  }

  void _persistData() {
    updateNoteObject();

    if (_editableNote.content.isNotEmpty) {
      var noteDB = NotesDBHandler();

      if (_editableNote.id == -1) {
        Future<int> autoIncrementedId =
            noteDB.insertNote(_editableNote, true); // for new note
        // set the id of the note from the database after inserting the new note so for next persisting
        autoIncrementedId.then((value) {
          _editableNote.id = value;
        });
      } else {
        noteDB.insertNote(
            _editableNote, false); // for updating the existing note
      }
    }
  }

// this function will ne used to save the updated editing value of the note to the local variables as user types
  void updateNoteObject() {
    _editableNote.content = _contentController.text;
    _editableNote.title = _titleController.text;
    _editableNote.note_color = note_color;
    _editableNote.is_archived = _isArchive;
    // _editableNote.
    print("new content: ${_editableNote.content}");
    print(widget.noteInEditing);
    print(_editableNote);

    print("same title? ${_editableNote.title == _titleFrominitial}");
    print("same content? ${_editableNote.content == _contentFromInitial}");

    if (!(_editableNote.title == _titleFrominitial &&
            _editableNote.content == _contentFromInitial) ||
        (_isNewNote)) {
      // No changes to the note
      // Change last edit time only if the content of the note is mutated in compare to the note which the page was called with.
      _editableNote.date_last_edited = DateTime.now();
      print("Updating date_last_edited");
      CentralStation.updateNeeded = true;
    }
  }

  void bottomSheetOptionTappedHandler(moreOptions tappedOption) {
    print("option tapped: $tappedOption");
    switch (tappedOption) {
      case moreOptions.delete:
        {
          if (_editableNote.id != -1) {
            _deleteNote(_globalKey.currentContext);
          } else {
            _exitWithoutSaving(context);
          }
          break;
        }

      case moreOptions.copy:
        {
          _copy();
          break;
        }
      default:
        {
          //statements;
        }
        break;
    }
  }

  void _deleteNote(BuildContext context) {
    if (_editableNote.id != -1) {
      //_showWarningDailog(_globalKey.currentContext);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm ?"),
              content: Text("This note will be deleted permanently"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      _persistenceTimer.cancel();
                      var noteDB = NotesDBHandler();
                      Navigator.of(context).pop();
                      noteDB.deleteNote(_editableNote);
                      CentralStation.updateNeeded = true;

                      Navigator.of(context).pop();
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

  void _changeColor(Color newColorSelected) {
    print("note color changed");
    setState(() {
      note_color = newColorSelected;
      _editableNote.note_color = newColorSelected;
    });
    _persistColorChange();
    CentralStation.updateNeeded = true;
  }

  void _persistColorChange() {
    if (_editableNote.id != -1) {
      var noteDB = NotesDBHandler();
      _editableNote.note_color = note_color;
      noteDB.insertNote(_editableNote, false);
    }
  }

  void _saveAndStartNewNote(BuildContext context) {
    _persistenceTimer.cancel();
    _persistData();
    var emptyNote =
        new Note(-1, "", "", DateTime.now(), DateTime.now(), Colors.white, 0);
    Navigator.of(context).pop();
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => NotePage(emptyNote)));
  }

  Future<bool> _readyToPop() async {
    _persistenceTimer.cancel();
    //show saved toast after calling _persistData function.

    _persistData();
    //print("salllllllllllllllllllllllllllll");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DrawerPage()));
    //return true;
  }

  void _archivePopup(BuildContext context) {
    if (_editableNote.id != -1) {
      if (_isArchive == 0) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Confirm ?"),
                content: Text("This note will be archived !"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => _archiveThisNote(context),
                      child: Text("Yes")),
                  FlatButton(
                      onPressed: () => {Navigator.of(context).pop()},
                      child: Text("No"))
                ],
              );
            });
      } else if (_isArchive == 1) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Confirm ?"),
                content: Text("This note will extract from archive !"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => _archiveThisNote(context),
                      child: Text("Yes")),
                  FlatButton(
                      onPressed: () => {Navigator.of(context).pop()},
                      child: Text("No"))
                ],
              );
            });
      }
    } else {
      _exitWithoutSaving(context);
    }
  }

  void _exitWithoutSaving(BuildContext context) {
    _persistenceTimer.cancel();
    CentralStation.updateNeeded = false;
    Navigator.of(context).pop();
  }

  void _archiveThisNote(BuildContext context) {
    Navigator.of(context).pop();
    // set archived flag to true and send the entire note object in the database to be updated
    if (_isArchive == 0) {
      _editableNote.is_archived = 1;
    } else if (_isArchive == 1) {
      _editableNote.is_archived = 0;
    }
    
    var noteDB = NotesDBHandler();
    noteDB.archiveNote(_editableNote);
    // update will be required to remove the archived note from the staggered view
    CentralStation.updateNeeded = true;
    _persistenceTimer.cancel(); // shutdown the timer

    Navigator.of(context).pop(); // pop back to staggered view
    // TODO: OPTIONAL show the toast of deletion completion
    // Scaffold.of(context).showSnackBar(new SnackBar(content: Text("deleted")));
    showToast("Archived !", gravity: Toast.BOTTOM, duration: 2);
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void _copy() {
    if (_editableNote.id != -1) {
      Clipboard.setData(new ClipboardData(text: _editableNote.content));
      //Navigator.of(_globalKey.currentContext).pop();
      _displaySnackBar('Note Copied To Clipboard ! ');
    }
    // var noteDB = NotesDBHandler();
    // Note copy = Note(-1, _editableNote.title, _editableNote.content,
    //     DateTime.now(), DateTime.now(), _editableNote.note_color);

    // var status = noteDB.copyNote(copy);
    // status.then((query_success) {
    //   if (query_success) {
    //     CentralStation.updateNeeded = true;
    //     Navigator.of(_globalKey.currentContext).pop();
    //   }
    // });
  }

  _displaySnackBar(String showtext) {
    final snackBar = SnackBar(
      content: Text(
        showtext,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(milliseconds: 400),
      backgroundColor: Colors.black,
    );
    _globalKey.currentState.showSnackBar(snackBar);
  }

  void _undo() {
    _titleController.text = _titleFrominitial; // widget.noteInEditing.title;
    _contentController.text =
        _contentFromInitial; // widget.noteInEditing.content;
    _editableNote.date_last_edited =
        _lastEditedForUndo; // widget.noteInEditing.date_last_edited;
  }
}
