///
/// Copyright (C) 2019 Andrious Solutions
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
///          Created  05 Jul 2019
///
///

import 'package:flutter/material.dart';

import 'employee.dart' show Employee;

class MyEmployee extends StatefulWidget {
  MyEmployee({Key key, this.employee}) : super(key: key);
  final Map<String, dynamic> employee;
  final MyEmployeeState state = MyEmployeeState();
  @override
  MyEmployeeState createState() => state;
}

class MyEmployeeState extends State<MyEmployee> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text('Employee'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Delete employee',
          onPressed: () {
            Employee().deleteEmp(widget.employee);
            Navigator.of(context).pop();
          },
        ),
      ]),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller:
                    TextEditingController(text: widget.employee['firstname']),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (val) => val.length == 0 ? "Enter FirstName" : null,
                onSaved: (val) => widget.employee['firstname'] = val,
              ),
              TextFormField(
                controller:
                    TextEditingController(text: widget.employee['lastname']),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (val) => val.length == 0 ? 'Enter LastName' : null,
                onSaved: (val) => widget.employee['lastname'] = val,
              ),
              TextFormField(
                controller:
                    TextEditingController(text: widget.employee['mobileno']),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Mobile No'),
                onSaved: (val) => widget.employee['mobileno'] = val,
              ),
              TextFormField(
                controller:
                    TextEditingController(text: widget.employee['emailId']),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email Id'),
                onSaved: (val) => widget.employee['emailId'] = val,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: RaisedButton(
                  onPressed: _submit,
                  child: Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (this.formKey.currentState.validate()) {
      formKey.currentState.save();
    } else {
      return null;
    }
    Employee().save(widget.employee).then((save) {
      if (save) {
        _showSnackBar("Data saved successfully");
        Navigator.of(context).pop();
      }
    });
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text)));
  }
}
