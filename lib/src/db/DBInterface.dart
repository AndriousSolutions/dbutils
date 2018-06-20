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
      _dbError.set(_dbInt.ex);
      // Once recorded, don't keep as it may mislead future calls.
      _dbInt.ex = null;
    }
    return open;
  }

  close() {
    _dbInt._close();
  }

  /// List of the tables and list their fields: Map<String, List>
  Map<String, List> get fields => _dbInt._fields;

  /// List of the table and a map of each of their field values: Map<String, Map>
  Map<String, Map> get values => _dbInt._fldValues;

  /// Gets the Database
  Database get db => _dbInt.db;

  /// Gets the exception if any.
  Exception get error => _dbError.e;

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


  Future<Map> saveRec(String table) async {

    return updateRec(table, _dbInt._fldValues[table]);
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

  Future<List<Map<String, dynamic>>> getRecord(String table, int id) async {
    return getRow(table, id, _dbInt._fields);
  }

  Future<List<Map<String, dynamic>>> getRow(String table, int id, Map fields) async {
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
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      recs = List<Map<String, dynamic>>();
    }
    return recs;
  }


  Future<List<Map<String, dynamic>>> getTable(
       String table,
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


  Future<List<Map<String, dynamic>>> query(
      String table,
      List columns,
      {bool distinct,
      String where,
      List whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {
    final cols = columns ?? _dbInt._fields[table];
    List<Map<String, dynamic>> recs;
    try {
      recs = await _dbInt.query(
          table,
          columns: cols,
          distinct: distinct,
          where: where,
          whereArgs: whereArgs,
          groupBy: groupBy,
          having: having,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
      );
      _dbError.clear();
    } catch (e) {
      _dbError.set(e);
      recs = List<Map<String, dynamic>>();
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
  String message = '';

  Exception e;

  bool get inError => message.isNotEmpty;

  bool get noError => message.isEmpty;

  void clear(){
    e = null;
    message = '';
  }

  String set(Exception ex){
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

  // ROWID is automatically added to all SQLite tables by default, and is a unique integer,
  String keyField = 'rowid';

  Exception ex;

  Database db;

  Future<bool> _open() async {
    bool opened;

    if (db != null) {
      opened = db is Database && (db.path?.isNotEmpty ?? false);
    }else{
      assert(version > 0, "Version number must be greater than one!");
      
      var path = await Files.localPath;

      String dbPath = join(path, name);

      try {

        db = await openDatabase(dbPath,
          version: version,
          onCreate: onCreate,
          onConfigure: onConfigure,
          onUpgrade: onUpgrade,
          onDowngrade: onDowngrade,
          onOpen: onOpen,
        );

        // Create the Map objects containing the table's fields.
        _tableFields();

        opened = true;

      } catch (e) {
        ex = e;
        opened = false;
      }
    }
    return opened;
}

  Future<void> _close() async {
    if (db != null) {
      await db.close();
      db = null;
    }
  }

  int rowsUpdated;

  Future<Map> updateRec(String table, Map fields) async {
    rowsUpdated = 0;
    if (fields[keyField] == null) {
      fields[keyField] = await db.insert(table, fields);
      rowsUpdated = 1;
    } else {
      rowsUpdated = await db.update(table, fields,
          where: "$keyField = ?", whereArgs: [fields["id"]]);
    }
    return fields;
  }

  Future<List<Map>> getRec(String table, int id, List fields) async {
    if (db == null) {
      final open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await db.query(table,
        columns: fields, where: "$keyField = ?", whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    if (db == null) {
      final open = await _open();
      if(!open) return Future.value(0);
    }
    return await db.delete(table, where: "$keyField = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sqlStmt) async {
    if (db == null) {
      final open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await db.rawQuery(sqlStmt);
  }

  Future<List<Map>> query(
      String table,
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
      final open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
    );
  }

  Future<List<Map>> tableNames() async {
    if (db == null) {
      final open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await db
        .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  }

  Future<List<Map>> tableColumns(String table) async {
    if (db == null) {
      final open = await _open();
      if(!open) return Future.value([{}]);
    }
    return await db.rawQuery("pragma table_info('$table')");
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

  final Map<String, Map> _fldValues = Map();

  void _tableFields() async {
    
    var tables = await _tableList();

    for (var table in tables) {
      
      var columns = await tableColumns(table);

      List<String> fields = List();

      Map<String, dynamic> fieldValues = Map();

      for (var col in columns) {

        fields.add(col['name']);
        /// Record the name of the primary key field.
        if (col['pk'] == 1) keyField = col['name'];

        fieldValues[col['name']] = null;
      }

      _fields[table] = fields;

      _fldValues[table] = fieldValues;
    }
  }
}