import 'package:demo_13/ViewControllers/NotePage.dart';

import '../Models/Note.dart';
import 'package:flutter/material.dart';

class SearchNotes extends SearchDelegate<String> {

  final Note note;
  SearchNotes({this.note});

  final allNotes = [
    'salam',
    'hello',
    'hi',
    'how are you?',
    'how are they?',
    'nice to see you.',
    'apointment 6 pm.',
  ];

  final recentNotes = [
    'hi',
    'how are you?',
    'nice to see you.',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.notifications),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentNotes
        : allNotes.where((p) => p.startsWith(query)).toList();
    return ListView.builder(
      
      itemBuilder: (context, index) => ListTile(
        onTap: ()=>  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => NotePage(note),
      ),
    ),
            //  trailing: Icon(Icons.restore),
            leading: Icon(Icons.event_note),
            title: RichText(
              text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                children: [
                  TextSpan(
                    text: suggestionList[index].substring(query.length),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
      itemCount: suggestionList.length,
    );
  }
}
