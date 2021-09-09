// Copyright 2021 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

@Deprecated('Use the class, FireStoreCollection, instead')
class FireStoreDB {
  FireStoreDB(String path) : _collection = FireStoreCollection(path);
  final FireStoreCollection _collection;

  CollectionReference? get collection => _collection.collection;

  Future<User?> currentUser() async => _collection.currentUser();

  String get uid => _collection.uid;

  bool get inError => _collection.inError;

  Future<bool> update(String path, Map<String, dynamic> data) async =>
      _collection.update(path, data);

  Future<String> add(Map<String, dynamic> data) async => _collection.add(data);

  Future<bool> delete(String docId) async => _collection.delete(docId);

  Future<Map<String, dynamic>> runTransaction(
          TransactionHandler transactionHandler,
          {Duration timeout = const Duration(seconds: 10)}) =>
      _collection.runTransaction(transactionHandler, timeout: timeout);

  // ignore: avoid_setters_without_getters
  set ex(Exception ex) => _collection.ex = ex;

  Exception setError(Object ex) => _collection.setError(ex);

  Exception getError([Object? ex]) => _collection.getError(ex);
}

/// todo: This has to be split up to a parent class.
class FireStoreCollection {
  //
  FireStoreCollection(String path) {
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
  Future<User?> currentUser() async => _user ??= _auth.currentUser;

  String get uid => _user!.uid;

  bool get inError => _ex != null;
  Exception? _ex;

  Future<bool> update(String path, Map<String, dynamic> data) async {
    bool update = true;
    try {
      final DocumentReference ref = _collection!.doc(path);
      update = await ref.update(data).then((_) {
        return true;
      }).catchError((Object ex) {
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
    // ignore: avoid_as
    final User user = await (currentUser() as Future<User>);
    data['uid'] = user.uid;
    return _collection!.add(data).then((ref) {
      final List<String> path = ref.path.split('/');
      return path.last;
    }).catchError((Object ex) {
      setError(ex);
      return '';
    });
  }

  Future<bool> delete(String? docId) async {
    if (docId == null || docId.trim().isEmpty) {
      return false;
    }
    bool delete = true;
    try {
      final DocumentReference ref = _collection!.doc(docId);
      delete = await ref.delete().then((_) {
        return true;
      }).catchError((Object ex) {
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
      _store.runTransaction(
          transactionHandler as Future<Map<String, dynamic>> Function(
              Transaction),
          timeout: timeout);

  // ignore: avoid_setters_without_getters
  set ex(Exception ex) => setError(ex);

  Exception setError(Object ex) => getError(ex);

  Exception getError([Object? ex]) {
    Exception? e = _ex;
    if (ex == null) {
      _ex = null;
    } else {
      // ignore: avoid_as
      _ex = ex as Exception;
    }

    /// Return the stored error if any.
    e ??= _ex;
    return e!;
  }
}
