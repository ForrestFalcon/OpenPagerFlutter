import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesAppModel {
  static final PreferencesAppModel _singleton = new PreferencesAppModel._internal();

  BehaviorSubject<bool> isActive = new BehaviorSubject<bool>(seedValue: true);
  BehaviorSubject<bool> vibrate = new BehaviorSubject<bool>(seedValue: true);
  BehaviorSubject<bool> tts = new BehaviorSubject<bool>(seedValue: true);
  BehaviorSubject<double> ttsVolume = new BehaviorSubject<double>(seedValue: 1.0);

  PreferencesAppModel._internal() {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    _prefs.then((pref) {
      var isActive = pref.getBool("isActive");
      if (isActive != null) this.isActive.add(isActive);

      var vibrate = pref.getBool("vibrate");
      if (vibrate != null) this.vibrate.add(isActive);

      var tts = pref.getBool("tts");
      if (tts != null) this.tts.add(isActive);

      double ttsVolume = pref.getDouble("ttsVolume");
      if (ttsVolume != null) this.ttsVolume.add(ttsVolume);
    });

    isActive.distinct().listen((data) async {
      SharedPreferences prefs = await _prefs;
      prefs.setBool("isActive", data);
    });

    vibrate.distinct().listen((data) async {
      SharedPreferences prefs = await _prefs;
      prefs.setBool("vibrate", data);
    });

    tts.distinct().listen((data) async {
      SharedPreferences prefs = await _prefs;
      prefs.setBool("tts", data);
    });

    ttsVolume.distinct().listen((data) async {
      SharedPreferences prefs = await _prefs;
      prefs.setDouble("ttsVolume", data);
    });
  }

  factory PreferencesAppModel() {
    return _singleton;
  }
}
