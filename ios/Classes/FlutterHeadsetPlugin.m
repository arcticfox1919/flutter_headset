#import "FlutterHeadsetPlugin.h"
#import "HeadsetManager.h"

@implementation FlutterHeadsetPlugin{
    HeadsetManager* headsetManager;
    NSObject<FlutterPluginRegistrar> *_registrar;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"arcticfox.com/flutter_headset"
            binaryMessenger:[registrar messenger]];
  FlutterHeadsetPlugin* instance = [[FlutterHeadsetPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:
    (NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        _registrar = registrar;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *args = call.arguments;
    BOOL enabled = [args[@"onOrOff"] boolValue];
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if ([@"init" isEqualToString:call.method]){
    if (headsetManager == nil) {
      headsetManager = [[HeadsetManager alloc] initWithRegistrar:_registrar];
      [headsetManager addListener];
    }
    result(nil);
  }else if ([@"hasHeadset" isEqualToString:call.method]){
    BOOL r = [headsetManager hasHeadset];
    result([NSNumber numberWithBool:r]);
  }else if ([@"setAudioProperty" isEqualToString:call.method]){
    [headsetManager setAudioProperty:enabled];
    result(nil);
  }else if ([@"switchBluetooth" isEqualToString:call.method]){
      BOOL r = [headsetManager switchBluetooth:enabled];
    result([NSNumber numberWithBool:r]);
  }else if ([@"switchSpeaker" isEqualToString:call.method]){
    BOOL r = [headsetManager switchBluetooth:enabled];
    result([NSNumber numberWithBool:r]);
  }else if ([@"switchEarphone" isEqualToString:call.method]){
    BOOL r = [headsetManager switchBluetooth:enabled];
    result([NSNumber numberWithBool:r]);
  }else if ([@"dispose" isEqualToString:call.method]){
    result(nil);
  }else {
    result(FlutterMethodNotImplemented);
  }
}

@end
