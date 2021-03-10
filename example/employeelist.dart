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
import 'package:flutter/material.dart';

import 'employee.dart' show Employee;

import 'employeedetail.dart';

class MyEmployeeList extends StatefulWidget {
  MyEmployeeList({Key? key}) : super(key: key);
  final MyEmployeeListPageState state = MyEmployeeListPageState();
  @override
  MyEmployeeListPageState createState() => state;
}

class MyEmployeeListPageState extends State<MyEmployeeList> {
  late Employee db;
  @override
  void initState() {
    super.initState();
    db = Employee();
//    db.init();
  }

  @override
  void dispose() {
    db.disposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: db.getEmployees(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: Feedback.wrapForTap(
                            () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => MyEmployee(
                                    employee: snapshot.data![index]))),
                            context),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(snapshot.data![index]['firstname'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0)),
                              Text(snapshot.data![index]['lastname'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0)),
                              Divider()
                            ]));
                  });
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Container(
              alignment: AlignmentDirectional.center,
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    MyEmployee(employee: db.emptyRec())));
          }),
    );
  }
}
