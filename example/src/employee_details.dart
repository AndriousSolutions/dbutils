// Copyright 2021 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'employee_database.dart';

class EmployeeDetails extends StatefulWidget {
  const EmployeeDetails({Key? key, required this.employee}) : super(key: key);
  final Map<String, dynamic> employee;

  @override
  _EmployeeDetailsState createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
  final Employee _db = Employee();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Employee'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.employee.isEmpty
                      ? null
                      : widget.employee['firstname'],
                  keyboardType: TextInputType.text,
                  inputFormatters: [ProperCaseTextFormatter()],
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (val) => val!.isEmpty ? 'Enter FirstName' : null,
                  onSaved: (val) => widget.employee['firstname'] = val,
                ),
                TextFormField(
                  initialValue: widget.employee.isEmpty
                      ? null
                      : widget.employee['lastname'],
                  keyboardType: TextInputType.text,
                  inputFormatters: [ProperCaseTextFormatter()],
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (val) => val!.isEmpty ? 'Enter LastName' : null,
                  onSaved: (val) => widget.employee['lastname'] = val,
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  /// Submit the current record to be saved.
  /// The record is, of course, a Map passed to the database.
  void _save() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    } else {
      return;
    }

    _db.saveRecord(widget.employee).then((saved) {
      final text = saved ? 'Data saved successfully' : 'Data not saved!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    });

    Navigator.pop(context);
  }
}

/// Ensures the text starts with a capital letter.
class ProperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final word = newValue.text;
    return TextEditingValue(
      text: oldValue.text == '' ? word.toUpperCase() : word,
      selection: newValue.selection,
    );
  }
}
