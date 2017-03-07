//
//  NativeLogin.m
//  Teacher
//
//  Created by Derrick Hathaway on 2/21/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "NativeLogin.h"
#import <React/RCTLog.h>
#import "AppDelegate.h"
#import "RCCManager.h"
#import <React/RCTBridge.h>

@import CanvasKeymaster;
@import CocoaLumberjack;

@interface NativeLogin ()

@property (nonatomic) RACDisposable *loginObserver;
@property (nonatomic) RACDisposable *logoutObserver;
@property(nonatomic) NSMutableDictionary *eventsSent;

@end

@implementation NativeLogin

+ (instancetype)shared {
  static NativeLogin *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[NativeLogin alloc] init];
  });
  return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventsSent = [NSMutableDictionary dictionary];
    }
    return self;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(logout)
{
  self.eventsSent = [NSMutableDictionary dictionary];
  [TheKeymaster logout];
}

RCT_EXPORT_METHOD(startObserving)
{
  self.logoutObserver = [TheKeymaster.signalForLogout subscribeNext:^(UIViewController * _Nullable x) {
    
    [self sendEventWithName:@"Login" body:@{}];
    
    if (x) {
      AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        d.window.rootViewController = x;
      });
    }
  }];
  
  self.loginObserver = [TheKeymaster.signalForLogin subscribeNext:^(CKIClient *client) {

     NSDictionary *body = @{
                            @"authToken": client.accessToken,
                            @"user": client.currentUser.JSONDictionary,
                            @"baseURL": client.baseURL.absoluteString
                            };

    if (!self.eventsSent[client.accessToken]) {
      self.eventsSent[client.accessToken] = body;
      [self sendEventWithName:@"Login" body:body];
    }

  }];
}

RCT_EXPORT_METHOD(stopObserving)
{
  self.eventsSent = [NSMutableDictionary dictionary];
  [self.loginObserver dispose];
  [self.logoutObserver dispose];
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"Login"];
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

@end
