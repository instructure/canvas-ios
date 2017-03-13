/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <BuddyBuildSDK/BuddyBuildSDK.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "RCCManager.h"
#import "NativeLogin.h"

@import CanvasKeymaster;

@interface AppDelegate()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [BuddyBuildSDK setup];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.rootViewController = [UIViewController new];
  
  TheKeymaster.delegate = [NativeLogin shared];
  
  [TheKeymaster.signalForLogout subscribeNext:^(UIViewController * _Nullable x) {
    self.window.rootViewController = x;
  }];
  
  [TheKeymaster.signalForLogin subscribeNext:^(CKIClient * _Nullable client) {
    NSURL *jsCodeLocation;
#ifdef DEBUG
    jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
#else
    jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif

    [[RCCManager sharedInstance] initBridgeWithBundleURL:jsCodeLocation launchOptions:launchOptions];
  }];
  
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
