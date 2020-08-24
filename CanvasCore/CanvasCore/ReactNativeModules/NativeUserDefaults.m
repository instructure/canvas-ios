//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <CanvasCore/CanvasCore-Swift.h>
@import React;

@interface NativeUserDefaultsReact: RCTEventEmitter
@property (nonatomic, strong) NSObject *token;
@end

@implementation NativeUserDefaultsReact
RCT_EXPORT_MODULE(UserDefaults);

+ (NativeUserDefaultsReact *)sharedInstance {
    static dispatch_once_t onceToken;
    static NativeUserDefaultsReact *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NativeUserDefaultsReact alloc] initActual];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [NativeUserDefaultsReact sharedInstance];
    return self;
}

- (instancetype)initActual {
    self = [super init];
    self.token = [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self sendEventWithName:NSUserDefaultsDidChangeNotification body:nil];
    }];
    return self;
}

- (NSDictionary *)constantsToExport {
    return @{ @"didChangeNotification": NSUserDefaultsDidChangeNotification };
}

RCT_REMAP_METHOD(getShowGradesOnDashboard, resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([NativeUserDefaults showGradesOnDashboard]));
}

- (dispatch_queue_t)methodQueue { return dispatch_get_main_queue(); }
+ (BOOL)requiresMainQueueSetup { return YES; }
- (NSArray<NSString *> *)supportedEvents { return @[NSUserDefaultsDidChangeNotification]; }

@end
