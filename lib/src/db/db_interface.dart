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

abstract class DBInterface {
  Exception error;

  // TODO: implement name
  String get name => throw UnimplementedError();

  // TODO: implement db
  dynamic get db => throw UnimplementedError();

  // TODO: implement version
  int get version => throw UnimplementedError();

  Future<bool> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  Future<bool> open() {
    // TODO: implement open
    throw UnimplementedError();
  }

  void close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  Future<int> delete(String table, int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  void disposed() {
    // TODO: implement disposed
  }

  // TODO: implement message
  String get message => throw UnimplementedError();

  // TODO: implement fields
  Map<String, List> get fields => throw UnimplementedError();

  Future<List<Map<String, dynamic>>> getRecord(String table, int id) {
    // TODO: implement getRecord
    throw UnimplementedError();
  }

  Future<List<Map<String, dynamic>>> getRow(String table, int id, Map fields) {
    // TODO: implement getRow
    throw UnimplementedError();
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
    // TODO: implement getTable
    throw UnimplementedError();
  }

  Future<String> keyField(String table) {
    // TODO: implement keyField
    throw UnimplementedError();
  }

  List<Map<String, dynamic>> mapQuery(List<Map<String, dynamic>> query) {
    // TODO: implement mapQuery
    throw UnimplementedError();
  }

  Map<String, dynamic> newRec(String table, [Map<String, dynamic> data]) {
    // TODO: implement newRec
    throw UnimplementedError();
  }

  // TODO: implement newrec
  Map<String, Map> get newrec => throw UnimplementedError();

  // TODO: implement noError
  bool get noError => throw UnimplementedError();

  Future<List<Map<String, dynamic>>> query(String table, List columns,
      {bool distinct,
      String where,
      List whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) {
    // TODO: implement query
    throw UnimplementedError();
  }

  Future<int> rawDelete(String sqlStmt, [List arguments]) {
    // TODO: implement rawDelete
    throw UnimplementedError();
  }

  Future<int> rawInsert(String sqlStmt, [List arguments]) {
    // TODO: implement rawInsert
    throw UnimplementedError();
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sqlStmt) {
    // TODO: implement rawQuery
    throw UnimplementedError();
  }

  Future<int> rawUpdate(String sqlStmt, [List arguments]) {
    // TODO: implement rawUpdate
    throw UnimplementedError();
  }

  // TODO: implement recsUpdated
  int get recsUpdated => throw UnimplementedError();

  Future<void> runTxn(void Function() func) {
    // TODO: implement runTxn
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> saveMap(
      String table, Map<String, dynamic> values) {
    // TODO: implement saveMap
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> saveRec(
      String table, Map<String, dynamic> fldValues) {
    // TODO: implement saveRec
    throw UnimplementedError();
  }

  Future<List<Map>> tableColumns(String table) {
    // TODO: implement tableColumns
    throw UnimplementedError();
  }

  Future<List<Map>> tableNames() {
    // TODO: implement tableNames
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> updateRec(
      String table, Map<String, dynamic> fields) {
    // TODO: implement updateRec
    throw UnimplementedError();
  }

  // TODO: implement inError
  bool get inError => throw UnimplementedError();

  // TODO: implement isDatabaseClosedError
  bool get isDatabaseClosedError => throw UnimplementedError();

  // TODO: implement isDatabaseException
  bool get isDatabaseException => throw UnimplementedError();

  // TODO: implement isNoSuchTableError
  bool get isNoSuchTableError => throw UnimplementedError();

  // TODO: implement isOpenFailedError
  bool get isOpenFailedError => throw UnimplementedError();

  // TODO: implement isReadOnlyError
  bool get isReadOnlyError => throw UnimplementedError();

  // TODO: implement isSyntaxError
  bool get isSyntaxError => throw UnimplementedError();

  // TODO: implement isUniqueConstraintError
  bool get isUniqueConstraintError => throw UnimplementedError();
}
