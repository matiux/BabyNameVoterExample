import 'package:baby_name_voter/app_state.dart';
import 'package:baby_name_voter/widgets/row_connection_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNamePage extends StatelessWidget {
  static final String routeName = "/addname";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add baby name')),
        body: Container(
          child: Column(
            children: <Widget>[
              ScopedModelDescendant<AppStateModel>(builder: (context, child, model) => RowConnectionStateWidget(state: model.connectionStatus())),
              MyInsertNameApp(),
            ],
          ),
        ));
  }
}

class MyInsertNameApp extends StatefulWidget {
  @override
  _MyInsertNameAppState createState() => _MyInsertNameAppState();
}

class _MyInsertNameAppState extends State {
  String _name = '';

  void _handleTextChange(String v) {
    setState(() {
      _name = v;
    });
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  void _saveName() async {
    if (_name.toLowerCase().trim().isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final DocumentReference id = Firestore.instance.collection('babies').document(_name.toLowerCase().trim());

    bool voted = prefs.getBool('voted.' + _name) ?? false;

    if (voted) {
      Navigator.pop(context, "Name already voted: $_name");
      return;
    }

    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(id);

      if (freshSnap.exists) {
        await transaction.update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});

        Navigator.pop(context, "Baby name voted: $_name");
      } else {
        await transaction.set(id, {'name': capitalize(_name), 'votes': 1});

        Navigator.pop(context, "Baby name created: $_name");
      }
      prefs.setBool('voted.' + _name, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              autofocus: true,
              onChanged: _handleTextChange,
              decoration: InputDecoration(hintText: 'Please enter a baby name'),
            ),
            ScopedModelDescendant<AppStateModel>(
              builder: (context, child, model) => RaisedButton(
                    child: Text('Save'),
                    onPressed: () {
                      if ("Connection status: none" != model.connectionStatus()) {
                        _saveName();
                      } else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(model.connectionStatus()),
                          duration: Duration(seconds: 2),
                        ));
                      }
                    },
                  ),
            ),
            Center(child: Text("Typed name: $_name"))
          ],
        ));
  }
}
