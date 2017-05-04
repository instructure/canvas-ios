//
//  NativeLogin.m
//  Teacher
//
//  Created by Derrick Hathaway on 2/21/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "NativeLoginManager.h"
#import <React/RCTLog.h>
#import "AppDelegate.h"
#import "RCCManager.h"
#import <React/RCTBridge.h>

@import CanvasKeymaster;
@import CocoaLumberjack;

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

RCT_EXPORT_METHOD(logout)
{
  [TheKeymaster logout];
}

RCT_EXPORT_METHOD(startObserving)
{
  self.isObserving = YES;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

- (void)sendEventWithName:(NSString *)name body:(id)body {
  if (self.isObserving) {
    [super sendEventWithName:name body:body];
  }
  else {
    self.pendingEvents[name] = body;
  }
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"Login"];
}

@end

@interface NativeLoginManager ()

@property (nonatomic) NSDictionary *injectedLoginInfo;
@property (nonatomic) RACDisposable *loginObserver;
@property (nonatomic) NSMutableDictionary *eventsSent;

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

- (instancetype)init {
  
  self = [super init];
  if (self) {
    self.eventsSent = [NSMutableDictionary dictionary];
    [self setup];
  }
  return self;
}

- (void)setup {
  [TheKeymaster.signalForLogout subscribeNext:^(UIViewController * _Nullable x) {
    if (self.injectedLoginInfo) { return; }
    
    [self.delegate didLogout:x];
  }];
  
  [TheKeymaster.signalForLogin subscribeNext:^(CKIClient * _Nullable client) {
    if (self.injectedLoginInfo) { return; }
    
    [self.delegate didLogin];
  }];
  
  __weak NativeLoginManager *weakSelf = self;
  self.loginObserver = [[[RACObserve(TheKeymaster, currentClient) subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CKIClient *client) {
    __strong NativeLoginManager *self = weakSelf;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (client == nil) {
        [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:@{}];
        return;
      }
      
      NSDictionary *body = @{
                             @"authToken": client.accessToken,
                             @"user": client.currentUser.JSONDictionary,
                             @"baseURL": client.baseURL.absoluteString,
                             @"branding": client.branding ? client.branding.JSONDictionary : @{},
                             };
      
      if (!self.eventsSent[client.accessToken]) {
        self.eventsSent[client.accessToken] = body;
        [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:body];
      }
    });
  }] asScopedDisposable];
}

#pragma MARK - CanvasKeymasterDelegate

- (NSString *)appNameForMobileVerify {
  return @"iCanvas";
}

- (UIView *)backgroundViewForDomainPicker {
  UIView *bg = [[UIView alloc] init];
  bg.backgroundColor = [UIColor whiteColor];
  return bg;
}

- (UIImage *)logoForDomainPicker {
  return [UIImage imageNamed:@"logo"];
}

- (NSString *)logFilePath {
  NSString *cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:@"InstructureLogs"];
  
  return [[DDLogFileManagerDefault alloc] initWithLogsDirectory:cacheDir].sortedLogFilePaths.firstObject;
}

- (void)injectLoginInformation:(NSDictionary *)info {
  
  self.injectedLoginInfo = info;
  
  if (!info) {
    [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:@{}];
    UIViewController *controller = [UIViewController new];
    [self.delegate didLogout:controller];
  }
  else {
    
    NSString *accessToken = info[@"authToken"];
    NSAssert(accessToken, @"You must provide an access token when injecting login information");
    
    [self.delegate didLogin];
    
    // See the above method called startObserving to understand why we need a delay here
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:info];
    });
  }
}

@end
