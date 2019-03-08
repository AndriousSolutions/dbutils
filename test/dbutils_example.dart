///
/// Copyright (C) 2018 Andrious Solutions
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
///          Created  24 Nov 2018
///
import 'dart:async' show Future;

import 'package:flutter/material.dart' show AppBar, BuildContext, Colors, Column, Container, EdgeInsets, FlutterError, FlutterErrorDetails, Form, FormState, GlobalKey, Icon, IconButton, Icons, InputDecoration, Key, MaterialApp, MaterialPageRoute, Navigator, Padding, RaisedButton, Scaffold, ScaffoldState, SnackBar, State, StatefulWidget, StatelessWidget, Text, TextFormField, TextInputType, ThemeData, Widget, runApp;

import 'employee.dart' show Employee;

import 'employeelist.dart' show MyEmployeeList;


void main(){
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
      home: MyHomePage(key: key, title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  final MyHomePageState state = MyHomePageState();
  @override
  MyHomePageState createState() => state;
}

class MyHomePageState extends State<MyHomePage> {

  Employee db = Employee();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  @override
  initState(){
    super.initState();
    db.init();
  }

  @override
  void dispose() {
    db.disposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
          title: Text('Saving Employee'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.view_list),
              tooltip: 'Next choice',
              onPressed: () {
                navigateToEmployeeList();
              },
            ),
          ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (val) =>
                val.length == 0 ?"Enter FirstName" : null,
                onSaved: (val) => db.values['Employee']['firstname'] = val,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (val) =>
                val.length ==0 ? 'Enter LastName' : null,
                onSaved: (val) => db.values['Employee']['lastname'] = val,
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Mobile No'),
                validator: (val) =>
                val.length ==0 ? 'Enter Mobile No' : null,
                onSaved: (val) => db.values['Employee']['mobileno'] = val,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email Id'),
                validator: (val) =>
                val.length ==0 ? 'Enter Email Id' : null,
                onSaved: (val) =>db.values['Employee']['emailId'] = val,
              ),
              Container(margin: const EdgeInsets.only(top: 10.0),child: RaisedButton(onPressed: _submit,
                child: Text('Login'),),)

            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (this.formKey.currentState.validate()) {
      formKey.currentState.save();
    }else{
      return null;
    }

    db.save('Employee');
    _showSnackBar("Data saved successfully");
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(text)));
  }

  void navigateToEmployeeList(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyEmployeeList()),
    );
  }
}


/// Reports [error] along with its [stackTrace]
Future<Null> _reportError(FlutterErrorDetails details) async {
  // details.exception, details.stack

  FlutterError.dumpErrorToConsole(details);
}