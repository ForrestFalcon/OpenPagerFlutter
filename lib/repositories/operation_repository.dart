import 'dart:async';

import 'package:flutter_open_pager/models/operation_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class OperationRepository {

  Future<Database> _database;

  static final OperationRepository _singleton = new OperationRepository._internal();

  factory OperationRepository() {
    return OperationRepository._singleton;
  }


  OperationRepository._internal() {
    // Get a location using getDatabasesPath
    var databasesPath = getDatabasesPath();
    _database =
        databasesPath.then((path) => join(path, "database.db")).then((path) => openDatabase(path, version: 1, onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute("CREATE TABLE Operations ("
              "id INTEGER PRIMARY KEY, "
              "title TEXT, "
              "message TEXT, "
              "key TEXT, "
              "destination TEXT, "
              "destinationLat REAL, "
              "destinationLng REAL, "
              "time INTEGER)");
        }));

  }

  Future<List<OperationModel>> getOperations() async {
    List<Map> maps = await (await _database).query("Operations",
        orderBy: "time DESC");

    List<OperationModel> list = [];
    maps.forEach((map) => list.add(OperationModel.fromMap(map)));

    if(list.length == 0) {
      return null;
    }

    return list;
  }

  Future<OperationModel> getOperation(int id) async {
    List<Map> maps = await (await _database).query("Operations",
        where: "id = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return new OperationModel.fromMap(maps.first);
    }
    return null;
  }


  Future<int> removeOperation(int id) async {
    return await (await _database).delete("Operations", where: "id = ?", whereArgs: [id]);
  }

  Future<OperationModel> insert(OperationModel operation) async {
    operation.id = await (await _database).insert("Operations", operation.toMap());
    return operation;
  }

  Future close() async => (await _database).close();
}