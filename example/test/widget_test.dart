// Copyright 2021 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/employee_database.dart';

import '../lib/src/employee_list.dart';

import '../lib/main.dart';

String _location = '========================== widget_test.dart';

void main() {
  testWidgets('Counter App Test', (WidgetTester tester) async {
    /// Renders the UI from the given [widget].
    await tester.pumpWidget(const MyApp());

    /// Waits for all animations to complete.
    await tester.pumpAndSettle();

    final employeeDB = Employee();

    // Remove any previous records.
    await employeeDB.rawDelete('DELETE FROM ${employeeDB.table}');

    State stateObj = tester.firstState<State>(find.byType(EmployeeList));

    await employeeDB.getEmployees();

    // ignore: INVALID_USE_OF_PROTECTED_MEMBER
    stateObj.setState(() {});
    await tester.pumpAndSettle();

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));

    await tester.pumpAndSettle();

    Finder finder = find.byType(TextFormField);

    // The text form fields should be available.
    expect(finder, findsWidgets, reason: _location);

    for (var cnt = 0; cnt < 2; cnt++) {
      //
      final field = finder.at(cnt);

      await tester.tap(field);
      await tester.pumpAndSettle();

      String text = '';

      switch (cnt) {
        case 0:
          text = 'Jimmy';
          break;
        case 1:
          text = 'Reacher';
          break;
      }
      await tester.enterText(field, text);
    }

    finder = find.widgetWithText(ElevatedButton, 'Save');

    expect(finder, findsOneWidget, reason: _location);

    await tester.tap(finder);
    await tester.pumpAndSettle();

    /// You can directly access the 'internal workings' of the app!
    // ignore: unused_local_variable
    EmployeeList list = tester.widget(find.byKey(const Key('EmployeeList')));
  });
}
