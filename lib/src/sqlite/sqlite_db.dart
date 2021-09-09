// Copyright 2021 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

/// SQLite helper class
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
  @override
  String get name;

  /// int value greater than zero.
  @override
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

  /// Called in the initState() function or the FutureBuilder(future: parameter
  /// Usually calls the open() function to open the Database
  @override
  @mustCallSuper
  Future<bool> init({bool throwError = false}) {
    return open(throwError: throwError);
  }

  /// Called in a State object's dispose() function.
  /// Usually call close() function to close the Database.
  /// Leave the word 'dispose' to subclasses.
  @override
  @mustCallSuper
  void disposed() {
    close();
  }

  /// Opens the Database
  @override
  Future<bool> open({bool throwError = false}) async {
    final open = await _dbInt!.open();
    if (!open) {
      _dbError.set(_dbInt!.ex);
      // Once recorded, don't keep as it may mislead future calls.
      if (throwError && _dbInt!.ex != null) {
        final Exception err = _dbInt!.ex!;
        _dbInt!.ex = null;
        throw err;
      } else {
        _dbInt!.ex = null;
      }
    }
    return open;
  }

  /// Close the Database
  @override
  void close() {
    // Sometimes there's no open(). gp
    _dbInt?.close();
  }

  /// List of the tables and list their fields: Map<String, List>
  @override
  Map<String, List<String>> get fields => _dbInt!._fields;

  /// Get the key field for a table
  @override
  Future<String?> keyField(String table) async {
    if (db == null) {
      await open();
    }
    return _dbInt!._keyFields[table];
  }

  /// Create a new 'empty' record from a specified data table
  @override
  Map<String, Map<String, dynamic>> get newrec => _dbInt!._newRec;

  /// Gets the Database
  @override
  Database? get db => _dbInt!.db;

  /// Gets the exception if any.
  @override
  Exception? get error => _dbError.e;

  /// Contains the last exception if any
  @override
  set error(Exception? ex) => _dbError.set(ex);

  /// Get the error message
  @override
  String get message => _dbError.message;

  /// Has an error.
  bool get hasError => _dbError.inError;

  /// There was no error
  @override
  bool get noError => _dbError.noError;

  /// How many records were last updated.
  @override
  int? get recsUpdated => _dbInt!.rowsUpdated;

  /// Save the specified record values to the specified data table
  /// Neither parameters can be null
  @override
  Future<Map<String, dynamic>> saveRec(
      String table, Map<String, dynamic> fldValues) async {
    return updateRec(table, fldValues);
  }

  /// Initiate a Database transaction
  /// All sequences are rolled back in one among them fails.
  @override
  Future<void> runTxn(void Function() func, {bool? exclusive}) =>
      db!.transaction((txn) async => func(), exclusive: exclusive);

  /// Save the specified record values to the specified data table
  /// Either parameters may be null
  @override
  Future<Map<String, dynamic>> saveMap(
      String? table, Map<String, dynamic>? values) async {
    if (table == null || table.isEmpty || values == null || values.isEmpty) {
      return {};
    }
    final Map<String, dynamic> rec = newRec(table, values);
    return saveRec(table, rec);
  }

  /// Update the specified record from the specified data table
  @override
  Future<Map<String, dynamic>> updateRec(
      String table, Map<String, dynamic> fields) async {
    Map<String, dynamic> rec;
    try {
      rec = await _dbInt!.updateRec(table, fields);
      _dbError.clear();
    } catch (e) {
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
      rec = {};
    }
    return rec;
  }

  /// Return an 'empty' record map
  @override
  Map<String, dynamic> newRec(String table, [Map<String, dynamic>? data]) {
    final Map<String, dynamic> newRec = {};

    newRec.addAll(_dbInt!._newRec[table]!);

    if (data != null) {
      data.forEach((key, value) {
        if (newRec.containsKey(key)) {
          newRec[key] = value;
        }
      });
    }

    return newRec;
  }

  /// Return a specific record by primary key from a specified data table
  @override
  Future<List<Map<String, dynamic>>> getRecord(String table, int id) async {
    return getRow(table, id, _dbInt!._fields);
  }

  /// Return the specified fields from a specified record by primary key
  /// from a specified data table
  @override
  Future<List<Map<String, dynamic>>> getRow(
      String table, int id, Map<String, dynamic> fields) async {
    List<Map<String, dynamic>> rec;
    try {
      rec = await _dbInt!.getRec(table, id, fields[table]);
      _dbError.clear();
    } catch (e) {
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
      rec = [];
    }
    return rec;
  }

  /// Delete a data table's record by its primary key
  /// Returns the number of records effected.
  @override
  Future<int> delete(String table, int id) async {
    int rows;
    try {
      rows = await _dbInt!.delete(table, id);
      _dbError.clear();
    } catch (e) {
      rows = 0;
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return rows;
  }

  /// Delete the specified record by using a where clause from the specified data table
  @override
  Future<int> deleteRec(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    int rows;
    try {
      rows = await _dbInt!.deleteRec(table, where: where, whereArgs: whereArgs);
      _dbError.clear();
    } catch (e) {
      rows = 0;
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return rows;
  }

  /// Executes a raw SQL SELECT query and returns a list
  /// of the rows that were found.
  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sqlStmt) async {
    List<Map<String, dynamic>> recs;
    try {
      recs = await _dbInt!.rawQuery(sqlStmt);
      // Convert the QueryResultSet to a Map
      recs = mapQuery(recs);
      _dbError.clear();
    } catch (e) {
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
      recs = [];
    }
    return recs;
  }

  /// Executes a raw SQL INSERT query and returns the last inserted row ID.
  @override
  Future<int> rawInsert(String sqlStmt, [List<dynamic>? arguments]) async {
    int recs;
    try {
      recs = await _dbInt!.rawInsert(sqlStmt, arguments);
      _dbError.clear();
    } catch (e) {
      recs = 0;
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return recs;
  }

  /// int count = await database.rawUpdate('UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',["updated name", "9876", "some name"]);
  @override
  Future<int> rawUpdate(String sqlStmt, [List<dynamic>? arguments]) async {
    int recs;
    try {
      recs = await _dbInt!.rawUpdate(sqlStmt, arguments);
      _dbError.clear();
    } catch (e) {
      recs = 0;
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return recs;
  }

  /// int cnt = await _this.rawDelete('DELETE FROM Yahoo WHERE id = ?',id);
  @override
  Future<int> rawDelete(String sqlStmt, [List<dynamic>? arguments]) async {
    int recs;
    try {
      recs = await _dbInt!.rawDelete(sqlStmt, arguments);
      _dbError.clear();
    } catch (e) {
      recs = 0;
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return recs;
  }

  /// Return a List of records from a specified data table.
  @override
  Future<List<Map<String, dynamic>>> getTable(String table,
      {bool? distinct,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {
    return query(
      table,
      columns: _dbInt!._fields[table],
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

  /// Returns a list of record from the specified data table
  /// based on its where clause
  @override
  Future<List<Map<String, dynamic>>> query(String table,
      {List<String>? columns,
      bool? distinct,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    List<Map<String, dynamic>> recs;

    try {
      recs = await _dbInt!.query(
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
      recs = [];
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return recs;
  }

  /// Return a List of records from a query result
  @override
  List<Map<String, dynamic>> mapQuery(List<Map<String, dynamic>> query) {
    final List<Map<String, dynamic>> mapList = [];
    for (final row in query) {
      final Map<String, dynamic> map =
          row.map((key, value) => MapEntry(key, value));
      mapList.add(map);
    }
    return mapList;
  }

  /// Return a list of data tables in the Database
  @override
  Future<List<Map<String, dynamic>>> tableNames() async {
    List<Map<String, dynamic>> rec;
    try {
      rec = await _dbInt!.tableNames();
      _dbError.clear();
    } catch (e) {
      rec = [];
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return rec;
  }

  /// Return the field names of the specified data table
  @override
  Future<List<Map<String, dynamic>>> tableColumns(String table) async {
    List<Map<String, dynamic>> rec;
    try {
      rec = await _dbInt!.tableColumns(table);
      _dbError.clear();
    } catch (e) {
      rec = [];
      final Exception ex = e is Exception ? e : Exception(e.toString());
      _dbError.set(ex);
    }
    return rec;
  }

  static Exception? _exception;

  /// Record the current Database error
  static void setError(Object? ex) {
    if (ex is! Exception) {
      ex = Exception(ex.toString());
    }
    _exception = ex;
  }

  /// Retrieve the current Database error if any
  static Exception? getError() {
    final ex = _exception;
    _exception = Exception();
    return ex;
  }

  /// Indicate if there was a recent Database error
  @override
  bool get inError => _dbError.inError;

  /// Was there a 'Database Closed' error
  @override
  bool get isDatabaseClosedError => _dbError.isDatabaseClosedError();

  /// Was there a 'Database Exception' error
  @override
  bool get isDatabaseException => _dbError.isDatabaseException;

  /// Was there a 'No Such Table' error
  @override
  bool get isNoSuchTableError => _dbError.isNoSuchTableError();

  /// Was there a 'Open Failed' error
  @override
  bool get isOpenFailedError => _dbError.isOpenFailedError();

  /// Was there a 'ReadOnly' error
  @override
  bool get isReadOnlyError => _dbError.isReadOnlyError();

  /// Was there a 'Syntax' error
  @override
  bool get isSyntaxError => _dbError.isSyntaxError();

  /// Was there a 'Unique Constraint' error
  @override
  bool get isUniqueConstraintError => _dbError.isUniqueConstraintError();
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
    return message = ex?.toString() ?? '';
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

  /// Opens the Database
  Future<bool> open() async {
    bool opened;

    if (db != null) {
      opened = db is Database && db!.path.isNotEmpty;
    } else {
      assert(version! > 0, 'Version number must be greater than one!');

      final path = await localPath;

      final String dbPath = join(path, name);

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
        await _tableFields();

        opened = true;
      } catch (e) {
        opened = false;
        ex = e is Exception ? e : Exception(e.toString());
      }
    }
    return opened;
  }

  /// Close the Database
  void close() {
    final temp = db;

    /// Hot reload must have db close & set to null first.
    db = null;

    /// Don't provide the 'await' command as the process MUST wait.
    temp?.close();
  }

  int? rowsUpdated;

  /// Update the specified record from the specified data table
  Future<Map<String, dynamic>> updateRec(
      String? table, Map<String, dynamic> fields) async {
    rowsUpdated = 0;
    final String keyFld = _keyFields[table]!;
    final keyValue = fields[keyFld];
    if (table == null) {
      /// We got nothing.
    } else if (keyValue == null) {
      fields[keyFld] = await db!.insert(table, fields);
      rowsUpdated = 1;
    } else {
      rowsUpdated = await db!
          .update(table, fields, where: '$keyFld = ?', whereArgs: [keyValue]);
    }
    return fields;
  }

  /// Return a specific record by primary key from a specified data table
  /// Return only a subset of field columns if specified
  Future<List<Map<String, dynamic>>> getRec(
      String table, int id, List<String>? fields) async {
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return Future.value([{}]);
      }
    }
    return db!.query(table,
        columns: fields, where: '${_keyFields[table]} = ?', whereArgs: [id]);
  }

  /// Delete a data table's record by its primary key
  /// Returns the number of records effected.
  Future<int> delete(String table, int id) async {
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return Future.value(0);
      }
    }
    return db!
        .delete(table, where: '${_keyFields[table]} = ?', whereArgs: [id]);
  }

  /// Delete the specified record by using a where clause
  /// from the specified data table
  Future<int> deleteRec(String? table,
      {String? where, List<dynamic>? whereArgs}) async {
    if (table == null || table.isEmpty) {
      return 0;
    }
    if (where == null || where.isEmpty) {
      return 0;
    }
    if (whereArgs == null || whereArgs.isEmpty) {
      return 0;
    }
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return Future.value(0);
      }
    }
    return db!.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Executes a raw SQL SELECT query and returns a list
  /// of the rows that were found.
  Future<List<Map<String, dynamic>>> rawQuery(String sqlStmt) async {
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return Future.value([{}]);
      }
    }
    return db!.rawQuery(sqlStmt);
  }

  /// Executes a raw SQL INSERT query and returns the last inserted row ID.
  Future<int> rawInsert(String sqlStmt, [List<Object?>? arguments]) async {
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return 0;
      }
    }
    return db!.rawInsert(sqlStmt, arguments);
  }

  /// Executes a raw SQL UPDATE query and returns
  /// the number of changes made.
  ///
  /// ```
  /// int count = await database.rawUpdate(
  ///   'UPDATE Test SET name = ?, value = ? WHERE name = ?',
  ///   ['updated name', '9876', 'some name']);
  /// ```
  Future<int> rawUpdate(String sqlStmt, [List<Object?>? arguments]) async {
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return 0;
      }
    }
    return db!.rawUpdate(sqlStmt, arguments);
  }

  /// Executes a raw SQL DELETE query and returns the
  /// number of changes made.
  ///
  /// ```
  /// int count = await database
  ///   .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
  ///
  Future<int> rawDelete(String sqlStmt, [List<Object?>? arguments]) async {
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return 0;
      }
    }
    return db!.rawDelete(sqlStmt, arguments);
  }

  /// Returns a list of record from the specified data table
  /// based on its where clause
  Future<List<Map<String, dynamic>>> query(String table,
      {bool? distinct = false,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return Future.value([{}]);
      }
    }
    final List<String>? cols = columns ?? _fields[table];
    return db!.query(
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

  /// Return a list of data tables in the Database
  Future<List<Map<String, dynamic>>> tableNames() async {
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return Future.value([{}]);
      }
    }
    return db!.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  }

  /// Return the field names of the specified data table
  Future<List<Map<String, dynamic>>> tableColumns(String? table) async {
    if (db == null) {
      final open = await this.open();
      if (!open) {
        return Future.value([{}]);
      }
    }
    return db!.rawQuery("pragma table_info('$table')");
  }

  /// Return a list of tables residing in the Database
  Future<List<String>> _tableList() async {
    final List<Map<String, dynamic>> tables = await tableNames();

    final List<String> list = [];

    // Include android metadata table as well with 0; iOS then works.
    for (var i = 0; i < tables.length; i++) {
      list.add(tables[i]['name']);
    }
    return list;
  }

  final Map<String, List<String>> _fields = {};

  final Map<String, String?> _keyFields = {};

  final Map<String, Map<String, dynamic>> _newRec = {};

  /// Map all the tables and their fields
  Future<void> _tableFields() async {
    dynamic fldValue;
    String keyField;
    String type;

    final tables = await _tableList();

    for (final table in tables) {
      //
      final columns = await tableColumns(table);

      final List<String> fields = [];

      /// ROWID is automatically added to all SQLite tables by default, and is a unique integer,
      keyField = 'rowid';

      fields.add(keyField);

      final Map<String, dynamic> fieldValues = {};

      fieldValues[keyField] = null;

      _keyFields[table] = keyField;

      for (final col in columns) {
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

            switch (type.toLowerCase()) {
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
              switch (type.toLowerCase()) {
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

      _newRec[table] = <String, dynamic>{};

      /// Make a copy as an 'empty' record.
      _newRec[table]!
          .addEntries(fieldValues.entries); //_fldValues[table].entries);
    }
  }

  /// Return the 'local' path where the Database resides
  Future<String> get localPath async {
    String path;
    if (_path != null) {
      path = _path!;
    } else {
      try {
        final Directory directory = await getApplicationDocumentsDirectory();
        path = directory.path;
      } catch (e) {
        path = '';
        ex = e is Exception ? e : Exception(e.toString());
      }
      _path = path;
    }
    return path;
  }

  String? _path;
}
