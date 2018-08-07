import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_pager/firebase_manager.dart';
import 'package:flutter_open_pager/pages/operation_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  Intl.defaultLocale = 'de';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseManager().init();
    initializeDateFormatting();

    return new MaterialApp(
        title: "OpenPager",
        theme: new ThemeData(
          primaryColor: Colors.red,
        ),
        home: new OperationListWidget()
    );
  }
}

// theme: defaultTargetPlatform == TargetPlatform.iOS