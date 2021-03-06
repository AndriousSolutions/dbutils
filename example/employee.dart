///
/// Copyright (C) 2018 Andrious Solutions
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  24 Nov 2018
///
import 'dart:async' show Future;

import 'package:sqflite/sqflite.dart' show Database;

import 'package:dbutils/sqlite_db.dart' show SQLiteDB;

class Employee extends SQLiteDB {
  factory Employee() {
    if (_this == null) _this = Employee._getInstance();
    return _this!;
  }

  /// Make only one instance of this class.
  static Employee? _this;

  Employee._getInstance() : super();

  @override
  get name => 'testing.db';

  @override
  get version => 1;

  @override
  Future onCreate(Database db, int version) async {
    await db.execute("""
     CREATE TABLE Employee(
              id INTEGER PRIMARY KEY
              ,firstname TEXT
              ,lastname TEXT
              ,mobileno TEXT
              ,emailId TEXT
              )
     """);
  }

  Map<String?, dynamic>? values;

  @override
  Future<bool> init() async {
    bool init = await super.init();
    if (init) getEmployees();
    return init;
  }

  Future<bool> save([Map<String?, dynamic>? employee]) async {
    Map<String?, dynamic> rec = await saveRec('Employee', employee ?? values!);
    return rec.isNotEmpty;
  }

  void deleteEmp([Map<String?, dynamic>? employee]) =>
      delete('Employee', employee?['id'] ?? values!['id']);

  Future<List<Map<String, dynamic>>> getEmployees() async {
    List<Map<String, dynamic>> rec =
        await this.rawQuery('SELECT * FROM Employee');
    if (rec.length == 0) {
      values = newrec['Employee'] as Map<String?, dynamic>?;
    } else {
      values = rec[rec.length - 1];
    }
    return rec;
  }

  Map<String?, dynamic> emptyRec() => newRec('Employee');
}
