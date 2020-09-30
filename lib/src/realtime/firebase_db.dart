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
///          Created  19 Feb 2020
///
///

import 'dart:io' show InternetAddress, SocketException;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/widgets.dart' show AppLifecycleState;

typedef OnceCallback = void Function(DataSnapshot data);

typedef EventCallback = void Function(Event event);

class FireBaseDB {
  factory FireBaseDB.init({
    OnceCallback once,
    EventCallback onChildAdded,
    EventCallback onChildRemoved,
    EventCallback onChildChanged,
    EventCallback onChildMoved,
    EventCallback onValue,
  }) =>
      _this ??= FireBaseDB._(
        once,
        onChildAdded,
        onChildRemoved,
        onChildChanged,
        onChildMoved,
        onValue,
      );

  FireBaseDB._(
    OnceCallback once,
    EventCallback onChildAdded,
    EventCallback onChildRemoved,
    EventCallback onChildChanged,
    EventCallback onChildMoved,
    EventCallback onValue,
  ) {
    _auth = FirebaseAuth.instance;

    _user = _auth.currentUser;

    _db = FirebaseDatabase.instance;

    _dbReference = _db?.reference();

    if (once != null) _onceListeners.add(once);
    if (onChildAdded != null) _addedListeners.add(onChildAdded);
    if (onChildRemoved != null) _removedListeners.add(onChildRemoved);
    if (onChildChanged != null) _changedListeners.add(onChildChanged);
    if (onChildMoved != null) _movedListeners.add(onChildMoved);
    if (onValue != null) _valueListeners.add(onValue);

    // this errors with 'permission denied??'
//    _setEvents(_dbReference);

    _app = _db?.app;
  }
  static FireBaseDB _this;

  Set<OnceCallback> _onceListeners = Set();
  Set<EventCallback> _addedListeners = Set();
  Set<StreamSubscription<Event>> _addedSubscription = Set();
  Set<EventCallback> _removedListeners = Set();
  Set<StreamSubscription<Event>> _removedSubscription = Set();
  Set<EventCallback> _changedListeners = Set();
  Set<StreamSubscription<Event>> _changedSubscription = Set();
  Set<EventCallback> _movedListeners = Set();
  Set<StreamSubscription<Event>> _movedSubscription = Set();
  Set<EventCallback> _valueListeners = Set();
  Set<StreamSubscription<Event>> _valueSubscription = Set();

  dispose() {
    //
    goOffline();
    _db = null;
    _dbReference = null;

    _onceListeners.clear();
    _addedListeners.clear();
    _removedListeners.clear();
    _changedListeners.clear();
    _movedListeners.clear();
    _valueListeners.clear();

    _app = null;

    _addedSubscription.forEach((f) {
      f.cancel();
    });
    _addedSubscription.clear();
    _removedSubscription.forEach((f) {
      f.cancel();
    });
    _removedSubscription.clear();
    _changedSubscription.forEach((f) {
      f.cancel();
    });
    _changedSubscription.clear();
    _movedSubscription.forEach((f) {
      f.cancel();
    });
    _movedSubscription.clear();
    _valueSubscription.forEach((f) {
      f.cancel();
    });
    _valueSubscription.clear();
  }

  Future<bool> isOnline() => Is.online();

  FirebaseAuth _auth;

  User _user;
  User get user => _user;

  FirebaseDatabase _db;
  FirebaseDatabase get db => _db;
  FirebaseDatabase get instance => _db;

  DatabaseReference _dbReference;
  DatabaseReference reference() => _dbReference;

  FirebaseApp _app;
  FirebaseApp get app => _app;

  set onceListener(OnceCallback once) {
    if (once != null) _onceListeners.add(once);
  }

  set addedListener(EventCallback onChildAdded) {
    if (onChildAdded != null) _addedListeners.add(onChildAdded);
  }

  bool onChildAdded(DatabaseReference ref, EventCallback listener) {
    StreamSubscription<Event> sub = ref.onChildAdded.listen((Event event) {
      listener(event);
    }, onError: (error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
      print('done');
    });
    bool added = _addedSubscription.add(sub);
    if (!added) {
      added = _addedSubscription.remove(sub);
      if (added) added = _addedSubscription.add(sub);
    }
    return added;
  }

  set removedListener(EventCallback onChildRemoved) {
    if (onChildRemoved != null) _removedListeners.add(onChildRemoved);
  }

  set changedListener(EventCallback onChildChanged) {
    if (onChildChanged != null) _changedListeners.add(onChildChanged);
  }

  set movedListener(EventCallback onChildMoved) {
    if (onChildMoved != null) _movedListeners.add(onChildMoved);
  }

  set valueListener(EventCallback onValue) {
    if (onValue != null) _valueListeners.add(onValue);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      goOffline();
    } else if (state == AppLifecycleState.resumed) {
      goOnline();
    }
  }

  DatabaseReference dataRef(String name) => _dbReference?.child(name);

  String get databaseURL => _db?.databaseURL ?? 'unknown';

  bool get isPersistenceEnabled => _persistenceEnabled;
  bool _persistenceEnabled;

  Future<bool> setPersistenceEnabled(bool enabled) async {
    _persistenceEnabled = await _db?.setPersistenceEnabled(enabled);

    _persistenceEnabled = _persistenceEnabled ?? false;

    return Future.value(_persistenceEnabled);
  }

  Future<bool> setPersistenceCacheSizeBytes(int cacheSize) =>
      _db?.setPersistenceCacheSizeBytes(cacheSize) ?? Future.value(false);

  Future<FireBaseDB> open() async {
    final online = await isOnline();
    // No internet connection is available.
    if (!online) {
      return this;
    }

    try {
      _db.goOnline();
    } finally {}

    return this;
  }

  void close() {
    _db.goOffline();
  }

  Future<void> goOnline() => _db?.goOnline();

  Future<void> goOffline() => _db?.goOffline();

  Future<void> purgeOutstandingWrites() => _db?.purgeOutstandingWrites();

//  DatabaseReference prevUserIdDBRef(){
//
//    DatabaseReference ref;
//
//    String prevUserId = Auth.getPrevUid();
//
//    if (prevUserId == null || prevUserId.isEmpty()){
//
//      ref = _db.reference().child("tasks").child("dummy");
//    }else{
//
//      ref = _db.reference().child("tasks").child(prevUserId);
//    }
//
//    return ref;
//  }

  Exception _ex;
  String get message => _ex?.toString() ?? "";
  bool get inError => _ex != null;
  bool get hasError => _ex != null;

  void setError(Object ex) {
    if (ex is! Exception) {
      _ex = Exception(ex.toString());
    } else {
      _ex = ex;
    }
  }

  /// Get the last error but clear it.
  Exception getError() {
    Exception ex = _ex;
    _ex = null;
    return ex;
  }

  void _setEvents(DatabaseReference ref) {
    if (ref == null) return;

    ref.once().then((DataSnapshot data) {
      for (OnceCallback listener in _onceListeners) {
        listener(data);
      }
    }).catchError((error) {
      setError(error);
    });

    _addedSubscription.add(ref.onChildAdded.listen((Event event) {
      for (EventCallback listener in _addedListeners) {
        listener(event);
      }
    }, onError: (error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
      print('done');
    }));

    _removedSubscription.add(ref.onChildRemoved.listen((Event event) {
      for (EventCallback listener in _removedListeners) {
        listener(event);
      }
    }, onError: (error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
      print('done');
    }));

    _changedSubscription.add(ref.onChildChanged.listen((Event event) {
      for (EventCallback listener in _changedListeners) {
        listener(event);
      }
    }, onError: (error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
      print('done');
    }));

    _movedSubscription.add(ref.onChildMoved.listen((Event event) {
      for (EventCallback listener in _movedListeners) {
        listener(event);
      }
    }, onError: (error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
      print('done');
    }));

    _valueSubscription.add(ref.onValue.listen((Event event) {
      for (EventCallback listener in _valueListeners) {
        listener(event);
      }
    }, onError: (error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
      print('done');
    }));
  }
}

class Is {
  static Future<bool> online() async {
    bool online;
    try {
      List<InternetAddress> result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        online = true;
      } else {
        online = false;
      }
    } on SocketException catch (_) {
      online = false;
    }
    return online;
  }

  static Future<bool> offline() => online().then((online) {
        return !online;
      });
}
