/* This program is free software. It comes without any warranty, to
     * the extent permitted by applicable law. You can redistribute it
     * and/or modify it under the terms of the Do What The Fuck You Want
     * To Public License, Version 2, as published by Sam Hocevar. See
     * http://www.wtfpl.net/ for more details. */
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterNearbyMessages {
  static const MethodChannel _channel =
  const MethodChannel('flutter_nearby_messages');

  static NearbyMessageCallback _onFound;
  static NearbyMessageCallback _onLost;

  static Future<dynamic> setApiKey(String key) async =>
    await _channel.invokeMethod("apikey", key);

  static var _isListening = false;

  static Future<dynamic> subscribe({NearbyMessageCallback onFound, NearbyMessageCallback onLost}) async {
    _onFound = onFound;
    _onLost = onLost;
    if (!_isListening) {
      _channel.setMethodCallHandler((mc) {
        if (mc.method == "found") {
          if (_onFound != null)
            _onFound(mc.arguments);
        } else if (mc.method == "lost") {
          if (_onLost != null)
            _onLost(mc.arguments);
        }
      });
      _isListening = true;
    }
    return await _channel.invokeMethod("subscribe");
  }

  static unsubscribe() async {
    _onFound = null;
    _onLost = null;
    await _channel.invokeMethod("unsubscribe");
  }

  static Future<dynamic> publish(String msg) async =>
    await _channel.invokeMethod("publish", msg);

  static Future<dynamic> unpublish() async =>
    await _channel.invokeMethod("unpublish");
}

typedef void NearbyMessageCallback(String message);