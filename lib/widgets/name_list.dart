import 'package:baby_name_voter/app_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NameListWidgetStatus();
  }
}

class _NameListWidgetStatus extends State<NameListWidget> {
  _deleteName(DocumentReference dr, BuildContext context, AppStateModel appStateModel) {
    if ("ConnectivityResult.none" == appStateModel.connectionStatus()) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text("No internet connection"),
          duration: Duration(milliseconds: 1000),
        ));

      return;
    }

    Firestore.instance.runTransaction((transaction) async {
      await transaction.delete(dr);
    });
  }

  _buildListItem(BuildContext context, DocumentSnapshot ds) {
    return ScopedModelDescendant<AppStateModel>(
      rebuildOnChange: false,
      builder: (context, _, model) => Dismissible(
            key: ValueKey(ds.documentID),
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              _deleteName(ds.reference, context, model);

              String name = ds['name'];
              Scaffold.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text("$name deleted")));
            },
            child: BabyNameListTileWidget(ds: ds, model: model),
          ),
    );
  }

  @override
  Widget build(BuildContext context) => Expanded(
        child: StreamBuilder(
            stream: Firestore.instance.collection('babies').orderBy("votes", descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text('Loading...');
              }

              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: EdgeInsets.only(top: 10.0),
                itemExtent: 55.0,
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]),
              );
            }),
      );
}

class BabyNameListTileWidget extends StatefulWidget {
  final DocumentSnapshot ds;
  final AppStateModel model;

  BabyNameListTileWidget({Key key, @required this.ds, @required this.model}) : super(key: key);

  @override
  State<BabyNameListTileWidget> createState() => _BabyNameListTileState(ds['votes'].toString());
}

class _BabyNameListTileState extends State<BabyNameListTileWidget> {
  String _vote = '';

  _BabyNameListTileState(String currentVote) {
    _vote = currentVote;
  }

  _voteName(DocumentSnapshot ds, BuildContext context, AppStateModel appStateModel) async {
    String keyName = ds['name'].toLowerCase().trim();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool voted = prefs.getBool("voted.$keyName") ?? false;

    if (voted) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text("Hai già votato " + ds['name']),
          duration: Duration(milliseconds: 1000),
        ));

      return;
    }

    if ("ConnectivityResult.none" == appStateModel.connectionStatus()) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text("No internet connection"),
          duration: Duration(milliseconds: 1000),
        ));

      return;
    }

    setState(() {
      _vote = (int.parse(_vote) + 1).toString();
    });

    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(ds.reference);
      await transaction.update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});

      prefs.setBool("voted.$keyName", true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), borderRadius: BorderRadius.circular(5.0)),
          padding: EdgeInsets.all(10.0),
          child: new Row(
            children: <Widget>[Expanded(child: Text(widget.ds['name'])), Text(_vote)],
          )),
      onTap: () => _voteName(widget.ds, context, widget.model),
    );
  }
}
