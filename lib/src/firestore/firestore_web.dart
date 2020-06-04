/////
///// Copyright (C) 2020 Andrious Solutions
/////
///// Licensed under the Apache License, Version 2.0 (the "License");
///// you may not use this file except in compliance with the License.
///// You may obtain a copy of the License at
/////
/////    http://www.apache.org/licenses/LICENSE-2.0
/////
///// Unless required by applicable law or agreed to in writing, software
///// distributed under the License is distributed on an "AS IS" BASIS,
///// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///// See the License for the specific language governing permissions and
///// limitations under the License.
////
/////          Created  04 Feb 2020
/////
/////
//
///// Comment out so to run app in a mobile app.
//import 'package:firebase/firebase.dart' hide Transaction;
//
///// Comment out so to run app in a mobile app.
//import 'package:firebase/firestore.dart';
//
//
//class FireStoreDB {
//  //
//  FireStoreDB(String path) {
//    _store =  firestore();
//    _auth = _store.app.auth();
//    _collection = _store.collection(path);
//  }
//  Firestore _store;
//  Auth _auth;
//  Exception _ex;
//
//  CollectionReference get collection => _collection;
//  CollectionReference _collection;
//
//  Future<bool> update(String path, Map<String, dynamic> data) async {
//    bool update = true;
//    try {
//      DocumentReference ref = _collection.doc(path);
//      update = await ref.update(data: data).then((_) {
//        return true;
//      }).catchError((ex) {
//        setError(ex);
//        return false;
//      });
//    } catch (ex) {
//      setError(ex);
//      update = false;
//    }
//    return update;
//  }
//
//  Future<String> add(Map<String, dynamic> data) async {
//    String docId;
//    User user = _auth.currentUser;
//    data['uid'] = user.uid;
//    docId = await _collection.add(data).then((ref) {
//      List<String> path = ref.path.split("/");
//      return path.last;
//    }).catchError((ex) {
//      setError(ex);
//      return "";
//    });
//    return docId;
//  }
//
//  Future<bool> delete(String docId) async {
//    if (docId == null || docId.trim().isEmpty) return false;
//    bool delete = true;
//    try {
//      DocumentReference ref = _collection.doc(docId);
//      delete = await ref.delete().then((_) {
//        return true;
//      }).catchError((ex) {
//        setError(ex);
//        return false;
//      });
//    } catch (ex) {
//      setError(ex);
//      delete = false;
//    }
//    return delete;
//  }
//
//  /// Doubled the attempt duration to 10 seconds.
//  Future<void> runTransaction(Function(Transaction) func) => _store.runTransaction(func);
//
//  bool get inError => _ex != null;
//
//  set ex(Exception ex) => setError(ex);
//
//  Exception setError(Exception ex) => getError(ex);
//
//  Exception getError([Exception ex]) {
//    Exception e = _ex;
//    if (ex == null) {
//      _ex = null;
//    } else {
//      _ex = ex;
//    }
//
//    /// Return the stored error if any.
//    if (e == null) e = _ex;
//    return e;
//  }
//}
//
//
