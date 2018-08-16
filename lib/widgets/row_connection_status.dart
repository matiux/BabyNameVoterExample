import 'package:flutter/material.dart';

class RowConnectionStateWidget extends StatefulWidget {
  final String state;

  RowConnectionStateWidget({Key key, @required this.state})
      : assert(state.isNotEmpty);

  @override
  State<StatefulWidget> createState() {
    return _RowConnectionStateWidgetState();
  }
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
              child: Text(
                widget.state,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
