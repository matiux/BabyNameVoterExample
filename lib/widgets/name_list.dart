import 'package:baby_name_voter/app_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class NameListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NameListWidgetStatus();
  }
}

class _NameListWidgetStatus extends State<NameListWidget> {
  _deleteName(DocumentReference dr, BuildContext context, AppStateModel appStateModel) {
    if ("ConnectivityResult.none" == appStateModel.connectionStatus()) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("No internet connection"),
        duration: Duration(milliseconds: 1000),
      ));

      return;
    }

    Firestore.instance.runTransaction((transaction) async {
      await transaction.delete(dr);
    });
  }

  _voteName(DocumentReference dr, BuildContext context, AppStateModel appStateModel) {
    if ("ConnectivityResult.none" == appStateModel.connectionStatus()) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("No internet connection"),
        duration: Duration(milliseconds: 1000),
      ));

      return;
    }

    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(dr);
      await transaction.update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});
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
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("$name deleted")));
            },
            child: ListTile(
              title: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), borderRadius: BorderRadius.circular(5.0)),
                  padding: EdgeInsets.all(10.0),
                  child: new Row(
                    children: <Widget>[Expanded(child: Text(ds['name'])), Text(ds['votes'].toString())],
                  )),
              onTap: () => _voteName(ds.reference, context, model),
              //onLongPress: () => _deleteName(ds.reference, context, model),
            ),
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
