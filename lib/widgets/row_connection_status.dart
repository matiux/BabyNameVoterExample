import 'package:baby_name_voter/app_state.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RowConnectionStateWidget extends StatefulWidget {
//  final String state;

//  RowConnectionStateWidget({Key key, @required this.state}) : assert(state.isNotEmpty);

  @override
  State<StatefulWidget> createState() => _RowConnectionStateWidgetState();
}

class _RowConnectionStateWidgetState extends State<RowConnectionStateWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Colors.lightBlue),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: ScopedModelDescendant<AppStateModel>(
                builder: (context, child, model) => Text(
                      model.connectionStatus(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
