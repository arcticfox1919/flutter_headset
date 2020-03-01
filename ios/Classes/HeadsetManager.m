//
//  HeadsetManager.m
//  
//
//  Created by Bruce Ying on 2020/2/29.
//

#import <AVFoundation/AVFoundation.h>
#import "HeadsetManager.h"
#import "QueuingEventSink.h"

@implementation HeadsetManager{
  QueuingEventSink *_eventSink;
  FlutterEventChannel *_eventChannel;
}

- (instancetype)initWithRegistrar:(id<FlutterPluginRegistrar>)registrar {
    self = [super init];
    if (self) {
        _eventSink = [QueuingEventSink new];
        _eventChannel = [FlutterEventChannel
            eventChannelWithName:@"arcticfox.com/flutter_headset/event" binaryMessenger:[registrar messenger]];

        [_eventChannel setStreamHandler:self];
    }
    return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:
                                           (nonnull FlutterEventSink)events {
    [_eventSink setDelegate:events];
    return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
    [_eventSink setDelegate:nil];
    return nil;
}


- (AVAudioSessionPortDescription*)bluetoothAudioDevice
{
    NSArray* bluetoothRoutes = @[AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP];
    return [self audioDeviceFromTypes:bluetoothRoutes];
}

- (AVAudioSessionPortDescription*)builtinAudioDevice
{
    NSArray* builtinRoutes = @[AVAudioSessionPortBuiltInMic];
    return [self audioDeviceFromTypes:builtinRoutes];
}

- (AVAudioSessionPortDescription*)speakerAudioDevice
{
    NSArray* builtinRoutes = @[AVAudioSessionPortBuiltInSpeaker];
    return [self audioDeviceFromTypes:builtinRoutes];
}

- (AVAudioSessionPortDescription*)audioDeviceFromTypes:(NSArray*)types
{
    NSArray* routes = [[AVAudioSession sharedInstance] availableInputs];
    for(AVAudioSessionPortDescription* route in routes){
        if([types containsObject:route.portType]){
            return route;
        }
    }
    return nil;
}

- (BOOL)switchBluetooth:(BOOL)onOrOff
{
    NSError* audioError = nil;
    BOOL changeResult = NO;
    if (onOrOff == YES){
        AVAudioSessionPortDescription* _bluetoothPort = [self bluetoothAudioDevice];
        changeResult = [[AVAudioSession sharedInstance] setPreferredInput:_bluetoothPort
                                                     error:&audioError];
    }else{
        AVAudioSessionPortDescription* builtinPort = [self builtinAudioDevice];
        changeResult = [[AVAudioSession sharedInstance] setPreferredInput:builtinPort
                                                     error:&audioError];
    }
    return changeResult;
}

- (BOOL)switchSpeaker:(BOOL)onOrOff
{
    NSError* audioError = nil;
    BOOL changeResult = NO;
    if (onOrOff == YES){
        changeResult = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                                                   error:&audioError];
    }else{
        AVAudioSessionPortDescription* builtinPort = [self builtinAudioDevice];
        changeResult = [[AVAudioSession sharedInstance] setPreferredInput:builtinPort
                                                                   error:&audioError];
    }
    return changeResult;
}

- (BOOL)switchEarphone:(BOOL)onOrOff
{
    return [self switchSpeaker:!onOrOff];
}

- (void)addListener
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputDeviceChanged:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)outputDeviceChanged:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
        NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        NSDictionary *dict;
        switch (routeChangeReason) {
            case AVAudioSessionRouteChangeReasonNewDeviceAvailable:  // 耳机插入
                // [self setAudioProperty:NO];
                dict = @{@"headset_available":[NSNumber numberWithBool:YES]};
                [_eventSink success:dict];
                break;
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:  // 耳机拔出
                // [self setAudioProperty:YES];
                dict = @{@"headset_available":[NSNumber numberWithBool:NO]};
                [_eventSink success:dict];
                break;
            case AVAudioSessionRouteChangeReasonCategoryChange:
                // called at start - also when other audio wants to play
                NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
                break;
        }
}

- (void)setAudioProperty:(BOOL)enableSpeaker
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;

    if(enableSpeaker){
        if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker error:&error]){
            NSLog(@"AudioSession set mode error %@", error);
        }
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    }else{
        if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP | AVAudioSessionCategoryOptionMixWithOthers error:&error]){
            NSLog(@"AudioSession set mode error %@", error);
        }
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    }
}


/**
 *  判断是否有耳机
 *
 *  @return 判断是否有耳机
 */
- (BOOL)hasHeadset {
      AVAudioSession *audioSession = [AVAudioSession sharedInstance];

      AVAudioSessionRouteDescription *currentRoute = [audioSession currentRoute];

      for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
            if ([[output portType] isEqualToString:AVAudioSessionPortHeadphones]
                || [[output portType] isEqualToString:AVAudioSessionPortBluetoothLE]
                || [[output portType] isEqualToString:AVAudioSessionPortBluetoothA2DP]
                || [[output portType] isEqualToString:AVAudioSessionPortBluetoothHFP]) {
                  return YES;
            }
      }
      return NO;
}
@end
