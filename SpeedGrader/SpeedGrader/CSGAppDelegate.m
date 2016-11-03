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
@import Secrets;

#ifdef SNAPSHOT
#import <SDStatusBarManager.h>
#endif

@import PSPDFKit;
@import CocoaLumberjack;

// Crashlytics Keys
static NSString *const CRASHLYTICS_BASE_URL_KEY = @"DOMAIN";
static NSString *const CRASHLYTICS_MASQUERADE_USER_ID_KEY = @"MASQUERADE_AS_USER_ID";

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
    
    [self setupPSPDFKit];
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

- (void)setupPSPDFKit {
    NSString *pspdfKitLicenceKey = [Secrets fetch:SecretKeySpeedGraderPSPDFKit];
    if (pspdfKitLicenceKey) {
        [PSPDFKit setLicenseKey:pspdfKitLicenceKey];
    }
}

- (void)setupCrashlyticsDebugInformation {
    CKIClient *client = TheKeymaster.currentClient;
    
    // We cannot save user data from Simon Fraser University in Canada.
    // Make sure that we are not adding user data to crash reports
    NSString *baseURLString = [client.baseURL absoluteString];
    if (![baseURLString hasSuffix:@"sfu.ca"]) {
        
        CKIUser *user = [client currentUser];
        [[Crashlytics sharedInstance] setObjectValue:client.actAsUserID forKey:CRASHLYTICS_MASQUERADE_USER_ID_KEY];  // Set this at top of file
        [[Crashlytics sharedInstance] setObjectValue:baseURLString forKey:CRASHLYTICS_BASE_URL_KEY];                 // Set this at top of file
        [[Crashlytics sharedInstance] setUserIdentifier:user.id];
    }
}

- (void)setupGoogleAnalytics {
    
    NSString *googleTrackingId = [Secrets fetch:SecretKeySpeedGraderGoogleAnalytics];
    if (googleTrackingId) {
        [[GAI sharedInstance] trackerWithTrackingId:googleTrackingId];
        [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
        [GAI sharedInstance].dispatchInterval = 120; // in seconds
    }
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
