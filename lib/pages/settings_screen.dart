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
  bool _vibrate = false;
  bool _tts = false;
  String _ttsVolume = "";

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
    isActiveSubscription = PreferencesAppModel().vibrate.listen((value) {
      setState(() {
        _vibrate = value;
      });
    });
    isActiveSubscription = PreferencesAppModel().tts.listen((value) {
      setState(() {
        _tts = value;
      });
    });

    PreferencesAppModel().ttsVolume.listen((value) {
      setState(() {
        _ttsVolume = (value * 100).round().toString() + " %";
      });
    });

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
          title: Text("Alarm empfangen"),
          subtitle: Text("Warnung: Wenn deaktiviert werden keine Alarme mehr empfangen!"),
        ),
        Divider(),
        SwitchListTile(
          value: _vibrate,
          title: Text('Vibration'),
          subtitle: Text('Vibrieren bei Alarmempfang.'),
          onChanged: (value) => PreferencesAppModel().vibrate.add(value),
        ),
        Divider(),
        SwitchListTile(
          value: _tts,
          title: Text('Alarmtitel vorlesen'),
          onChanged: (value) => PreferencesAppModel().tts.add(value),
        ),
        Divider(),
        ListTile(
          title: Text('Vorlesen Lautstärke'),
          subtitle: Text(_ttsVolume),
          onTap: () => _createAlarmTimeout(context),
        ),
        Divider(),
        ListTile(
          title: Text('FCM-Key'),
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
                title: Text("25 %"),
                onTap: () {
                  PreferencesAppModel().ttsVolume.add(0.25);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("50 %"),
                onTap: () {
                  PreferencesAppModel().ttsVolume.add(0.5);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("75 %"),
                onTap: () {
                  PreferencesAppModel().ttsVolume.add(0.75);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("100 %"),
                onTap: () {
                  PreferencesAppModel().ttsVolume.add(1.0);
                  Navigator.pop(context);
                },
              ),
            ],
          ));
        });
  }
}
