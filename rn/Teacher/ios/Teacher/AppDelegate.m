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
#import "NativeLoginManager.h"

@import CanvasKeymaster;

@interface AppDelegate() <NativeLoginManagerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [BuddyBuildSDK setup];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.rootViewController = [UIViewController new];
  
  [NativeLoginManager shared].delegate = self;
  
  TheKeymaster.fetchesBranding = YES;
  TheKeymaster.delegate = [NativeLoginManager shared];
  
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)didLogin {
  NSURL *jsCodeLocation;
#ifdef DEBUG
  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
#else
  jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
  
  [[RCCManager sharedInstance] initBridgeWithBundleURL:jsCodeLocation launchOptions:nil];
}

- (void)didLogout:(UIViewController *)controller {
  self.window.rootViewController = controller;
}

@end
