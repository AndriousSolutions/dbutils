// Copyright 2021 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

/// SQLite
import 'package:dbutils/sqlite_db.dart';

class Employee extends SQLiteDB {
  /// Really should only make one instance of a database object.
  factory Employee() => _this ??= Employee._();

  Employee._() : super();
  static Employee? _this;

  /// The name of the whole SQLite database
  @override
  String get name => 'testing.db';

  @override
  int get version => 1;

  /// For convenience, the name of the lone data table used in this example.
  final String table = 'Employee';

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
     CREATE TABLE $table(
              id INTEGER PRIMARY KEY
              ,firstname TEXT
              ,lastname TEXT
              )
     ''');
  }

  Future<List<Map<String, dynamic>>> openDatabase() async {
    List<Map<String, dynamic>> employees = [{}];
    final init = await open();
    if (init) {
      employees = await getEmployees();
    }
    return employees;
  }

  Future<List<Map<String, dynamic>>> getEmployees() async =>
      _employees = await getTable(table);

  List<Map<String, dynamic>> get employees => _employees;
  List<Map<String, dynamic>> _employees = [{}];

  Future<List<Map<String, dynamic>>> getRec(int id) =>
      super.getRecord(table, id);

  Future<bool> saveRecord(Map<String, dynamic> record) async {
    final rec = await saveRec(table, record);
    return rec.isNotEmpty;
  }

  Future<bool> deleteRecord(Map<String, dynamic> record) async {
    int cnt;
    final id = record['id'];
    cnt = await delete(table, id);
    return cnt > 0;
  }
}
