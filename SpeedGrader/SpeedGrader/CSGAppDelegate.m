//
//  CSGAppDelegate.m
//  SpeedGrader
//
//  Created by Jason Larsen on 4/28/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <GoogleAnalytics/GAI.h>
#import "UIColor+Canvas.h"

#import "CSGToaster.h"
#import "CSGAppDelegate.h"
#import "CSGKeymasterDelegate.h"
#import "CSGCourseViewController.h"
#import "CSGSlideMenuViewController.h"
#import "CSGNotificationPermissionHandler.h"

#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "CSGLogger.h"
#import "CSGLogFormatter.h"
#import "Router.h"

@import CocoaLumberjack;

#ifdef SNAPSHOT
#import <SDStatusBarManager.h>
#endif

@import PSPDFKit;
@import CocoaLumberjack;

// Crashlytics Keys
static NSString *const CRASHLYTICS_AGENT_KEY = @"7cf76817b5c71690f9c8655cc366155508371fc6";
static NSString *const CRASHLYTICS_BASE_URL_KEY = @"DOMAIN";
static NSString *const CRASHLYTICS_MASQUERADE_USER_ID_KEY = @"MASQUERADE_AS_USER_ID";

// Google Analytics Keys
static NSString *const GOOGLE_ANALYTICS_APP_ID = @"UA-37592364-3";

@implementation CSGAppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[url scheme] isEqualToString:@"canvas-speedgrader"]) {
        [self openCanvasURL:url];
        return YES;
    }
    
    return NO;
}

- (void)openCanvasURL:(NSURL *)url {
    RACSignal *clientFromSuggestedDomain = [TheKeymaster signalForLoginWithDomain:url.host];
    
    [clientFromSuggestedDomain subscribeNext:^(CKIClient *client) {
        Router *router = [Router sharedRouter];
        [router routeFromController:self.window.rootViewController toURL:url];
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[NSUserDefaults standardUserDefaults] registerDefaults:@{}];
    [CSGUserPrefsKeys registerDefaults];
    
#if SNAPSHOT
    [[SDStatusBarManager sharedInstance] enableOverrides];
#endif
    
    [PSPDFKit setLicenseKey:@"x3KSCrOk6TpFYgRQ2qZ6dthhmekvQ43Huc65mgNxZEd/ARwoKUwl/9cTL0Dt"
                             "c0ilxJs6cq2asWom/vswjAA8ftsiuNchhy3n3UGrLln7ycJSqxxvWpNMsAJ8"
                             "fZDD7WrphgZE5iCd2OLBTvgUX1zsK6K8UXsacan6D/Ws9SCZhbF8Pke9zrAK"
                             "I83ZCCd2gFvjFVwumNJR69xWTQetOk9RKmHKFKGxpaA0qcsHG3S+d62xoU9w"
                             "/OMfevBs4tT6CABzkCc7LbxBTmmj/tbdTvLdXaRyTaZS6kkrgxYjGmt8Tl3a"
                             "FLV5t8Yg2UIrRkHIO1eNTQNEWa3eQDXhIZpSdCwVhil0nNJjdyJFJDok2Cdp"
                             "+8jNZEkY3NXzA1v4Xpo8Alza7MOj0xz5RvoAF+cW1TVvtCe5aX9CNc5FZ7Uw"
                             "w4Lw4dEXw9+RuB8Jg3IYzlg5QhOhVGf8gQ5XNtZjZ1f2GjKwAlMjU3YPjzjn"
                             "HuETRbngPrNvihc0VAIqY1qYC3rTq9M068Pvc9+4weSJmNmrYpUIElTBn6fP"
                             "YdgAwK8lJ3cLPOj0LJLrrrb1f9PxrbT7lY/8"];
    
    [self setupGoogleAnalytics];
    [self styleUIElements];
    [self setupLogging];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.window makeKeyAndVisible];

    TheKeymaster.delegate = [CSGKeymasterDelegate new];
    [self setupLogin];
    
    [self setupCrashlytics];

    __block CWStatusBarNotification *notification;
    CSGToaster *toaster = [CSGToaster new];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
            notification = [toaster statusBarToast:NSLocalizedString(@"Please check your internet connection if you are having issues", @"No internet warning") Color:[UIColor cbi_red]];
        } else {
            if (notification) {
                 [notification dismissNotification];
            }
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)styleUIElements
{
    [[UISwitch appearance] setTintColor:[UIColor csg_settingsSwitchOffColor]];
    [[UISwitch appearance] setOnTintColor:[UIColor csg_settingsSwitchOnColor]];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

- (void)setupCrashlytics
{
    [Fabric with:@[CrashlyticsKit]];
}

- (void)setupCrashlyticsDebugInformation {
    CKIClient *client = TheKeymaster.currentClient;
    
    // We cannot save user data from Simon Fraser University in Canada.
    // Make sure that we are not adding user data to crash reports
    NSString *baseURLString = [client.baseURL absoluteString];
    if (![baseURLString hasSuffix:@"sfu.ca"]) {
        CKIUser *user = [client currentUser];
        
        [[Crashlytics sharedInstance] setUserName:user.name];
        [[Crashlytics sharedInstance] setUserEmail:user.email];
        [[Crashlytics sharedInstance] setObjectValue:client.actAsUserID forKey:CRASHLYTICS_MASQUERADE_USER_ID_KEY];  // Set this at top of file
        [[Crashlytics sharedInstance] setObjectValue:baseURLString forKey:CRASHLYTICS_BASE_URL_KEY];                 // Set this at top of file
        [[Crashlytics sharedInstance] setUserIdentifier:user.id];
    }
}

- (void)setupGoogleAnalytics {
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-37592364-3"];        // Set this at top of file
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    [GAI sharedInstance].dispatchInterval = 120; // in seconds
}

- (void)setupLogging
{
    // Set up DDLog :)
    CSGLogFormatter *formatter = [CSGLogFormatter new];
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    [[CSGLogger sharedInstance] setLogFormatter:formatter];

    // only log errors marked as debug to xcode console so our logging doesn't drive us insane
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelWarning];
    [DDLog addLogger:[CSGLogger sharedInstance] withLevel:DDLogLevelInfo];
    
    // add a file logger
    NSString *logDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"InstructureLog"];
    self.logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logDirectory];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setLogFormatter:formatter];
    fileLogger = [[DDFileLogger alloc] initWithLogFileManager:self.logFileManager];
    fileLogger.rollingFrequency = 0;            // disable time based rolling
    fileLogger.maximumFileSize = 1024 * 100;    // 100KB;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 1;  // only need one file
    [DDLog addLogger:fileLogger withLevel:DDLogLevelInfo];
}

- (void)setupLogin
{
    RACSignal *loginSignal = [TheKeymaster.signalForLogin map:^id(CKIClient *client) {
        [CSGNotificationPermissionHandler checkPermissions];
        NSString *baseURLString = [client.baseURL absoluteString];
        CKIUser *user = [client currentUser];
        DDLogInfo(@"--------------\n\nBaseURL: %@\n\n New User Session: %@", baseURLString, user.id);
        
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
        // setup user crashlytics information
        [self setupCrashlyticsDebugInformation];
        
        // create initial view controller and display it
        CSGSlideMenuViewController *courseCollectionViewController = [CSGSlideMenuViewController instantiateFromStoryboard];
        return courseCollectionViewController;
    }];
    
    RACSignal *logoutSignal = [TheKeymaster.signalForLogout map:^id(UIViewController *loginPageViewController) {
        
        DDLogInfo(@"End User Session\n\n--------------\n--------------");
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        return loginPageViewController;
    }];
    
    RAC(self, window.rootViewController) = [RACSignal merge:@[logoutSignal, loginSignal]]; // order of these signals matters
}

- (NSString *)sqliteDBNameForCurrentUser
{
    return [NSString stringWithFormat:@"%@-%@", TheKeymaster.currentClient.baseURL.host, TheKeymaster.currentClient.currentUser.id];
}

@end
