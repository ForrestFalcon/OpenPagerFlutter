import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_open_pager/german_duration_locale.dart';
import 'package:flutter_open_pager/models/operation_model.dart';
import 'package:flutter_open_pager/repositories/preferences_app_model.dart';
import 'package:latlong/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:duration/duration.dart';
import 'package:flutter_tts/flutter_tts.dart';

class OperationScreen extends StatelessWidget {
  final OperationModel model;
  final bool isAlarm;

  OperationScreen({@required this.model, this.isAlarm});

  _launchNavigation() async {
    String url;
    String coords = model.destinationLat.toString() + "," + model.destinationLng.toString();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      url = "http://maps.apple.com/?ll=$coords";
    } else {
      url = "http://maps.google.com/maps?daddr=$coords&amp;ll=";
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [Tab(icon: Icon(Icons.info))];
    final List<Widget> body = [OperationInfoWidget(model, isAlarm)];

    if (_hasCoords()) {
      tabs.add(Tab(icon: Icon(Icons.map)));
      body.add(_createMap());
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(this.model.title),
          actions: _createActions(),
          bottom: TabBar(
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          children: body,
        ),
      ),
    );
  }

  List<Widget> _createActions() {
    if (_hasCoords()) {
      return [
        IconButton(
          icon: Icon(Icons.directions_car),
          onPressed: _launchNavigation,
        )
      ];
    } else {
      return [];
    }
  }

  Widget _createMap() {
    return new FlutterMap(
      options: new MapOptions(
        center: new LatLng(model.destinationLat, model.destinationLng),
        zoom: 16.0,
      ),
      layers: [
        new TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
        new MarkerLayerOptions(
          markers: [
            new Marker(
              width: 80.0,
              height: 80.0,
              anchor: AnchorPos.bottom,
              point: new LatLng(model.destinationLat, model.destinationLng),
              builder: (ctx) => new Container(
                    child: Icon(Icons.location_on, size: 80.0),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  bool _hasCoords() {
    return this.model.destinationLng != null && this.model.destinationLat != null;
  }
}

class OperationInfoWidget extends StatefulWidget {
  final OperationModel model;
  final bool isAlarm;

  OperationInfoWidget(this.model, this.isAlarm);

  @override
  OperationInfoState createState() => new OperationInfoState(model, isAlarm);
}

class OperationInfoState extends State<OperationInfoWidget> {
  OperationModel model;
  bool isAlarm;

  Timer timer;
  FlutterTts flutterTts;

  String time = "XXX";
  Color timerColor = Colors.black;

  OperationInfoState(this.model, this.isAlarm);

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 1), timerCallback);
    timerCallback(timer);

    if (isAlarm) {
      timerColor = Colors.red;

      speak();
    }

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    flutterTts?.stop();
    super.dispose();
  }

  void timerCallback(Timer timer) {
    int unix = (new DateTime.now().millisecondsSinceEpoch / 1000).round();
    Duration duration = Duration(seconds: unix - model.time);

    setState(() {
      this.time = prettyDuration(duration, locale: GermanDurationLocale(), delimiter: ', ');
    });
  }

  Future speak() async {
    bool tts = await PreferencesAppModel().tts.first;
    double volume = await PreferencesAppModel().ttsVolume.first;

    if (tts) {
      flutterTts = new FlutterTts();
      flutterTts.setVolume(volume);
      flutterTts.speak(model.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      new Text(model.title, textAlign: TextAlign.center, style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5, fontWeightDelta: 2)),
      new Text(
        "Alarm vor $time",
        style: DefaultTextStyle.of(context).style.apply(color: timerColor),
      ),
      Container(
        margin: const EdgeInsets.only(top: 0.0, bottom: 80.0),
        child: new Text(
          model.message,
          textAlign: TextAlign.center,
        ),
      )
    ];

    if (isAlarm) {
      children.add(new RaisedButton(
        onPressed: () => setState(() {
              timerColor = Colors.black;
              flutterTts?.stop();
              isAlarm = false;
            }),
        child: Text('Alarm bestätigen'),
      ));
    }

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }
}
