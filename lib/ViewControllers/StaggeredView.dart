import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../Models/Note.dart';
import '../Models/SqliteHandler.dart';
import '../Models/Utility.dart';
import '../Views/StaggeredTiles.dart';
import 'HomePage.dart';

class StaggeredGridPage extends StatefulWidget {
  final searchview;
  final notesViewType;
  final bool isArchive;
  const StaggeredGridPage(
      {Key key, this.notesViewType, this.searchview, this.isArchive})
      : super(key: key);
  @override
  _StaggeredGridPageState createState() => _StaggeredGridPageState();
}

class _StaggeredGridPageState extends State<StaggeredGridPage> {
  var noteDB = NotesDBHandler();
  List<Map<String, dynamic>> _allNotesInQueryResult = [];
  viewType notesViewType;

  @override
  void initState() {
    super.initState();
    this.notesViewType = widget.notesViewType;
  }

  @override
  void setState(fn) {
    super.setState(fn);
    this.notesViewType = widget.notesViewType;
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey _stagKey = GlobalKey();

    print("update needed?: ${CentralStation.updateNeeded}");
    if (CentralStation.updateNeeded) {
      if (widget.isArchive == null || widget.isArchive == false) {
        if (widget.searchview == null) {
          retrieveAllNotesFromDatabase(null);
        } else {
          retrieveAllNotesFromDatabase(widget.searchview);
        }
      } else if (widget.isArchive != null || widget.isArchive == true) {
        if (widget.searchview == null) {
          retrieveAllArchiveFromDatabase(null);
        } else {
          retrieveAllArchiveFromDatabase(widget.searchview);
        }
      }
    }
    return Container(
        child: Padding(
      padding: _paddingForView(context),
      child: new StaggeredGridView.count(
        key: _stagKey,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        crossAxisCount: _colForStaggeredView(context),
        children: List.generate(_allNotesInQueryResult.length, (i) {
          // return null;
          return _tileGenerator(i);
        }),
        staggeredTiles: _tilesForView(),
      ),
    ));
  }

  int _colForStaggeredView(BuildContext context) {
    if (widget.notesViewType == viewType.List) return 1;
    // for width larger than 600 on grid mode, return 3 irrelevant of the orientation to accommodate more notes horizontally
    return MediaQuery.of(context).size.width > 600 ? 3 : 2;
  }

  List<StaggeredTile> _tilesForView() {
    // Generate staggered tiles for the view based on the current preference.
    return List.generate(_allNotesInQueryResult.length, (index) {
      return StaggeredTile.fit(1);
    });
  }

  EdgeInsets _paddingForView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding;
    double top_bottom = 8;
    if (width > 500) {
      padding = (width) * 0.05; // 5% padding of width on both side
    } else {
      padding = 8;
    }
    return EdgeInsets.only(
        left: padding, right: padding, top: top_bottom, bottom: top_bottom);
  }

  MyStaggeredTile _tileGenerator(int i) {
    return MyStaggeredTile(Note(
        _allNotesInQueryResult[i]["id"],
        _allNotesInQueryResult[i]["title"] == null
            ? ""
            : utf8.decode(_allNotesInQueryResult[i]["title"]),
        _allNotesInQueryResult[i]["content"] == null
            ? ""
            : utf8.decode(_allNotesInQueryResult[i]["content"]),
        DateTime.fromMillisecondsSinceEpoch(
            _allNotesInQueryResult[i]["date_created"] * 1000),
        DateTime.fromMillisecondsSinceEpoch(
            _allNotesInQueryResult[i]["date_last_edited"] * 1000),
        Color(_allNotesInQueryResult[i]["note_color"]),
        _allNotesInQueryResult[i]['is_archived']
        ));
  }

  void retrieveAllNotesFromDatabase(String searchview) {
    // queries for all the notes from the database ordered by latest edited note. excludes archived notes.
    if (searchview == null) {
      var _testData = noteDB.selectAllNotes();
      _testData.then((value) {
        setState(() {
          this._allNotesInQueryResult = value;
          CentralStation.updateNeeded = false;
        });
      });
    } else {
      var _allNotes = noteDB.selectAllNotes();

      _allNotes.then((value) {
        this._allNotesInQueryResult = value;
      });

      _searchresult(searchview);
    }

    // var _testData =
    //     (widget.searchQuery == null) ? noteDB.selectAllNotes() : noteDB.selectSearchNotes(widget.searchQuery);
  }

  void _searchresult(String valueSearch) {
    List<Map<String, dynamic>> _foundNotesList = [];

    Iterable _dfgfoundNotesList =
        this._allNotesInQueryResult.where((Map<String, dynamic> note) {
      String _content = utf8.decode(note['content']);
      String _title = utf8.decode(note['title']);
      if (_content.toLowerCase().contains(valueSearch.toLowerCase()) ||
          _title.toLowerCase().contains(valueSearch.toLowerCase())) {
        return true;
      } else {
        return false;
      }
    });
    _foundNotesList = _dfgfoundNotesList.toList();

    setState(() {
      this._allNotesInQueryResult = _foundNotesList;
      CentralStation.updateNeeded = false;
    });
  }

  void retrieveAllArchiveFromDatabase(String searchview) {
    // queries for all the notes from the database ordered by latest edited note. excludes archived notes.
    if (searchview == null) {
      var _testData = noteDB.selectAllArchive();
      _testData.then((value) {
        setState(() {
          this._allNotesInQueryResult = value;
          CentralStation.updateNeeded = false;
        });
      });
    } else {
      var _allNotes = noteDB.selectAllArchive();

      _allNotes.then((value) {
        this._allNotesInQueryResult = value;
      });

      _searchArchiveResult(searchview);
    }

    // var _testData =
    //     (widget.searchQuery == null) ? noteDB.selectAllNotes() : noteDB.selectSearchNotes(widget.searchQuery);
  }

  void _searchArchiveResult(String valueSearch) {
    List<Map<String, dynamic>> _foundNotesList = [];

    Iterable _dfgfoundNotesList =
        this._allNotesInQueryResult.where((Map<String, dynamic> note) {
      String _content = utf8.decode(note['content']);
      String _title = utf8.decode(note['title']);
      if (_content.toLowerCase().contains(valueSearch.toLowerCase()) ||
          _title.toLowerCase().contains(valueSearch.toLowerCase())) {
        return true;
      } else {
        return false;
      }
    });
    _foundNotesList = _dfgfoundNotesList.toList();

    setState(() {
      this._allNotesInQueryResult = _foundNotesList;
      CentralStation.updateNeeded = false;
    });
  }
}
