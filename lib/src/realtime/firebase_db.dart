// Copyright 2021 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'dart:io' show InternetAddress, SocketException;

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart' show AppLifecycleState;

typedef OnceCallback = void Function(DatabaseEvent event);

typedef EventCallback = void Function(DatabaseEvent event);

class FireBaseDB {
  factory FireBaseDB.init({
    OnceCallback? once,
    EventCallback? onChildAdded,
    EventCallback? onChildRemoved,
    EventCallback? onChildChanged,
    EventCallback? onChildMoved,
    EventCallback? onValue,
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
    OnceCallback? once,
    EventCallback? onChildAdded,
    EventCallback? onChildRemoved,
    EventCallback? onChildChanged,
    EventCallback? onChildMoved,
    EventCallback? onValue,
  ) {
    _auth = FirebaseAuth.instance;

    _user = _auth.currentUser;

    _db = FirebaseDatabase.instance;

    _dbReference = _db?.ref();

    if (once != null) {
      _onceListeners.add(once);
    }
    if (onChildAdded != null) {
      _addedListeners.add(onChildAdded);
    }
    if (onChildRemoved != null) {
      _removedListeners.add(onChildRemoved);
    }
    if (onChildChanged != null) {
      _changedListeners.add(onChildChanged);
    }
    if (onChildMoved != null) {
      _movedListeners.add(onChildMoved);
    }
    if (onValue != null) {
      _valueListeners.add(onValue);
    }

    // this errors with 'permission denied??'
//    _setEvents(_dbReference);

    _app = _db?.app;
  }
  static FireBaseDB? _this;

  final Set<OnceCallback> _onceListeners = {};
  final Set<EventCallback> _addedListeners = {};
  final Set<StreamSubscription<DatabaseEvent>> _addedSubscription = {};
  final Set<EventCallback> _removedListeners = {};
  final Set<StreamSubscription<DatabaseEvent>> _removedSubscription = {};
  final Set<EventCallback> _changedListeners = {};
  final Set<StreamSubscription<DatabaseEvent>> _changedSubscription = {};
  final Set<EventCallback> _movedListeners = {};
  final Set<StreamSubscription<DatabaseEvent>> _movedSubscription = {};
  final Set<EventCallback> _valueListeners = {};
  final Set<StreamSubscription<DatabaseEvent>> _valueSubscription = {};

  void dispose() {
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

    for (final sub in _addedSubscription) {
      sub.cancel();
    }
    _addedSubscription.clear();

    for (final sub in _removedSubscription) {
      sub.cancel();
    }
    _removedSubscription.clear();

    for (final sub in _changedSubscription) {
      sub.cancel();
    }
    _changedSubscription.clear();

    for (final sub in _movedSubscription) {
      sub.cancel();
    }
    _movedSubscription.clear();

    for (final sub in _valueSubscription) {
      sub.cancel();
    }
    _valueSubscription.clear();
  }

  Future<bool> isOnline() => Is.online();

  late FirebaseAuth _auth;

  User? _user;
  User? get user => _user;

  FirebaseDatabase? _db;
  FirebaseDatabase? get db => _db;
  FirebaseDatabase? get instance => _db;

  DatabaseReference? _dbReference;
  DatabaseReference? reference() => _dbReference;

  FirebaseApp? _app;
  FirebaseApp? get app => _app;

  //ignore: avoid_setters_without_getters
  set onceListener(OnceCallback? once) {
    if (once != null) {
      _onceListeners.add(once);
    }
  }

  //ignore: avoid_setters_without_getters
  set addedListener(EventCallback? onChildAdded) {
    if (onChildAdded != null) {
      _addedListeners.add(onChildAdded);
    }
  }

  bool onChildAdded(DatabaseReference ref, EventCallback listener) {
    final StreamSubscription<DatabaseEvent> sub =
        ref.onChildAdded.listen((DatabaseEvent event) {
      listener(event);
    }, onError: (Object error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
//      print('done');
    });
    bool added = _addedSubscription.add(sub);
    if (!added) {
      added = _addedSubscription.remove(sub);
      if (added) {
        added = _addedSubscription.add(sub);
      }
    }
    return added;
  }

  //ignore: avoid_setters_without_getters
  set removedListener(EventCallback? onChildRemoved) {
    if (onChildRemoved != null) {
      _removedListeners.add(onChildRemoved);
    }
  }

  //ignore: avoid_setters_without_getters
  set changedListener(EventCallback? onChildChanged) {
    if (onChildChanged != null) {
      _changedListeners.add(onChildChanged);
    }
  }

  //ignore: avoid_setters_without_getters
  set movedListener(EventCallback? onChildMoved) {
    if (onChildMoved != null) {
      _movedListeners.add(onChildMoved);
    }
  }

  //ignore: avoid_setters_without_getters
  set valueListener(EventCallback? onValue) {
    if (onValue != null) {
      _valueListeners.add(onValue);
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      goOffline();
    } else if (state == AppLifecycleState.resumed) {
      goOnline();
    }
  }

  DatabaseReference? dataRef(String name) => _dbReference?.child(name);

  String get databaseURL => _db?.databaseURL ?? 'unknown';

  bool? get isPersistenceEnabled => _persistenceEnabled;
  bool? _persistenceEnabled;

  //ignore:avoid_positional_boolean_parameters
  bool setPersistenceEnabled(bool enabled) {
    _db?.setPersistenceEnabled(enabled);
    return _persistenceEnabled = enabled;
  }

  void setPersistenceCacheSizeBytes(int cacheSize) =>
      _db?.setPersistenceCacheSizeBytes(cacheSize);

  Future<FireBaseDB> open() async {
    final online = await isOnline();
    // No internet connection is available.
    if (!online) {
      return this;
    }

    try {
      await _db!.goOnline();
    } finally {}

    return this;
  }

  void close() {
    _db!.goOffline();
  }

  Future<void>? goOnline() => _db?.goOnline();

  Future<void>? goOffline() => _db?.goOffline();

  Future<void>? purgeOutstandingWrites() => _db?.purgeOutstandingWrites();

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

  Exception? _ex;
  String get message => _ex?.toString() ?? '';
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
  Exception? getError() {
    final Exception? ex = _ex;
    _ex = null;
    return ex;
  }

  void setEvents(DatabaseReference? ref) {
    if (ref == null) {
      return;
    }
    ref.once().then((DatabaseEvent event) {
      for (final OnceCallback listener in _onceListeners) {
        listener(event);
      }
      //ignore: unnecessary_lambdas
    }).catchError((Object error) {
      setError(error);
    });

    _addedSubscription.add(ref.onChildAdded.listen((DatabaseEvent event) {
      for (final EventCallback listener in _addedListeners) {
        listener(event);
      }
    }, onError: (Object error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
//      print('done');
    }));

    _removedSubscription.add(ref.onChildRemoved.listen((DatabaseEvent event) {
      for (final EventCallback listener in _removedListeners) {
        listener(event);
      }
    }, onError: (Object error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
//      print('done');
    }));

    _changedSubscription.add(ref.onChildChanged.listen((DatabaseEvent event) {
      for (final EventCallback listener in _changedListeners) {
        listener(event);
      }
    }, onError: (Object error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
//      print('done');
    }));

    _movedSubscription.add(ref.onChildMoved.listen((DatabaseEvent event) {
      for (final EventCallback listener in _movedListeners) {
        listener(event);
      }
    }, onError: (Object error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
//      print('done');
    }));

    _valueSubscription.add(ref.onValue.listen((DatabaseEvent event) {
      for (final EventCallback listener in _valueListeners) {
        listener(event);
      }
    }, onError: (Object error, StackTrace stackTrace) {
      setError(error);
    }, onDone: () {
//      print('done');
    }));
  }
}

class Is {
  static Future<bool> online() async {
    bool online;
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('google.com');
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
