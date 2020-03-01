import 'dart:async';

import 'package:flutter/services.dart';

class FlutterHeadset {
  static const MethodChannel _channel =
      const MethodChannel('arcticfox.com/flutter_headset');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<HeadsetController> createHeadsetController({HeadsetAvailable availableCallback}) async {
    await _channel.invokeMethod('init');
    return HeadsetController._(availableCallback);
  }
}

typedef HeadsetAvailable = void Function(bool);

class HeadsetController{
  bool _isDisposed = false;
  StreamSubscription _eventSubscription;
  HeadsetAvailable headsetAvailableCallback;

  HeadsetController._(this.headsetAvailableCallback){
    _eventSubscription =
        EventChannel("arcticfox.com/flutter_headset/event")
            .receiveBroadcastStream()
            .listen(_eventHandler, onError: _errorHandler);
  }

  Future<bool> get hasHeadset async {
    return await FlutterHeadset._channel.invokeMethod('hasHeadset');
  }

  Future<void> setAudioProperty(bool enableSpeaker) async {
    await FlutterHeadset._channel.invokeMethod('setAudioProperty');
  }

  Future<bool> switchBluetooth(bool enable) async {
    return await FlutterHeadset._channel.invokeMethod('switchBluetooth',{"onOrOff":enable});
  }

  Future<bool> switchSpeaker(bool enable) async {
    return await FlutterHeadset._channel.invokeMethod('switchSpeaker',{"onOrOff":enable});
  }

  Future<bool> switchEarphone(bool enable) async {
    return await FlutterHeadset._channel.invokeMethod('switchEarphone',{"onOrOff":enable});
  }

  void dispose(){
    if(!_isDisposed){
      _isDisposed = true;
      _eventSubscription?.cancel();
    }
  }

  _eventHandler(event) {
    if(event == null) return;
    final Map<dynamic, dynamic> map = event;
    print("= headset_available state = ${map.toString()}");
    if(headsetAvailableCallback !=null){
      bool val = map["headset_available"];
      headsetAvailableCallback(val);
    }
  }

  _errorHandler(error) {}
}