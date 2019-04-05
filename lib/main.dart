import 'package:flutter/material.dart';
import 'package:note_keeper/screens/note_details.dart';
import 'package:note_keeper/screens/note_list.dart';

void main() => runApp(NoteApp());

class NoteApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "NoteKeeper",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: NoteList() ,
    );
  }

}