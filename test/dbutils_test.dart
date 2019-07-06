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
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import '../example/employee.dart';
import '../example/employeelist.dart';
import '../example/main.dart';

void main() {
  testWidgets('Counter App Test', (WidgetTester tester) async {
    // Use a key to locate the widget you need to test
    Key key = UniqueKey();

    // Tells the tester to build a UI based on the widget tree passed to it
    await tester.pumpWidget(MyApp(key: key));

    /// You can directly access the 'internal workings' of the app!
    MyEmployeeList _statefulWidget = tester.widget(find.byKey(key));

    /// Reference to the Controller.
    MyEmployeeListPageState _state = _statefulWidget.state;

    Employee _db = _state.db;
  });
}
