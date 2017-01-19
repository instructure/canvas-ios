//
//  CKMAppDelegate.m
//  CanvasKeytester
//
//  Created by Derrick Hathaway on 4/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
