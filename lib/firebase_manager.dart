import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_open_pager/models/operation_model.dart';
import 'package:flutter_open_pager/repositories/operation_app_model.dart';
import 'package:flutter_open_pager/repositories/preferences_app_model.dart';
import 'package:vibrate/vibrate.dart';

class FirebaseManager {
  FirebaseMessaging _firebaseMessaging;

  FirebaseMessaging get firebaseMessaging => _firebaseMessaging;

  static final FirebaseManager _singleton = new FirebaseManager._internal();

  factory FirebaseManager() {
    return FirebaseManager._singleton;
  }

  FirebaseManager._internal() {
    _firebaseMessaging = FirebaseMessaging();
  }

  init() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("ZEFIX! onMessage: $message");
        if (message.containsKey("type") && message["type"] == "operation") {
          this._handleOperation(message);
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        print("ZEFIX! onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) {
        print("ZEFIX! onResume: $message");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future _handleOperation(Map<String, dynamic> message) async {
    bool isActive = await PreferencesAppModel().isActive.first;
    if (!isActive) {
      return;
    }

    OperationModel model = new OperationModel();

    message.forEach((key, value) {
      switch (key) {
        case "key":
          model.key = value;
          break;
        case "title":
          model.title = value;
          break;
        case "message":
          model.message = value;
          break;
        case "destination":
          model.destination = value;
          break;
        case "destination_loc":
          try {
            var destParts = value.split(';');

            model.destinationLat = double.parse(destParts[0]);
            model.destinationLng = double.parse(destParts[1]);
          } catch (e) {}
          break;
        case "timestamp":
          try {
            model.time = int.parse(value);
          } catch (e) {
            model.time = (new DateTime.now().millisecondsSinceEpoch / 1000).round();
          }
          break;
      }
    });

    print("New operation: $model");
    OperationAppModel().addOperationCommand.execute(model);

    bool canVibrate = await Vibrate.canVibrate;
    if (canVibrate) {
      // Vibrate with pauses between each vibration
      final Iterable<Duration> pauses = [
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 500),
      ];

      // vibrate - sleep 0.5s - vibrate - sleep 0.5s - vibrate - sleep 0.5s - vibrate
      Vibrate.vibrateWithPauses(pauses);
    }
  }
}
