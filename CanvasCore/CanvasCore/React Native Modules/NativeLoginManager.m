//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

#import "NativeLoginManager.h"
#import <React/RCTLog.h>
#import <React/RCTBridge.h>
#import <CanvasCore/CanvasCore-Swift.h>

// Object used to send events to React Native about login
@interface NativeLogin : RCTEventEmitter

@property (nonatomic) BOOL isObserving;
@property (nonatomic) NSMutableDictionary *pendingEvents;

@end

static NativeLogin *_sharedInstance;

@implementation NativeLogin

+ (void)setSharedInstance:(NativeLogin *)login {
    _sharedInstance = login;
}

+ (NativeLogin *)sharedInstance {
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    self.isObserving = NO;
    self.pendingEvents = [NSMutableDictionary new];
    [NativeLogin setSharedInstance:self];
    return self;
}

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
    return @{ @"isTesting": @([NSProcessInfo processInfo].environment[@"IS_UI_TEST"] != nil) };
}

RCT_EXPORT_METHOD(changeUser)
{
    [[NativeLoginManager shared].delegate changeUser];
}

RCT_EXPORT_METHOD(stopActing)
{
    [[NativeLoginManager shared].delegate stopActing];
}

RCT_EXPORT_METHOD(logout)
{
    [[NativeLoginManager shared].delegate logout];
}

RCT_EXPORT_METHOD(actAsFakeStudentWithID:(NSString *)fakeStudentID)
{
    [[NativeLoginManager shared].delegate actAsFakeStudentWithID:fakeStudentID];
}

RCT_EXPORT_METHOD(startObserving)
{
    self.isObserving = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pendingEvents enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL * _Nonnull stop) {
            [self sendEventWithName:key body:obj];
        }];
        [self.pendingEvents removeAllObjects];
    });
}

RCT_EXPORT_METHOD(stopObserving)
{
    self.isObserving = NO;
}

- (dispatch_queue_t)methodQueue { return dispatch_get_main_queue(); }
+ (BOOL)requiresMainQueueSetup { return YES; }
- (NSArray<NSString *> *)supportedEvents { return @[@"Login"]; }

- (void)sendEventWithName:(NSString *)name body:(id)body {
    if (self.isObserving) {
        [super sendEventWithName:name body:body];
    }
    else {
        self.pendingEvents[name] = body;
    }
}

@end

@implementation NativeLoginManager

+ (instancetype)shared {
    static NativeLoginManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NativeLoginManager alloc] init];
    });
    return manager;
}

- (id)init {
    self = [super init];
    return self;
}

- (void)login:(NSDictionary *)body {
    [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:body];
}

- (void)logout {
    [[HelmManager shared] cleanupWithCallback:^{
        [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:@{}];
    }];
}

@end
