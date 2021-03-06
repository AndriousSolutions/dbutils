///
/// Copyright (C) 2020 Andrious Solutions
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
///          Created  08 Feb 2020
///
///
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class FireStoreDB {
  //
  FireStoreDB(String path) {
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;
    _store = FirebaseFirestore.instance;
    _collection = _store.collection(path);
  }
  late FirebaseAuth _auth;
  late FirebaseFirestore _store;
  User? _user;

  CollectionReference? get collection => _collection;
  CollectionReference? _collection;

  /// The current user.
  /// No longer async operation but we'll keep it backward-compatible.
  Future<User?> currentUser() async {
    _user ??= _auth.currentUser;
    return _user;
  }

  String get uid => _user!.uid;

  bool get inError => _ex != null;
  Exception? _ex;

  Future<bool> update(String path, Map<String, dynamic> data) async {
    bool update = true;
    try {
      DocumentReference ref = _collection!.doc(path);
      update = await ref.update(data).then((_) {
        return true;
      }).catchError((ex) {
        setError(ex);
        return false;
      });
    } catch (ex) {
      setError(ex);
      update = false;
    }
    return update;
  }

  Future<String> add(Map<String, dynamic> data) async {
    String docId;
    User user = await (currentUser() as Future<User>);
    data['uid'] = user.uid;
    docId = await _collection!.add(data).then((ref) {
      List<String> path = ref.path.split("/");
      return path.last;
    }).catchError((ex) {
      setError(ex);
      return "";
    });
    return docId;
  }

  Future<bool> delete(String docId) async {
    if (docId == null || docId.trim().isEmpty) return false;
    bool delete = true;
    try {
      DocumentReference ref = _collection!.doc(docId);
      delete = await ref.delete().then((_) {
        return true;
      }).catchError((ex) {
        setError(ex);
        return false;
      });
    } catch (ex) {
      setError(ex);
      delete = false;
    }
    return delete;
  }

  /// Doubled the attempt duration to 10 seconds.
  Future<Map<String, dynamic>> runTransaction(
          TransactionHandler transactionHandler,
          {Duration timeout = const Duration(seconds: 10)}) =>
      _store.runTransaction(transactionHandler as Future<Map<String, dynamic>> Function(Transaction), timeout: timeout);

  set ex(Exception ex) => setError(ex);

  Exception setError(Object ex) => getError(ex);

  Exception getError([Object? ex]) {
    Exception? e = _ex;
    if (ex == null) {
      _ex = null;
    } else {
      _ex = ex as Exception;
    }

    /// Return the stored error if any.
    if (e == null) e = _ex;
    return e!;
  }
}
