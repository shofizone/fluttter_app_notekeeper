import 'package:flutter/material.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);


  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}
class NoteDetailState extends State<NoteDetail> {



  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();
  bool _sw = false;
  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(LineAwesomeIcons.angle_left),
          color: Colors.orange,
          onPressed: () {
            moveToLastScreen();
          },
        ),
        actions: <Widget>[
           Switch(
                  value: _sw,
                  onChanged: (bool value) {
                    setState(() {
                      _sw = value;
                      if (_sw) {
                        updatePriorityAsInt(1);
                      } else {
                        updatePriorityAsInt(2);
                      }
                    });
                  }),

           IconButton(
            icon: Icon(LineAwesomeIcons.close),
            color: Colors.orange,
            tooltip: "Delete Note",
            onPressed: () {

              setState(() {
                _delete();
              });

            },
          ),

     IconButton(
            icon: Icon(LineAwesomeIcons.check),
            color: Colors.orange,
            tooltip: "Save Note",
            onPressed: () {
              setState(() {
                _save();
              });

            },
          ),

        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: ListView(
          children: <Widget>[
            // First element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 10.0,left: 10,right: 10),
              child: TextField(
                controller: titleController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Something changed in Title Text Field');
                  updateTitle();
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Title Here . . .',
                  labelStyle: textStyle,
                ),
              ),
            ),

            // Second Element
            Padding(
              padding: EdgeInsets.only(bottom: 15.0,left: 10,right: 10),
              child: TextField(
                controller: descriptionController,
                maxLines: 25,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Something changed in Description Text Field');
                  updateDescription();
                },
                decoration: InputDecoration(
                    hintText: 'Description . . .',
                    labelStyle: textStyle,
                    border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void moveToLastScreen() {
   // Navigator.of(context,rootNavigator: true).pop();
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(int value) {
    switch (value) {
      case 1:
        note.priority = 1; //high
        break;
      case 2:
        note.priority = 2; //low
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }


}
