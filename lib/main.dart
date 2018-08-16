import 'package:baby_name_voter/add_name.dart';
import 'package:baby_name_voter/app_state.dart';
import 'package:baby_name_voter/widgets/name_list.dart';
import 'package:baby_name_voter/widgets/row_connection_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    NameListPage.routeName: (BuildContext context) => NameListPage(),
    AddNamePage.routeName: (context) => AddNamePage(),
  };

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppStateModel>(
      model: AppStateModel(),
      child: new MaterialApp(
        title: 'Baby names',
        debugShowCheckedModeBanner: false,
        home: const NameListPage(title: 'Baby name votes'),
        routes: routes,
      ),
    );
  }
}

class NameListPage extends StatefulWidget {
  static final String routeName = "Home-Page";
  final String title;

  const NameListPage({Key key, this.title}) : super(key: key);

  @override
  State<NameListPage> createState() => _NameListPageState();
}

class _NameListPageState extends State<NameListPage> {
  _navigateAndDisplayInfo(BuildContext context) async {
    //final result = await Navigator.of(context).push(
    // MaterialPageRoute(builder: (context) => AddNamePage.r),
    //);

    final result = await Navigator.pushNamed(context, AddNamePage.routeName);

    if ("null" != result.toString()) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("$result"),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Builder(
        builder: (BuildContext context) => FloatingActionButton(
            child: Text('+', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            onPressed: () {
              _navigateAndDisplayInfo(context);
            }),
      ),
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        child: ScopedModelDescendant<AppStateModel>(
          builder: (context, _, model) => Column(
                children: <Widget>[
                  RowConnectionStateWidget(state: model.connectionStatus()),
                  NameListWidget(),
                ],
              ),
        ),
      ),
    );
  }
}
