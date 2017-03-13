//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CKMAppDelegate.h"
#import <CanvasKeymaster/CanvasKeymaster.h>
@import ReactiveObjC;

@interface CKMAppDelegate () <CanvasKeymasterDelegate, CKMAnalyticsProvider>
@end

@implementation CKMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    [self.window makeKeyAndVisible];
    self.window.tintColor = [UIColor whiteColor];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    
    TheKeymaster.delegate = self;
    TheKeymaster.analyticsProvider = self;
    
    RACSignal *loggedOutUI = TheKeymaster.signalForLogout;
    
    RACSignal *loggedInUI = [TheKeymaster.signalForLogin map:^id(id value) {
        NSLog(@"logging in");
        return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    }];
    
    RAC(self, window.rootViewController) = [RACSignal merge:@[loggedOutUI, loggedInUI]];
    
    return YES;
}

- (UIImage *)logoForDomainPicker
{
    return [UIImage imageNamed:@"CanvasKeymaster"];
}

- (UIView *)backgroundViewForDomainPicker
{
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Unlocked"]];
}

- (NSString *)appNameForMobileVerify
{
    return @"iCanvas";
}

- (NSString *)logFilePath
{
    return nil;
}

- (void)trackScreenView:(NSString *)value
{
    /* If I were using GoogleAnalytics I would do:
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:value];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createScreenView] build]];
    */
}

@end
