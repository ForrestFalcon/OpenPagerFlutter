import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_pager/firebase_manager.dart';
import 'package:flutter_open_pager/repositories/preferences_app_model.dart';
import 'package:share/share.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsState createState() => new SettingsState();
}

class SettingsState extends State<SettingsScreen> {
  bool _active = false;
  String _alarmTimeout = "";

  StreamSubscription isActiveSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: _androidSettings());
  }

  @override
  void initState() {
    isActiveSubscription = PreferencesAppModel().isActive.listen((value) {
      setState(() {
        _active = value;
      });
    });

//    PreferencesAppModel().alarmTimeout.listen((value) {
//      setState(() {
//        _alarmTimeout = value.toString() + " Sekunden";
//      });
//    });

    super.initState();
  }


  @override
  void dispose() {
    isActiveSubscription?.cancel();
    super.dispose();
  }

  Widget _androidSettings() {
    return ListView(
      padding: EdgeInsets.only(top: 15.0),
      children: <Widget>[
        SwitchListTile(
          value: _active,
          onChanged: (value) => PreferencesAppModel().isActive.add(value),
          title: Text("Dienst aktivieren"),
          subtitle: Text("Warnung: Wenn deaktiviert werden keine Nachrichten empfangen!"),
        ),
        Divider(),
        ListTile(
          title: Text('Alarm Timeout'),
          subtitle: Text(_alarmTimeout),
          onTap: () => _createAlarmTimeout(context),
        ),
        Divider(),
        ListTile(
          title: Text('Alarmkarten'),
        ),
        Divider(),
        ListTile(
          title: Text('FCM Push Token'),
          onTap: () async {
            var token = await FirebaseManager().firebaseMessaging.getToken();
            Share.share(token);
          },
          subtitle: FutureBuilder(
              future: FirebaseManager().firebaseMessaging.getToken(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return new Text('Laden...');
                  default:
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else
                      return Text(snapshot.data);
                }
              }),
        ),
      ],
    );
  }

  void _createAlarmTimeout(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
              child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: Text("10 Sekunden"),
                onTap: () {
                  PreferencesAppModel().alarmTimeout.add(10);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("30 Sekunden"),
                onTap: () {
                  PreferencesAppModel().alarmTimeout.add(30);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("60 Sekunden"),
                onTap: () {
                  PreferencesAppModel().alarmTimeout.add(60);
                  Navigator.pop(context);
                },
              ),
            ],
          ));
        });
  }
}
