// Copyright 2021 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// For a demonstration, class SQLiteDB implements DBInterface
abstract class DBInterface {
  /// Contains the last exception if any
  Exception? error;

  /// Name of the database
  String get name => throw UnimplementedError();

  /// Database object
  dynamic get db => throw UnimplementedError();

  /// Current Database version number
  /// Update with any data tables changes.
  int get version => throw UnimplementedError();

  /// Called in the initState() function or the FutureBuilder(future: parameter
  /// Usually calls the open() function to open the Database
  Future<bool> init() {
    throw UnimplementedError();
  }

  /// Opens the Database
  Future<bool> open() {
    throw UnimplementedError();
  }

  /// Close the Database
  void close() {
    throw UnimplementedError();
  }

  /// Delete a data table's record by its primary key
  /// Returns the number of records effected.
  Future<int> delete(String table, int id) {
    throw UnimplementedError();
  }

  /// Delete the specified record by using a where clause
  /// from the specified data table
  Future<int> deleteRec(String table,
      {String? where, List<dynamic>? whereArgs}) {
    throw UnimplementedError();
  }

  /// Called in a State object's dispose() function.
  /// Usually call close() function to close the Database.
  /// Leave the word 'dispose' to subclasses. gp
  void disposed() {
    // TODO: implement disposed
  }

  /// Return any SQL or Database error message
  String get message => throw UnimplementedError();

  /// Contains a list of columns of each table
  Map<String, List<String>> get fields => throw UnimplementedError();

  /// Return a specific record by primary key from a specified data table
  Future<List<Map<String, dynamic>>> getRecord(String table, int id) {
    throw UnimplementedError();
  }

  /// Return the specified fields from a specified record by primary key
  /// from a specified data table
  Future<List<Map<String, dynamic>>> getRow(
      String table, int id, Map<String, dynamic> fields) {
    throw UnimplementedError();
  }

  /// Return a List of records from a specified data table.
  Future<List<Map<String, dynamic>>> getTable(String table,
      {bool? distinct,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {
    throw UnimplementedError();
  }

  /// Return the primary key name from the specified data table
  Future<String?> keyField(String table) {
    throw UnimplementedError();
  }

  /// Return a List of records from a query result
  List<Map<String, dynamic>> mapQuery(List<Map<String, dynamic>> query) {
    throw UnimplementedError();
  }

  /// Create a new 'empty' record from a specified data table
  /// Specified the fields to come from the data table
  Map<String?, dynamic> newRec(String table, [Map<String, dynamic>? data]) {
    throw UnimplementedError();
  }

  /// Create a new 'empty' record from a specified data table
  Map<String, Map<String, dynamic>> get newrec => throw UnimplementedError();

  /// Returns true if there was not an error recently.
  bool get noError => throw UnimplementedError();

  /// Returns a list of record from the specified data table
  /// based on its where clause
  Future<List<Map<String, dynamic>>> query(String table,
      {List<String>? columns,
      bool? distinct,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {
    throw UnimplementedError();
  }

  /// Executes a raw SQL DELETE query and returns the
  /// number of changes made.
  ///
  /// ```
  /// int count = await database
  ///   .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
  ///
  Future<int> rawDelete(String sqlStmt, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  /// Executes a raw SQL INSERT query and returns the last inserted row ID.
  Future<int> rawInsert(String sqlStmt, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  /// Executes a raw SQL SELECT query and returns a list
  /// of the rows that were found.
  Future<List<Map<String, dynamic>>> rawQuery(String sqlStmt) {
    throw UnimplementedError();
  }

  /// Executes a raw SQL UPDATE query and returns
  /// the number of changes made.
  ///
  /// ```
  /// int count = await database.rawUpdate(
  ///   'UPDATE Test SET name = ?, value = ? WHERE name = ?',
  ///   ['updated name', '9876', 'some name']);
  /// ```
  Future<int> rawUpdate(String sqlStmt, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  /// The of records updated in the last Database operation
  int? get recsUpdated => throw UnimplementedError();

  /// Initiate a Database transaction
  /// All sequences are rolled back in one among them fails.
  Future<void> runTxn(void Function() func) {
    throw UnimplementedError();
  }

  /// Save the specified record values to the specified data table
  /// Either parameters may be null
  Future<Map<String, dynamic>> saveMap(
      String? table, Map<String, dynamic>? values) {
    throw UnimplementedError();
  }

  /// Save the specified record values to the specified data table
  /// Neither parameters can be null
  Future<Map<String, dynamic>> saveRec(
      String table, Map<String, dynamic> fldValues) {
    throw UnimplementedError();
  }

  /// Return the field names of the specified data table
  Future<List<Map<String, dynamic>>> tableColumns(String table) {
    throw UnimplementedError();
  }

  /// Return a list of data tables in the Database
  Future<List<Map<String, dynamic>>> tableNames() {
    throw UnimplementedError();
  }

  /// Update the specified record from the specified data table
  Future<Map<String, dynamic>> updateRec(
      String table, Map<String, dynamic> fields) {
    throw UnimplementedError();
  }

  /// Indicate if there was a recent Database error
  bool get inError => throw UnimplementedError();

  /// Was there a 'Database Closed' error
  bool get isDatabaseClosedError => false;

  /// Was there a 'Database Exception' error
  bool get isDatabaseException => false;

  /// Was there a 'No Such Table' error
  bool get isNoSuchTableError => false;

  /// Was there a 'Open Failed' error
  bool get isOpenFailedError => false;

  /// Was there a 'ReadOnly' error
  bool get isReadOnlyError => false;

  /// Was there a 'Syntax' error
  bool get isSyntaxError => false;

  /// Was there a 'Unique Constraint' error
  bool get isUniqueConstraintError => false;
}
