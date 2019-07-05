///
/// Copyright (C) 2018  Andrious Solutions
///
/// This program is free software; you can redistribute it and/or
/// modify it under the terms of the GNU General Public License
/// as published by the Free Software Foundation; either version 3
/// of the License, or any later version.
///
/// You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
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

import 'package:path/path.dart' show join;

import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'package:flutter/foundation.dart' show mustCallSuper;

/// Signature of callbacks that have no arguments and return no data.
typedef Func = Function();

abstract class DBInterface {
  DBInterface() : _dbError = _DBError() {
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
  _DBInterface _dbInt;

  /// String value with the name of the database.
  String get name;

  /// int value greater than zero.
  int get version;

  /// abstract method needed to be subclassed.
  Future onCreate(Database db, int version);

  /// Configure before upgrading or downgrading or after deletedowngrade
  Future onConfigure(Database db) {
    return Future.value();
  }

  /// After opening, upgrading or downgrading.
  Future onOpen(Database db) {
    return Future.value();
  }

  /// Upgrade to a higher version.
  Future onUpgrade(Database db, int oldVersion, int newVersion) {
    return Future.value();
  }

  /// Downgrade to a lower version.
  Future onDowngrade(Database db, int oldVersion, int newVersion) {
    return Future.value();
  }

  @mustCallSuper
  Future<bool> init() {
    return open();
  }

  // Leave 'dispose' to subclasses. gp
  @mustCallSuper
  void disposed() {
    close();
  }

  Future<bool> open() async {
    var open = await _dbInt.open();
    if (!open) {
      _dbError.set(_dbInt.ex);
      // Once recorded, don't keep as it may mislead future calls.
      _dbInt.ex = null;
    }
    return open;
  }

  close() {
    _dbInt.close();
  }

  /// List of the tables and list their fields: Map<String, List>
  Map<String, List> get fields => _dbInt._fields;

  /// Get the key field for a table
  Future<String> keyField(String table) async {
    if (db == null) await open();
    return _dbInt._keyFields[table];
  }

  Map<String, Map> get newrec => _dbInt._newRec;

  /// Gets the Database
  Database get db => _dbInt.db;

  /// Gets the exception if any.
  Exception get error => _dbError.e;

  set error(Exception ex) => _dbError.set(ex);

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

  /// There was no error
  bool get noError => _dbError.noError;

  /// How many records were last updated.
  int get recsUpdated => _dbInt.rowsUpdated;

  Future<Map<String, dynamic>> saveRec(
      String table, Map<String, dynamic> fldValues) async {
    return updateRec(table, fldValues);
  }

  Future<Map<String, dynamic>> saveMap(
      String table, Map<String, dynamic> values) async {
    if (table == null || table.isEmpty) Future.value(Map<String, dynamic>());
    Map<String, dynamic> rec = newRec(table, values);
    rec = await saveRec(table, rec);
    return rec;
  }

  Future<bool> runTxn(Func func) async {
    var dbClient = db;
    var ret = await dbClient.transaction((txn) async {
      final bool result = await func();
      return Future.value(result);
    });
    return ret;
  }

  Future<Map<String, dynamic>> updateRec(
      String table, Map<String, dynamic> fields) async {
    Map<String, dynamic> rec;
    try {
      rec = await _dbInt.updateRec(table, fields);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      rec = Map<String, dynamic>();
    }
    return rec;
  }

  /// Return an 'empty' record map
  Map<String, dynamic> newRec(String table, [Map<String, dynamic> data]) {
    Map<String, dynamic> newRec = Map();

    newRec.addAll(_dbInt._newRec[table]);

    if (data != null)
      data.forEach((key, value) {
        if (newRec.containsKey(key)) newRec[key] = value;
      });

    return newRec;
  }

  Future<List<Map<String, dynamic>>> getRecord(String table, int id) async {
    return getRow(table, id, _dbInt._fields);
  }

  Future<List<Map<String, dynamic>>> getRow(
      String table, int id, Map fields) async {
    List<Map<String, dynamic>> rec;
    try {
      rec = await _dbInt.getRec(table, id, fields[table]);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      rec = List<Map<String, dynamic>>();
    }
    return rec;
  }

  Future<int> delete(String table, int id) async {
    int rows;
    try {
      rows = await _dbInt.delete(table, id);
      _dbError.clear();
    } catch (e) {
      rows = 0;
      _dbError.set(e);
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sqlStmt) async {
    List<Map<String, dynamic>> recs;
    try {
      recs = await _dbInt.rawQuery(sqlStmt);
      // Convert the QueryResultSet to a Map
      recs = mapQuery(recs);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      recs = List<Map<String, dynamic>>();
    }
    return recs;
  }

  Future<List<Map<String, dynamic>>> getTable(String table,
      {bool distinct,
      String where,
      List whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) {
    return query(
      table,
      _dbInt._fields[table],
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

  Future<List<Map<String, dynamic>>> query(String table, List columns,
      {bool distinct,
      String where,
      List whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {
    List<Map<String, dynamic>> recs;

    try {
      recs = await _dbInt.query(
        table,
        columns: columns,
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
      _dbError.set(e);
      recs = List<Map<String, dynamic>>();
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
      rec = await _dbInt.tableNames();
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      rec = List<Map>();
    }
    return rec;
  }

  Future<List<Map>> tableColumns(String table) async {
    List<Map> rec;
    try {
      rec = await _dbInt.tableColumns(table);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      rec = List<Map>();
    }
    return rec;
  }

  static Exception _exception;

  static setError(Object ex) {
    if (ex is! Exception) ex = Exception(ex.toString());
    _exception = ex;
  }

  static Exception getError() {
    var ex = _exception;
    _exception = Exception();
    return ex;
  }
}

class _DBError {
  String message = '';

  Exception e;

  bool get inError => message.isNotEmpty;

  bool get noError => message.isEmpty;

  void clear() {
    e = null;
    message = '';
  }

  String set(Exception ex) {
    DBInterface.setError(ex);
    e = ex;
    // parameter may be null.
    message = ex?.toString() ?? '';
    return message;
  }

  bool get isDatabaseException => e != null && e is DatabaseException;

  bool isNoSuchTableError([String table]) {
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

  bool isUniqueConstraintError([String field]) {
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

  final String name;
  final int version;
  final OnDatabaseCreateFn onCreate;
  final OnDatabaseOpenFn onOpen;
  final OnDatabaseConfigureFn onConfigure;
  final OnDatabaseVersionChangeFn onUpgrade;
  final OnDatabaseVersionChangeFn onDowngrade;

  Exception ex;
  Database db;

  Future<bool> open() async {
    bool opened;

    if (db != null) {
      opened = db is Database && (db.path?.isNotEmpty ?? false);
    } else {
      assert(version > 0, "Version number must be greater than one!");

      var path = await localPath;

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
        ex = e;
        opened = false;
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

  int rowsUpdated;

  Future<Map<String, dynamic>> updateRec(
      String table, Map<String, dynamic> fields) async {
    rowsUpdated = 0;
    String keyFld = _keyFields[table];
    var keyValue = fields[keyFld];
    if (table == null) {
      /// We got nothing.
    } else if (keyValue == null) {
      fields[keyFld] = await db.insert(table, fields);
      rowsUpdated = 1;
    } else {
      rowsUpdated = await db
          .update(table, fields, where: "$keyFld = ?", whereArgs: [keyValue]);
    }
    return fields;
  }

  Future<List<Map<String, dynamic>>> getRec(
      String table, int id, List fields) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value([{}]);
    }
    return await db.query(table,
        columns: fields, where: "${_keyFields[table]} = ?", whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value(0);
    }
    return await db
        .delete(table, where: "${_keyFields[table]} = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sqlStmt) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value([{}]);
    }
    return await db.rawQuery(sqlStmt);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {bool distinct = false,
      List<String> columns,
      String where,
      List whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value([{}]);
      return await db.query(
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
      return await db.query(
        table,
        distinct: distinct,
        columns: cols,
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
    return await db
        .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  }

  Future<List<Map<String, dynamic>>> tableColumns(String table) async {
    if (db == null) {
      final open = await this.open();
      if (!open) return Future.value([{}]);
    }
    return await db.rawQuery("pragma table_info('$table')");
  }

  Future<List<String>> tableList() async {
    List<Map<String, dynamic>> tables = await tableNames();

    List<String> list = List();

    for (var i = 1; i < tables.length; i++) {
      list.add(tables[i]['name']);
    }
    return list;
  }

  final Map<String, List> _fields = Map();

  final Map<String, String> _keyFields = Map();

  final Map<String, Map<String, dynamic>> _newRec = Map();

  Future<void> tableFields() async {
    dynamic fldValue;
    String keyField;

    var tables = await tableList();

    for (var table in tables) {
      var columns = await tableColumns(table);

      List<String> fields = List();

      /// ROWID is automatically added to all SQLite tables by default, and is a unique integer,
      keyField = 'rowid';

      fields.add(keyField);

      Map<String, dynamic> fieldValues = Map();

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

          if (col['dflt_value'] != null) {
            fieldValues[col['name']] = col['dflt_value'];
          } else {
            if (col['notnull'] == 1) {
              switch (col['type']) {
                case 'Long':
                  {
                    fldValue = 0.0;
                  }
                  break;
                case 'INTEGER':
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

//      _fldValues[table] = fieldValues;

      _newRec[table] = Map<String, dynamic>();

      /// Make a copy as an 'empty' record.
      _newRec[table]
          .addEntries(fieldValues.entries); //_fldValues[table].entries);
    }
  }

  Future<String> get localPath async {
    if (_path == null) {
      try {
        Directory directory = await getApplicationDocumentsDirectory();
        _path = directory.path;
      } catch (e) {
        ex = e;
        _path = '';
      }
    }
    return _path;
  }

  String _path;
}
