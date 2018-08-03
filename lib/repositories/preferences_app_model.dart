import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesAppModel {
  static final PreferencesAppModel _singleton = new PreferencesAppModel._internal();

  BehaviorSubject<bool> isActive = new BehaviorSubject<bool>(seedValue: true);
  BehaviorSubject<int> alarmTimeout = new BehaviorSubject<int>(seedValue: 30);

  PreferencesAppModel._internal() {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    _prefs.then((pref) {
      var isActive = pref.getBool("isActive");
      if (isActive != null) this.isActive.add(isActive);

      int alarmTimeout = pref.getInt("alarmTimeout");
      if (alarmTimeout != null) this.alarmTimeout.add(alarmTimeout);
    });

    isActive.distinct().listen((data) async {
      SharedPreferences prefs = await _prefs;
      prefs.setBool("isActive", data);
    });

    alarmTimeout.distinct().listen((data) async {
      SharedPreferences prefs = await _prefs;
      prefs.setInt("alarmTimeout", data);
    });
  }

  factory PreferencesAppModel() {
    return _singleton;
  }
}
