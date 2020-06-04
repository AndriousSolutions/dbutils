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

import 'package:flutter/material.dart';

import 'employeelist.dart';

void main() {
  /// The default is to dump the error to the console.
  /// Instead, a custom function is called.
  FlutterError.onError = (FlutterErrorDetails details) async {
    await _reportError(details);
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({this.key});
  final Key key;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFLite DataBase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(key: key),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.key}) : super();
  final Key key;
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => MyEmployeeList(key: widget.key);
}

/// Reports [error] along with its [stackTrace]
Future<void> _reportError(FlutterErrorDetails details) async {
  /// Turn to details.exception, details.stack
  FlutterError.dumpErrorToConsole(details);
}
