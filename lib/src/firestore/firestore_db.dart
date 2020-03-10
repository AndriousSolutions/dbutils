///
/// Copyright (C) 2020 Andrious Solutions
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
///          Created  08 Feb 2020
///
///
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class FireStoreDB {
  //
  FireStoreDB(String path) {
    _auth = FirebaseAuth.instance;
    _auth.currentUser().then((user) {
      _user = user;
    });
    _store = Firestore.instance;
    _collection = _store.collection(path);
  }
  FirebaseAuth _auth;
  Firestore _store;
  FirebaseUser _user;

  CollectionReference get collection => _collection;
  CollectionReference _collection;

  Future<FirebaseUser> currentUser() async {
    _user ??= await _auth.currentUser();
    return _user;
  }

  String get uid => _user.uid;

  bool get inError => _ex != null;
  Exception _ex;

  Future<bool> update(String path, Map<String, dynamic> data) async {
    bool update = true;
    try {
      DocumentReference ref = _collection.document(path);
      update = await ref.updateData(data).then((_) {
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
    FirebaseUser user = await currentUser();
    data['uid'] = user.uid;
    docId = await _collection.add(data).then((ref) {
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
      DocumentReference ref = _collection.document(docId);
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
  Future<Map<String, dynamic>> runTransaction(TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 10)}) => _store.runTransaction(transactionHandler, timeout: timeout);

  set ex(Exception ex) => setError(ex);

  Exception setError(Exception ex) => getError(ex);

  Exception getError([Exception ex]) {
    Exception e = _ex;
    if (ex == null) {
      _ex = null;
    } else {
      _ex = ex;
    }

    /// Return the stored error if any.
    if (e == null) e = _ex;
    return e;
  }
}
