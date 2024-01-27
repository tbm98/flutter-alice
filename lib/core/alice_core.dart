import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_error.dart';
import 'package:flutter_alice/model/alice_http_response.dart';
import 'package:flutter_alice/ui/page/alice_calls_list_screen.dart';
import 'package:rxdart/rxdart.dart';

class AliceCore {
  /// Should user be notified with notification if there's new request catched
  /// by Alice

  /// Should inspector use dark theme
  final bool darkTheme;

  /// Rx subject which contains all intercepted http calls
  final BehaviorSubject<List<AliceHttpCall>> callsSubject = BehaviorSubject.seeded([]);

  Brightness _brightness = Brightness.light;
  StreamSubscription? _callsSubscription;

  static AliceCore? _singleton;

  factory AliceCore(darkTheme) {
    _singleton ??= AliceCore._(darkTheme);
    return _singleton!;
  }

  /// Creates alice core instance
  AliceCore._(this.darkTheme) {
    _brightness = darkTheme ? Brightness.dark : Brightness.light;
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    callsSubject.close();
    //_shakeDetector?.stopListening();
    _callsSubscription?.cancel();
  }

  /// Get currently used brightness
  Brightness get brightness => _brightness;

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.

  BuildContext? context;

  BuildContext? getContext() {
    return context;
  }

  void show(BuildContext context) {
    this.context = context;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AliceCallsListScreen(this),
      ),
    );
  }

  /// Add alice http call to calls subject
  void addCall(AliceHttpCall call) {
    callsSubject.add([call, ...callsSubject.value]);
  }

  /// Add error to exisng alice http call
  void addError(AliceHttpError error, int requestId) {
    AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  /// Add response to existing alice http call
  void addResponse(AliceHttpResponse response, int requestId) {
    AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }
    selectedCall.loading = false;
    selectedCall.response = response;
    selectedCall.duration =
        response.time.millisecondsSinceEpoch - selectedCall.request!.time.millisecondsSinceEpoch;

    callsSubject.add([...callsSubject.value]);
  }

  /// Add alice http call to calls subject
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    callsSubject.add([...callsSubject.value, aliceHttpCall]);
  }

  /// Remove all calls from calls subject
  void removeCalls() {
    callsSubject.add([]);
  }

  AliceHttpCall? _selectCall(int requestId) =>
      callsSubject.value.firstWhereOrNull((call) => call.id == requestId);
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
