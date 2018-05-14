//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "NativeLoginManager.h"
#import <React/RCTLog.h>
#import <React/RCTBridge.h>
#import <CanvasCore/CanvasCore-Swift.h>

@import CanvasKeymaster;
@import CocoaLumberjack;

CanvasApp _Nonnull CanvasAppStudent = @"student";
CanvasApp _Nonnull CanvasAppTeacher = @"teacher";
CanvasApp _Nonnull CanvasAppParent = @"parent";

@interface NativeLoginManager ()

@property (nonatomic) NSDictionary *injectedLoginInfo;
@property (nonatomic) RACDisposable *loginObserver;
@property (nonatomic) RACDisposable *logoutObserver;
@property (nonatomic) RACDisposable *multipleLoginObserver;
@property (nonatomic) RACDisposable *clientObserver;
@property (nonatomic) UIViewController *domainPicker;
@property (nonatomic) CKIClient *currentClient;
@property (nonatomic) BOOL shouldCleanupOnNextLogoutEvent;

- (void)setup;

@end

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
    
    // Each time one of these gets created, we need to re-setup the observing of keymaster stuff
    // Otherwise, the right events don't get triggered
    [[NativeLoginManager shared] setup];
    return self;
}

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
    return @{ @"isTesting": @(NSClassFromString(@"EarlGreyImpl") != nil) };
}

RCT_EXPORT_METHOD(logout)
{
    [[NativeLoginManager shared] setShouldCleanupOnNextLogoutEvent:YES];
    [TheKeymaster logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasqueradeDidEnd" object:nil];
}

RCT_EXPORT_METHOD(switchUser)
{
    [[NativeLoginManager shared] setShouldCleanupOnNextLogoutEvent:YES];
    [TheKeymaster switchUser];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasqueradeDidEnd" object:nil];
}

RCT_EXPORT_METHOD(masquerade:(NSString *)userID domain:(NSString *)domain resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[NativeLoginManager shared] setShouldCleanupOnNextLogoutEvent:YES];
    [[TheKeymaster masqueradeAsUserWithID:userID domain:domain] subscribeNext:^(CKIUser *user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            resolve(user.JSONDictionary);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MasqueradeDidStart" object:nil];
        });
    } error:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *code = [@(error.code) stringValue];
            reject(code, error.localizedDescription, nil);
        });
    }];
}

RCT_EXPORT_METHOD(stopMasquerade)
{
    [[NativeLoginManager shared] setShouldCleanupOnNextLogoutEvent:YES];
    [TheKeymaster stopMasquerading];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasqueradeDidEnd" object:nil];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(loginInformation)
{
    NSDictionary *injected = [[NativeLoginManager shared] injectedLoginInfo];
    if (injected) {
        return injected;
    }
    
    // I imagine that we can extend this to checking keymaster in a synchronous way,
    // which would improve app startup time
    return nil;
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

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
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

@implementation NativeLoginManager

+ (instancetype)shared {
    static NativeLoginManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NativeLoginManager alloc] init];
        manager.app = CanvasAppTeacher; // default to teacher app
    });
    return manager;
}

- (id)init {
    self = [super init];
    self.shouldCleanupOnNextLogoutEvent = NO;
    return self;
}

- (void)setup {
    BOOL uiTesting = NSClassFromString(@"EarlGreyImpl") != nil;
    self.shouldCleanupOnNextLogoutEvent = uiTesting; // UI tests always clean up on logout
    [self.logoutObserver dispose];
    [self.loginObserver dispose];
    [self.clientObserver dispose];
    [self.multipleLoginObserver dispose];
    
    @weakify(self);
    void (^logoutHandler)(UIViewController *) = ^void(UIViewController * _Nullable x) {
        @strongify(self);
        self.domainPicker = x;

        if (self.shouldCleanupOnNextLogoutEvent) {
            [[HelmManager shared] cleanupWithCallback:^{
                if (!self.injectedLoginInfo) {
                    [self.delegate didLogout:x];
                    [self sendLoginEvent:nil];
                }
            }];
            self.shouldCleanupOnNextLogoutEvent = NO;
        } else {
            [self.delegate didLogout:x];
            [self sendLoginEvent:nil];
        }
    };
    
    self.logoutObserver = [TheKeymaster.signalForLogout subscribeNext:logoutHandler];
    self.multipleLoginObserver = [TheKeymaster.signalForCannotLoginAutomatically subscribeNext:logoutHandler];
    
    self.loginObserver = [TheKeymaster.signalForLogin subscribeNext:^(CKIClient * _Nullable client) {
        @strongify(self);
        if (self.injectedLoginInfo) { return; }
        
        [self.delegate didLogin:client];
        [self sendLoginEvent:client];
    } error:^(NSError * _Nullable error) {
        // I'm not sure what would cause this to error, but in the case the login signal explodes, force a logout
        [CanvasKeymaster.theKeymaster logout];
    }];
}

- (void) sendLoginEvent:(CKIClient*) client {
    if (client == nil) {
        [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:@{}];
        return;
    }
    
    NSLocale* locale = [NSLocale currentLocale];
    NSDictionary *body = @{
                           @"appId": self.app,
                           @"authToken": client.accessToken,
                           @"user": client.currentUser.JSONDictionary,
                           @"baseURL": client.baseURL.absoluteString,
                           @"branding": client.branding ? [client.branding JSONDictionary] : @{},
                           @"actAsUserID": client.actAsUserID ?: [NSNull null],
                           @"countryCode": [locale countryCode] ?: @"",
                           };
    
    [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:body];
}

#pragma MARK - CanvasKeymasterDelegate

- (void)injectLoginInformation:(NSDictionary *)info {
    if (!info) {
        if (self.injectedLoginInfo) {
            self.injectedLoginInfo = nil;
            [[[HelmManager shared] bridge] reload];
        }
    }
    else {
        NSMutableDictionary *mutableInfo = [info mutableCopy];
        mutableInfo[@"skipHydrate"] = @YES;
        mutableInfo[@"appId"] = self.app;
        self.injectedLoginInfo = mutableInfo;
        
        NSString *accessToken = info[@"authToken"];
        NSAssert(accessToken, @"You must provide an access token when injecting login information");
        NSDictionary *userDictionary = info[@"user"];
        NSAssert(userDictionary, @"You must provide a user when injecting login information");
        CKIUser *user = [CKIUser modelFromJSONDictionary:userDictionary];
        NSAssert(user, @"You must provide a user when injecting login information");
        NSString *baseURL = info[@"baseURL"];
        NSAssert(baseURL, @"You must provide a base url when injecting login information");
        
        CKIClient *client = [[CKIClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        [client setValue:accessToken forKey:@"accessToken"];
        [client setValue:user forKey:@"currentUser"];
        self.currentClient = client;
        [[CanvasKeymaster theKeymaster] setValue:client forKey:@"currentClient"];
        [self.delegate didLogin:client];
        [[[HelmManager shared] bridge] reload];
    }
}

- (void)stopMasquerding {
    [[NativeLogin sharedInstance] stopMasquerade];
}

@end
