//
//  NativeLogin.m
//  Teacher
//
//  Created by Derrick Hathaway on 2/21/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "NativeLogin.h"
#import "RCTLog.h"
@import CanvasKeymaster;
@import CocoaLumberjack;


@implementation NativeLogin

+ (instancetype)shared {
  static NativeLogin *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[NativeLogin alloc] init];
  });
  return instance;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(logout)
{
  [TheKeymaster logout];
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
