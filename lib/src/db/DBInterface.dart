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

typedef Future OnCreate(Database db, int version);


class _DBInterface{
  _DBInterface({
    this.name,
    this.version,
    this.onCreate,
  });

  final String name;
  final int version;
  final OnCreate onCreate;

  init(){

    create();
  }

  // abstract method
//  Future onCreate(Database db, int version);

  Database _db;
  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await create();
    return _db;
  }

  Future<Database> create() async {
    var path = await Files.localPath;
    String dbPath = join(path, name);

    _db = await openDatabase(dbPath, version: 1,
        onCreate: onCreate);

    _tableFields();

    return _db;
  }

  int _rowsUpdated =0;
  get rows => _rowsUpdated;

  Future<Map> updateRec(String table, Map fields) async {
    if (fields["id"] == null) {
      fields["id"] = await _db.insert(table, fields);
    } else {
      _rowsUpdated = await _db.update(table, fields, where: "id = ?", whereArgs: [fields["id"]]);
    }
    return fields;
  }

  Future<List<Map>> getRec(String table, int id, Map fields) async {
    return await _db.query(table, columns: fields.keys.toList(), where: "id = ?", whereArgs: [id]);
  }


  Future<List<Map>> query(String table, Map fields,{String orderBy: "id ASC"}) async {
    return await _db.query(table, columns: fields.keys.toList(), orderBy: orderBy);
  }

  Future<List<Map>> tableNames( ) async{
    return await _db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  }

  Future<List<Map>> tableColumns(String table) async{
    return await _db.rawQuery("pragma table_info('$table')");
  }

  List<String> _tables = List();

  Future<List<String>> _tableList() async{

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

  void _tableFields() async{

    var tables = await _tableList();

    for (var table in tables) {

      var columns = await tableColumns(table);

      List<String> fields = List();

      Map<String, dynamic> fieldValues = Map();

      for (var col in columns) {
        
        fields.add(col['name']);

        fieldValues[col['name']] = null;
      }

      _fields[table] = fields;

      _fldValues[table] = fieldValues;
    }
  }
}



abstract class DBInterface{

  // ignore: implicit_this_reference_in_initializer, implicit_this_reference_in_initializer
  DBInterface(): _dbInt = _DBInterface(name: name, version: version, onCreate: onCreate);

  final _DBInterface _dbInt;

  get name;

  get version;

  init(){

    _dbInt.init();
  }
  
  // abstract method
  Future onCreate(Database db, int version);

  get fields => _dbInt._fields;

  get values => _dbInt._fldValues;

  get db => _dbInt.db;
  
  Future<Database> create(){
    return _dbInt.create();
  }

  Future<Map> saveRec(String table){
    return _dbInt.updateRec(table, _dbInt._fldValues[table]);
  }

  Future<Map> updateRec(String table, Map fields){
    return _dbInt.updateRec(table, fields);
  }

  Future<List<Map>> getRec(String table, int id, Map fields){
    return _dbInt.getRec(table, id, fields);
  }

  Future<List<Map>> query(String table, Map fields,{String orderBy: "id ASC"}){
    return _dbInt.query(table, fields, orderBy: orderBy);
  }

  Future<List<Map>> tableNames(){
    return _dbInt.tableNames();
  }

  Future<List<Map>> tableColumns(String table){
    return _dbInt.tableColumns(table);
  }
}