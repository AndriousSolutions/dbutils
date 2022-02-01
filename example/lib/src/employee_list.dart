// Copyright 2021 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'employee_database.dart';
import 'employee_details.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({Key? key}) : super(key: key);
  //
  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  //
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Employee List'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            /// Access the database's Employee data table.
            future: Employee().openDatabase(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        _employeeDetails(snapshot.data![index]);
                      },
                      child: Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            await Employee()
                                .deleteRecord(snapshot.data![index]);
                            setState(() {});
                          }
                        },
                        background: Container(
                          color: Colors.red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(snapshot.data![index]['firstname'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text(snapshot.data![index]['lastname'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              const Divider()
                            ]),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return Container(
                alignment: AlignmentDirectional.center,
                child: const CircularProgressIndicator(),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async => _employeeDetails(<String, dynamic>{}),
          child: const Icon(Icons.add),
        ),
      );

  Future<void> _employeeDetails(Map<String, dynamic> employee) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => EmployeeDetails(employee: employee),
    ));
    await Employee().getEmployees();
    setState(() {});
  }
}
