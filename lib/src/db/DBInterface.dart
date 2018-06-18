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
///
import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:file_utils/files.dart';


abstract class DBInterface {
  DBInterface()
      : _dbError = _DBError(),
        // ignore: implicit_this_reference_in_initializer, implicit_this_reference_in_initializer
        _dbInt = _DBInterface(name: name, version: version, onCreate: onCreate, onConfigure: onConfigure, onOpen: onOpen, onUpgrade: onUpgrade, onDowngrade: onDowngrade);

  final _DBError _dbError;
  final _DBInterface _dbInt;

  /// String value with the name of the database.
  get name;
  
  /// int value greater than zero.
  get version;

  /// abstract method needed to be subclassed.
  Future onCreate(Database db, int version);

  /// Configure before upgrading or downgrading or after deletedowngrade
  Future onConfigure(Database db){
    return Future.value();
  }

  /// After opening, upgrading or downgrading.
  Future onOpen(Database db){
    return Future.value();
  }

  /// Upgrade to a higher version.
  Future onUpgrade(Database db, int oldVersion, int newVersion){
    return Future.value();
  }

  /// Downgrade to a lower version.
  Future onDowngrade(Database db, int oldVersion, int newVersion){
    return Future.value();
  }
  
  init() {
    open();
  }

  dispose() {
    close();
  }

  Future<bool> open() async {
    var open = await _dbInt._open();
    if(!open){
      _dbError.set(_dbInt._ex);
      // Once recorded, don't keep as it may mislead future calls.
      _dbInt._ex = null;
    }
    return open;
  }

  close() {
    _dbInt._close();
  }

  get fields => _dbInt._fields;

  get values => _dbInt._fldValues;

  get db => _dbInt;

  get error => _dbError._e;

  bool get isDatabaseException => _dbError.isDatabaseException;

  get message => _dbError._message;

  get inError => _dbError.inError;

  get noError => _dbError.noError;


  Future<Map> saveRec(String table) async {
    Map rec;
    try {
      rec = await _dbInt.updateRec(table, _dbInt._fldValues[table]);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      rec = Map();
    }
    return rec;
  }

  Future<Map> updateRec(String table, Map fields) async {
    Map rec;
    try {
      rec = await _dbInt.updateRec(table, fields);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      rec = Map();
    }
    return rec;
  }

  Future<List<Map>> getRec(String table, int id, Map fields) async {
    List<Map> rec;
    try {
      rec = await _dbInt.getRec(table, id, fields);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      rec = List<Map>();
    }
    return rec;
  }

  Future<int> delete(String table, int id) async {
    int rows;
    try {
      rows = await _dbInt.delete(table, id);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      rows = 0;
    }
    return rows;
  }

  Future<List<Map>> rawQuery(String sqlStmt) async {
    List<Map> recs;
    try {
      recs = await _dbInt.rawQuery(sqlStmt);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      recs = List<Map>();
    }
    return recs;
  }

  Future<List<Map>> query(String table, Map fields, {String orderBy}) async {
    List<Map> recs;
    try {
      recs = await _dbInt.query(table, fields, orderBy: orderBy);
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      recs = List<Map>();
    }
    return recs;
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
}



class _DBError {
  String _message = '';

  Exception _e;

  get inError => _message.isNotEmpty;

  get noError => _message.isEmpty;

  void clear() => _message = '';

  String set(Exception e){
    _e = e;
    // parameter may be null.
    _message = e?.toString() ?? '';
    return _message;
  }

  bool get isDatabaseException => _e is DatabaseException;

  bool isNoSuchTableError([String table]) {
    if (_e is DatabaseException) {
      DatabaseException dbErr = _e;
      return dbErr.isNoSuchTableError();
    }
    return false;
  }

  bool isSyntaxError() {
    if (_e is DatabaseException) {
      DatabaseException dbErr = _e;
      return dbErr.isSyntaxError();
    }
    return false;
  }

  bool isOpenFailedError() {
    if (_e is DatabaseException) {
      DatabaseException dbErr = _e;
      return dbErr.isOpenFailedError();
    }
    return false;
  }

  bool isDatabaseClosedError() {
    if (_e is DatabaseException) {
      DatabaseException dbErr = _e;
      return dbErr.isDatabaseClosedError();
    }
    return false;
  }

  bool isReadOnlyError() {
    if (_e is DatabaseException) {
      DatabaseException dbErr = _e;
      return dbErr.isReadOnlyError();
    }
    return false;
  }

  bool isUniqueConstraintError([String field]) {
    if (_e is DatabaseException) {
      DatabaseException dbErr = _e;
      return dbErr.isUniqueConstraintError();
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

  String keyField = 'id';

  Exception _ex;

  Database _db;

  Future<bool> _open() async {
    bool opened;

    if (_db != null) {
      opened = _db is Database;
    }else{
      assert(version > 0, "Version number must be greater than one!");
      
      var path = await Files.localPath;

      String dbPath = join(path, name);

      try {

        _db = await openDatabase(dbPath,
          version: version,
          onCreate: onCreate,
          onConfigure: onConfigure,
          onUpgrade: onUpgrade,
          onDowngrade: onDowngrade,
          onOpen: onOpen,
        );

        _tableFields();

        opened = true;

      } catch (e) {
        _ex = e;
        opened = false;
      }
    }
    return opened;
}

  Future<void> _close() async {
    if (_db != null) {
      await _db.close();
      _db = null;
    }
  }

  int _rowsUpdated = 0;
  get rows => _rowsUpdated;

  Future<Map> updateRec(String table, Map fields) async {
    if (fields[keyField] == null) {
      fields[keyField] = await _db.insert(table, fields);
    } else {
      _rowsUpdated = await _db.update(table, fields,
          where: "$keyField = ?", whereArgs: [fields["id"]]);
    }
    return fields;
  }

  Future<List<Map>> getRec(String table, int id, Map fields) async {
    if (_db == null) {
      var open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await _db.query(table,
        columns: fields.keys.toList(), where: "$keyField = ?", whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    if (_db == null) {
      var open = await _open();
      if(!open) return Future.value(0);
    }
    return await _db.delete(table, where: "$keyField = ?", whereArgs: [id]);
  }

  Future<List<Map>> rawQuery(String sqlStmt) async {
    if (_db == null) {
      var open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await _db.rawQuery(sqlStmt);
  }

  Future<List<Map>> query(String table, Map fields, {String orderBy}) async {
    if (_db == null) {
      var open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await _db.query(table,
        columns: fields.keys.toList(), orderBy: orderBy);
  }

  Future<List<Map>> tableNames() async {
    if (_db == null) {
      var open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await _db
        .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  }

  Future<List<Map>> tableColumns(String table) async {
    if (_db == null) {
      var open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await _db.rawQuery("pragma table_info('$table')");
  }

  List<String> _tables = List();

  Future<List<String>> _tableList() async {
    List<Map> tables = await tableNames();

    for (var i = 1; i < tables.length; i++) {
      _tables.add(tables[i]['name']);
    }

    return _tables;
  }

  final Map<String, List> _fields = Map();
  get fields => _fields;

  final Map<String, Map> _fldValues = Map();
  get values => _fldValues;

  void _tableFields() async {
    var tables = await _tableList();

    for (var table in tables) {
      var columns = await tableColumns(table);

      List<String> fields = List();

      Map<String, dynamic> fieldValues = Map();

      for (var col in columns) {
        fields.add(col['name']);

        if (col['pk'] == 1) keyField = col['name'];

        fieldValues[col['name']] = null;
      }

      _fields[table] = fields;

      _fldValues[table] = fieldValues;
    }
  }
}