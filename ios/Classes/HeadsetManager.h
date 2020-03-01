//
//  HeadsetManager.h
//  
//
//  Created by Bruce Ying on 2020/2/29.
//
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeadsetManager : NSObject<FlutterStreamHandler>
- (void)addListener;
- (BOOL)hasHeadset;
- (void)setAudioProperty:(BOOL)enableSpeaker;
- (BOOL)switchBluetooth:(BOOL)onOrOff;
- (BOOL)switchSpeaker:(BOOL)onOrOff;
- (BOOL)switchEarphone:(BOOL)onOrOff;
- (instancetype)initWithRegistrar:(id<FlutterPluginRegistrar>)registrar;
@end

NS_ASSUME_NONNULL_END
