
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_pager/models/operation_model.dart';
import 'package:flutter_open_pager/pages/operation_screen.dart';
import 'package:flutter_open_pager/pages/settings_screen.dart';
import 'package:flutter_open_pager/repositories/operation_app_model.dart';
import 'package:flutter_open_pager/rx_widgets.dart';
import 'package:intl/intl.dart';

class OperationListWidget extends StatefulWidget {

  OperationListWidget();
  OperationListWidget.forDesignTime();

  @override
  OperationListState createState() => new OperationListState();
}

class OperationListState extends State<OperationListWidget> {

  OperationListState() {
    OperationAppModel().addOperationCommand.results.listen((model) {
      _pushOperationScreen(model, true);
    });
  }

  void _pushSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void _pushOperationScreen(OperationModel model, bool isAlarm) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OperationScreen(model: model, isAlarm: isAlarm)),
    );
  }

  @override
  void initState() {
    super.initState();
    OperationAppModel().getOperationsCommand.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarme'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _pushSettingsScreen,
          )
        ],
      ),
      body: RxLoader<List<OperationModel>>(
        radius: 25.0,
        commandResults: OperationAppModel().getOperationsCommand,
        dataBuilder: (context, data) => _listView(context, data),
        placeHolderBuilder: (context) => Center(child: Text("Keine Alarme vorhanden")),
        errorBuilder: (context, ex) => Center(child: Text("Error: ${ex.toString()}")),
      ),
    );
  }

  Widget _listView(BuildContext context, List<OperationModel> data) {
    return ListView.builder(itemCount: data.length, itemBuilder: (BuildContext context, int index) => _createDismissible(context, index, data[index]));
  }

  Widget _createDismissible(BuildContext context, int index, OperationModel item) {
    String time = "";
    if (item.time != null) {
      DateFormat dateFormat = new DateFormat.Hm().add_yMMM();
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(item.time * 1000, isUtc: true);
      time = dateFormat.format(dateTime);
    }

    return Dismissible(
        // Show a red background as the item is swiped away
        background: Container(
          color: Colors.red,
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20.0),
          alignment: Alignment.centerRight,
        ),
        direction: DismissDirection.endToStart,
        key: Key(item.title),
        onDismissed: (direction) {
          OperationAppModel().removeOperation(item.id);
        },
        child: GestureDetector(
          onTap: () =>  _pushOperationScreen(item, false),
          child: Column(
            children: <Widget>[
              new Divider(
                height: 10.0,
              ),
              new ListTile(
                title: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(
                      item.title,
                      style: new TextStyle(fontWeight: FontWeight.bold),
                    ),
                    new Text(
                      time,
                      style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                  ],
                ),
                subtitle: new Container(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: new Text(
                    item.message,
                    style: new TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                ),
              )
            ],
          ),
        ));
  }

}
