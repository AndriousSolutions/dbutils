///
/// Copyright (C) 2018  Andrious Solutions
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
///          Created  14 May 2018
///
/// Github: https://github.com/AndriousSolutions/dbutils
///
import 'dart:async' show Future;

import 'dart:io' show Directory;

import 'package:sqflite/sqflite.dart'
    show
        Database,
        DatabaseException,
        OnDatabaseConfigureFn,
        OnDatabaseCreateFn,
        OnDatabaseOpenFn,
        OnDatabaseVersionChangeFn,
        openDatabase;

//import 'package:sqflite/src/database_mixin.dart' show SqfliteDatabaseMixin;

import 'package:path/path.dart' show join;

import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'package:flutter/foundation.dart' show mustCallSuper;

import 'package:dbutils/src/db/db_interface.dart' as db;

/// Signature of callbacks that have no arguments and return no data.
typedef Func = Future<bool> Function();

abstract class SQLiteDB implements db.DBInterface {
  SQLiteDB() : _dbError = _DBError() {
    _dbInt = _DBInterface(
        name: name,
        version: version,
        onCreate: onCreate,
        onConfigure: onConfigure,
        onOpen: onOpen,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade);
  }

  final _DBError _dbError;
  _DBInterface? _dbInt;

  /// String value with the name of the database.
  String get name;

  /// int value greater than zero.
  int get version;

  /// abstract method needed to be subclassed.
  Future<void> onCreate(Database db, int version);

  /// Configure before upgrading or downgrading or after deletedowngrade
  Future<void> onConfigure(Database db) {
    return Future.value();
  }

  /// After opening, upgrading or downgrading.
  Future<void> onOpen(Database db) {
    return Future.value();
  }

  /// Upgrade to a higher version.
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) {
    return Future.value();
  }

  /// Downgrade to a lower version.
  Future<void> onDowngrade(Database db, int oldVersion, int newVersion) {
    return Future.value();
  }

  @mustCallSuper
  Future<bool> init() {
    return open();
  }

  // Leave the word 'dispose' to subclasses. gp
  @mustCallSuper
  void disposed() {
    close();
  }

  Future<bool> open() async {
    var open = await _dbInt!.open();
    if (!open) {
      _dbError.set(_dbInt!.ex);
      // Once recorded, don't keep as it may mislead future calls.
      _dbInt!.ex = null;
    }
    return open;
  }

  close() {
    // Sometimes there's no open(). gp
    _dbInt?.close();
  }

  /// List of the tables and list their fields: Map<String, List>
  Map<String?, List> get fields => _dbInt!._fields;

  /// Get the key field for a table
  Future<String?> keyField(String table) async {
    if (db == null) await open();
    return _dbInt!._keyFields[table];
  }

  Map<String?, Map> get newrec => _dbInt!._newRec;

  /// Gets the Database
  Database? get db => _dbInt!.db;

  /// Gets the exception if any.
  Exception? get error => _dbError.e;

  set error(Exception? ex) => _dbError.set(ex);

  bool get isDatabaseException => _dbError.isDatabaseException;

  bool get isNoSuchTableError => _dbError.isNoSuchTableError();

  bool get isSyntaxError => _dbError.isSyntaxError();

  bool get isOpenFailedError => _dbError.isOpenFailedError();

  bool get isDatabaseClosedError => _dbError.isDatabaseClosedError();

  bool get isReadOnlyError => _dbError.isReadOnlyError();

  bool get isUniqueConstraintError => _dbError.isUniqueConstraintError();

  /// Get the error message
  String get message => _dbError.message;

  /// There was just now an error
  bool get inError => _dbError.inError;

  /// Has an error.
  bool get hasError => _dbError.inError;

  /// There was no error
  bool get noError => _dbError.noError;

  /// How many records were last updated.
  int? get recsUpdated => _dbInt!.rowsUpdated;

  Future<Map<String?, dynamic>> saveRec(
      String table, Map<String?, dynamic> fldValues) async {
    return updateRec(table, fldValues);
  }

  Future<Map<String?, dynamic>> saveMap(
      String? table, Map<String, dynamic> values) async {
    if (table == null || table.isEmpty) Future.value(Map<String, dynamic>());
    Map<String?, dynamic> rec = newRec(table!, values);
    rec = await saveRec(table, rec);
    return rec;
  }

  Future<void> runTxn(void Function() func, {bool? exclusive}) =>
      db!.transaction((txn) async => func(), exclusive: exclusive);

  Future<Map<String?, dynamic>> updateRec(
      String table, Map<String?, dynamic> fields) async {
    Map<String?, dynamic> rec;
    try {
      rec = await _dbInt!.updateRec(table, fields);
      _dbError.clear();
    } catch (e) {
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
      rec = Map();
    }
    return rec;
  }

  /// Return an 'empty' record map
  Map<String?, dynamic> newRec(String table, [Map<String, dynamic>? data]) {
    Map<String?, dynamic> newRec = Map();

    newRec.addAll(_dbInt!._newRec[table]!);

    if (data != null)
      data.forEach((key, value) {
        if (newRec.containsKey(key)) newRec[key] = value;
      });

    return newRec;
  }

  Future<List<Map<String, dynamic>>> getRecord(String table, int id) async {
    return getRow(table, id, _dbInt!._fields);
  }

  Future<List<Map<String, dynamic>>> getRow(
      String table, int id, Map fields) async {
    List<Map<String, dynamic>> rec;
    try {
      rec = await _dbInt!.getRec(table, id, fields[table]);
      _dbError.clear();
    } catch (e) {
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
      rec = [];
    }
    return rec;
  }

  Future<int> delete(String table, int id) async {
    int rows;
    try {
      rows = await _dbInt!.delete(table, id);
      _dbError.clear();
    } catch (e) {
      rows = 0;
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return rows;
  }

  Future<int> deleteRec(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    int rows;
    try {
      rows = await _dbInt!.deleteRec(table, where: where, whereArgs: whereArgs);
      _dbError.clear();
    } catch (e) {
      rows = 0;
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sqlStmt) async {
    List<Map<String, dynamic>> recs;
    try {
      recs = await _dbInt!.rawQuery(sqlStmt);
      // Convert the QueryResultSet to a Map
      recs = mapQuery(recs);
      _dbError.clear();
    } catch (e) {
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
      recs = [];
    }
    return recs;
  }

  Future<int> rawInsert(String sqlStmt, [List<dynamic>? arguments]) async {
    int recs;
    try {
      recs = await _dbInt!.rawInsert(sqlStmt, arguments);
      _dbError.clear();
    } catch (e) {
      recs = 0;
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return recs;
  }

  /// int count = await database.rawUpdate('UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',["updated name", "9876", "some name"]);
  Future<int> rawUpdate(String sqlStmt, [List<dynamic>? arguments]) async {
    int recs;
    try {
      recs = await _dbInt!.rawUpdate(sqlStmt, arguments);
      _dbError.clear();
    } catch (e) {
      recs = 0;
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return recs;
  }

  /// int cnt = await _this.rawDelete('DELETE FROM Yahoo WHERE id = ?',[id]);
  Future<int> rawDelete(String sqlStmt, [List<dynamic>? arguments]) async {
    int recs;
    try {
      recs = await _dbInt!.rawDelete(sqlStmt, arguments);
      _dbError.clear();
    } catch (e) {
      recs = 0;
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return recs;
  }

  Future<List<Map<String, dynamic>>> getTable(String table,
      {bool? distinct,
      String? where,
      List? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {
    return query(
      table,
      _dbInt!._fields[table],
      distinct: distinct,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> query(String table, List? columns,
      {bool? distinct,
      String? where,
      List? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    List<Map<String, dynamic>> recs;

    try {
      recs = await _dbInt!.query(
        table,
        columns: columns as List<String?>?,
        distinct: distinct,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      // Convert the QueryResultSet to a Map
      recs = mapQuery(recs);
      _dbError.clear();
    } catch (e) {
      recs = [];
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return recs;
  }

  List<Map<String, dynamic>> mapQuery(List<Map<String, dynamic>> query) {
    List<Map<String, dynamic>> mapList = [];
    for (var row in query) {
      Map<String, dynamic> map = row.map((key, value) => MapEntry(key, value));
      mapList.add(map);
    }
    return mapList;
  }

  Future<List<Map>> tableNames() async {
    List<Map> rec;
    try {
      rec = await _dbInt!.tableNames();
      _dbError.clear();
    } catch (e) {
      rec = [];
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return rec;
  }

  Future<List<Map>> tableColumns(String table) async {
    List<Map> rec;
    try {
      rec = await _dbInt!.tableColumns(table);
      _dbError.clear();
    } catch (e) {
      rec = [];
      Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return rec;
  }

  static Exception? _exception;

  static setError(Object? ex) {
    if (ex is! Exception) ex = Exception(ex.toString());
    _exception = ex;
  }

  static Exception? getError() {
    var ex = _exception;
    _exception = Exception();
    return ex;
  }
}

class _DBError {
  String message = '';

  Exception? e;

  bool get inError => message.isNotEmpty;

  bool get noError => message.isEmpty;

  void clear() {
    e = null;
    message = '';
  }

  String set(Exception? ex) {
    SQLiteDB.setError(ex);
    e = ex;
    // parameter may be null.
    message = ex?.toString() ?? '';
    return message;
  }

  bool get isDatabaseException => e != null && e is DatabaseException;

  bool isNoSuchTableError([String? table]) {
    if (e != null && e is DatabaseException) {
      return (e as DatabaseException).isNoSuchTableError();
    }
    return false;
  }

  bool isSyntaxError() {
    if (e != null && e is DatabaseException) {
      return (e as DatabaseException).isSyntaxError();
    }
    return false;
  }

  bool isOpenFailedError() {
    if (e != null && e is DatabaseException) {
      return (e as DatabaseException).isOpenFailedError();
    }
    return false;
  }

  bool isDatabaseClosedError() {
    if (e != null && e is DatabaseException) {
      return (e as DatabaseException).isDatabaseClosedError();
    }
    return false;
  }

  bool isReadOnlyError() {
    if (e != null && e is DatabaseException) {
      return (e as DatabaseException).isReadOnlyError();
    }
    return false;
  }

  bool isUniqueConstraintError([String? field]) {
    if (e != null && e is DatabaseException) {
      return (e as DatabaseException).isUniqueConstraintError();
    }
    return false;
  }
}

class _DBInterface {
  _DBInterface({
    this.name,
    this.version,
    this.onCreate,
    this.onOpen,
    this.onConfigure,
    this.onUpgrade,
    this.onDowngrade,
  });

  final String? name;
  final int? version;
  final OnDatabaseCreateFn? onCreate;
  final OnDatabaseOpenFn? onOpen;
  final OnDatabaseConfigureFn? onConfigure;
  final OnDatabaseVersionChangeFn? onUpgrade;
  final OnDatabaseVersionChangeFn? onDowngrade;

  Exception? ex;
  Database? db;

  Future<bool> open() async {
    bool opened;

    if (db != null) {
      opened = db is Database && (db!.path?.isNotEmpty ?? false);
    } else {
      assert(version! > 0, "Version number must be greater than one!");

      var path = await (localPath as Future<String>);

      String dbPath = join(path, name);

      try {
        db = await openDatabase(
          dbPath,
          version: version,
          onCreate: onCreate,
          onConfigure: onConfigure,
          onUpgrade: onUpgrade,
          onDowngrade: onDowngrade,
          onOpen: onOpen,
        );

        // Create the Map objects containing the table's fields.
        await tableFields();

        opened = true;
      } catch (e) {
        opened = false;
        ex = e is Exception ? e : Exception(e.toString());
      }
    }
    return opened;
  }

  void close() {
    var temp = db;

    /// Hot reload must have db close & set to null first.
    db = null;

    /// Don't provide the 'await' command as the process MUST wait.
    temp?.close();
  }

  int? rowsUpdated;

  Future<Map<String?, dynamic>> updateRec(
      String? table, Map<String?, dynamic> fields) async {
    rowsUpdated = 0;
    String? keyFld = _keyFields[table];
    var keyValue = fields[keyFld];
    if (table == null) {
      /// We got nothing.
    } else if (keyValue == null) {
      fields[keyFld] = await db!.insert(table, fields as Map<String, Object?>);
      rowsUpdated = 1;
    } else {
      rowsUpdated = await db!
          .update(table, fields as Map<String, Object?>, where: "$keyFld = ?", whereArgs: [keyValue]);
    }
    return fields;
  }

  Future<List<Map<String, dynamic>>> getRec(
      String table, int id, List? fields) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value([{}]);
    }
    return db!.query(table,
        columns: fields as List<String>?, where: "${_keyFields[table]} = ?", whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value(0);
    }
    return db!.delete(table, where: "${_keyFields[table]} = ?", whereArgs: [id]);
  }

  Future<int> deleteRec(String? table,
      {String? where, List<dynamic>? whereArgs}) async {
    if (table == null || table.isEmpty) return 0;
    if (where == null || where.isEmpty) return 0;
    if (whereArgs == null || whereArgs.length == 0) return 0;
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value(0);
    }
    return db!.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sqlStmt) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value([{}]);
    }
    return db!.rawQuery(sqlStmt);
  }

  Future<int> rawInsert(String sqlStmt, [List<dynamic>? arguments]) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return 0;
    }
    return db!.rawInsert(sqlStmt, arguments);
  }

  Future<int> rawUpdate(String sqlStmt, [List<dynamic>? arguments]) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return 0;
    }
    return db!.rawUpdate(sqlStmt, arguments);
  }

  Future<int> rawDelete(String sqlStmt, [List<dynamic>? arguments]) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return 0;
    }
    return db!.rawDelete(sqlStmt, arguments);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {bool? distinct = false,
      List<String?>? columns,
      String? where,
      List? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value([{}]);
      return await db!.query(
        table,
        distinct: distinct,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } else {
      final cols = columns == null ? _fields[table] : columns;
      return await db!.query(
        table,
        distinct: distinct,
        columns: cols as List<String>?,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    }
  }

  Future<List<Map<String, dynamic>>> tableNames() async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value([{}]);
    }
    return db!.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  }

  Future<List<Map<String, dynamic>>> tableColumns(String? table) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value([{}]);
    }
    return db!.rawQuery("pragma table_info('$table')");
  }

  Future<List<String?>> tableList() async {
    List<Map<String, dynamic>> tables = await tableNames();

    List<String?> list = [];

    // Include android metadata table as well with 0; iOS then works.
    for (var i = 0; i < tables.length; i++) {
      list.add(tables[i]['name']);
    }
    return list;
  }

  final Map<String?, List> _fields = Map();

  final Map<String?, String?> _keyFields = Map();

  final Map<String?, Map<String?, dynamic>> _newRec = Map();

  Future<void> tableFields() async {
    dynamic fldValue;
    String? keyField;
    String? type;

    var tables = await tableList();

    for (var table in tables) {
      var columns = await tableColumns(table);

      List<String?> fields = [];

      /// ROWID is automatically added to all SQLite tables by default, and is a unique integer,
      keyField = 'rowid';

      fields.add(keyField);

      Map<String?, dynamic> fieldValues = Map();

      fieldValues[keyField] = null;

      _keyFields[table] = keyField;

      for (var col in columns) {
        /// Replace the primary key field.
        if (col['pk'] == 1 && keyField != col['name']) {
          fieldValues.remove(keyField);
          keyField = col['name'];
          _keyFields[table] = keyField;
          fieldValues[keyField] = null;
          fields.first = keyField;
        } else {
          fields.add(col['name']);
          type = col['type'];
          if (col['dflt_value'] != null) {
            fldValue = col['dflt_value'];
            switch (type!.toLowerCase()) {
              case 'long':
                {
                  fldValue = double.parse(fldValue);
                }
                break;
              case 'integer':
                {
                  fldValue = int.parse(fldValue);
                }
            }
            fieldValues[col['name']] = fldValue;
          } else {
            if (col['notnull'] == 1) {
              switch (type!.toLowerCase()) {
                case 'long':
                  {
                    fldValue = 0.0;
                  }
                  break;
                case 'integer':
                  {
                    fldValue = 0;
                  }
                  break;
                default:
                  {
                    fldValue = '';
                  }
              }
              fieldValues[col['name']] = fldValue;
            } else {
              fieldValues[col['name']] = null;
            }
          }
        }
      }

      _fields[table] = fields;

      _newRec[table] = Map<String?, dynamic>();

      /// Make a copy as an 'empty' record.
      _newRec[table]!
          .addEntries(fieldValues.entries); //_fldValues[table].entries);
    }
  }

  Future<String?> get localPath async {
    if (_path == null) {
      try {
        Directory directory = await getApplicationDocumentsDirectory();
        _path = directory.path;
      } catch (e) {
        _path = '';
        ex = e is Exception ? e : Exception(e.toString());
      }
    }
    return _path;
  }

  String? _path;
}
