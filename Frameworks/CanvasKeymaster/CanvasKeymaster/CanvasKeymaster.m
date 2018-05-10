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

#import "CanvasKeymaster.h"
#import <objc/runtime.h>
#import "FXKeychain+CKMKeyChain.h"
#import "UIDevice+CKMHardware.h"
#import "UIAlertController+Show.h"
@import ReactiveObjC;

#pragma mark - Mobile Verify

NS_ENUM(NSInteger , CBIMobileVerifyResult) {
    CBIMobileVerifyResultSuccess = 0,
    CBIMobileVerifyResultOther = 1, // generic "you aren't authorized cuz i said so"
    CBIMobileVerifyResultBadSite = 2, // params['domain'] isn't authorized for mobile apps
    CBIMobileVerifyResultBadUserAgent = 3 // the user agent given wasn't recognized
};

static NSString * const CBIMobileVerifyAPIKeyName = @"api_key";
static NSString * const CBIMobileVerifyAuthorizedName = @"authorized";
static NSString * const CBIMobileVerifyBaseURLName = @"base_url";
static NSString * const CBIMobileVerifyAPIClientIDName = @"client_id";
static NSString * const CBIMobileVerifyAPIClientSecretName = @"client_secret";
static NSString * const CBIMobileVerifyResultName = @"result";

static NSString *const DELETE_EXTRA_CLIENTS_USER_PREFS_KEY = @"delete_extra_clients";

@interface CanvasKeymaster ()

@property (nonatomic, strong) CKMDomainPickerViewController *domainPicker;
@property (nonatomic, strong) UINavigationController *domainPickerNavigationController;

@end

@implementation CanvasKeymaster {
    RACSubject *_subjectForClientLogout, *_subjectForClientLogin, *_subjectForClientCannotLogInAutomatically;
    CKIClient *_currentClient;
    dispatch_once_t _once;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _subjectForClientLogin = [RACSubject new];
        _subjectForClientLogout = [RACSubject new];
        _subjectForClientCannotLogInAutomatically = [RACSubject new];
        self.fetchesBranding = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenExpired:) name:CKIClientAccessTokenExpiredNotification object:nil];
    }
    return self;
}

+ (instancetype)theKeymaster
{
    static CanvasKeymaster *keymaster;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keymaster = [CanvasKeymaster new];
        [keymaster removeExtraClientsIfNecessary];
    });
    return keymaster;
}

#pragma mark - Creating/Loading Clients

- (CKIClient *)clientFromKeychain
{
    FXKeychain *keychain = [FXKeychain sharedKeychain];
    NSArray *clients = [keychain clients];
    // if we only have 1 client, lets log them in automatically
    if (clients.count == 1) {
        return clients.firstObject;
    }
    
    // if we have more than one client, let the user decide which to use
    return nil;
}

- (RACSignal *)clientForMobileVerifiedDomain:(CKIAccountDomain *)accountDomain
{
    @weakify(self)
    return [[self mobileVerify:[self domainify:accountDomain.domain]] map:^id(NSDictionary *mobileVerifyDetails) {
        @strongify(self)
        return [self clientWithMobileVerifiedDetails:mobileVerifyDetails accountDomain:accountDomain];
    }];
}

- (CKIClient *)clientWithMobileVerifiedDetails:(NSDictionary *)details accountDomain:(CKIAccountDomain *)domain {
    NSString *clientID = details[CBIMobileVerifyAPIClientIDName];
    NSString *clientSecret = details[CBIMobileVerifyAPIClientSecretName];
    NSString *baseURLString = details[CBIMobileVerifyBaseURLName];
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
    CKIClient *client = [CKIClient clientWithBaseURL:baseURL clientID:clientID clientSecret:clientSecret authenticationProvider:domain.authenticationProvider];
    [client.requestSerializer setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    return client;
}

- (void)loginWithMobileVerifyDetails:(NSDictionary *)details {
    CKIClient *client = [self clientWithMobileVerifiedDetails:details accountDomain:nil];
    [[client login] subscribeNext:^(CKIClient *currentClient) {
        [self setCurrentClient:currentClient];
        [[FXKeychain sharedKeychain] addClient:currentClient];
        [_subjectForClientLogin sendNext:currentClient];
    } error:^(NSError *error) {
        [self login];
    }];
}

#pragma mark - Client Management

- (void)accessTokenExpired:(NSNotification *)note
{
    NSString *message = NSLocalizedString(@"Your login has expired or has been removed by the server. Please log in again.", @"when the access token has been revoked");
    NSString *dismissButtonTitle = NSLocalizedString(@"Dismiss", @"Dismiss login expired/revoked alert button");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:dismissButtonTitle style:UIAlertActionStyleDefault handler:nil]];
    [alert show];
    [self logout];
}

- (nullable CKIClient *)currentClient
{
    return _currentClient;
}

- (void)setCurrentClient:(CKIClient *)client
{
    @synchronized(self) {
        [_currentClient invalidateSessionCancelingTasks:YES];
        _currentClient = client;
    }
}

- (NSInteger)numberOfClients
{
    return [[FXKeychain sharedKeychain] clients].count;
}

- (void)removeExtraClientsIfNecessary {
    // Previously we were saving a new client in the keychain each time the app was open.
    // We are removing all clients that are not needed.
    // This code can be removed after we are confident all users have run it one time... or most users...
    BOOL hasDeletedExtraClients = [[NSUserDefaults standardUserDefaults] boolForKey:DELETE_EXTRA_CLIENTS_USER_PREFS_KEY];
    if (!hasDeletedExtraClients) {
        NSMutableDictionary *deletedClients = [@{} mutableCopy];
        [[[FXKeychain sharedKeychain] clients] enumerateObjectsUsingBlock:^(CKIClient *client, NSUInteger idx, BOOL *stop) {
            if ([deletedClients objectForKey:client.accessToken]) {
                [[FXKeychain sharedKeychain] removeClient:client];        // removes all clients with same access token
                [[FXKeychain sharedKeychain] addClient:client];           // adds a single client back
            }
            else if (client.accessToken != nil) {
                [deletedClients setObject:client forKey:client.accessToken];
            }
        }];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DELETE_EXTRA_CLIENTS_USER_PREFS_KEY];
    }
}

#pragma mark - Mobile Verify

/**
 Reaches out to mobile_verify, which gives us all the details on whatever domain
 that is allowed to use the mobile app. Questionable security here...
 */
- (RACSignal *)mobileVerify:(NSString *)domain
{
    NSString *urlString = [NSString stringWithFormat:@"https://canvas.instructure.com/api/v1/mobile_verify.json?domain=%@", domain];
    NSURL *mobileVerifyURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:mobileVerifyURL];
    [request addValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        NSURLSessionTask *mobileVerifyTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            }
            else {
                // No idea how long this has been happening, but if any requests are made before the mobile verify request, the json is returned with while(1); in front of it
                // Need to strip that out before we parse the json
                NSString *stringResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *fixed = [stringResponse stringByReplacingOccurrencesOfString:@"while(1);" withString:@""];
                NSData   *fixedData = [fixed dataUsingEncoding:NSUTF8StringEncoding] ?: data;
                NSError *jsonError;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:fixedData options:NSJSONReadingAllowFragments error:&jsonError];
                if (jsonError) {
                    [subscriber sendError:jsonError];
                    return;
                }
                
                NSDictionary *localizedErrorDescriptions = @{
                                                             @(CBIMobileVerifyResultOther): NSLocalizedString(@"Not authorized.", nil),
                                                             @(CBIMobileVerifyResultBadSite): NSLocalizedString(@"Invalid Canvas URL.", nil),
                                                             @(CBIMobileVerifyResultBadUserAgent): NSLocalizedString(@"Invalid User Agent.", nil),
                                                             };
                
                NSNumber *responseCode = jsonResponse[CBIMobileVerifyResultName];
                NSString *localizedErrorDescription = localizedErrorDescriptions[responseCode];
                
                if (localizedErrorDescription) {
                    NSError *mobileVerifyResponseError = [NSError errorWithDomain:@"com.instructure.icanvas" code:[responseCode intValue] userInfo:@{NSLocalizedDescriptionKey: localizedErrorDescription}];
                    [subscriber sendError:mobileVerifyResponseError];
                }
                else { // mobile verify was successful
                    [subscriber sendNext:jsonResponse];
                    [subscriber sendCompleted];
                }
            }
        }];
        
        [mobileVerifyTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [mobileVerifyTask cancel];
        }];
    }];
}

- (NSString *)userAgent
{
    NSString *appVersion = [NSString stringWithFormat:@"%@ (%@)",
                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    NSString *hardwarePlatform = [[UIDevice currentDevice] ckm_platformString];
    return [NSString stringWithFormat:@"%@/%@   %@/iOS %@", self.delegate.appNameForMobileVerify, appVersion, hardwarePlatform, [[UIDevice currentDevice] systemVersion]];
}

- (NSString *)logFilePath {
    return self.delegate.logFilePath;
}

- (RACSignal *)clientForSuggestedDomain:(NSString *)host
{
    self.domainPicker = [CKMDomainPickerViewController new];
    self.domainPickerNavigationController = [[UINavigationController alloc] initWithRootViewController:self.domainPicker];
    [self.domainPickerNavigationController setNavigationBarHidden:YES animated:NO];
    
    RACSignal *signalForClientForUsersDomain =  [[self.domainPicker selectedADomainSignal] flattenMap:^__kindof RACStream * _Nullable(CKIAccountDomain *domain) {
        return [[self clientForMobileVerifiedDomain:domain] deliverOn:[RACScheduler mainThreadScheduler]];
    }];
    
    RACSignal *signalForLoggedInUser = [signalForClientForUsersDomain flattenMap:^__kindof RACStream *(CKIClient *clientForUsersDomain) {
        return [clientForUsersDomain loginWithAuthenticationMethod:self.domainPicker.authenticationMethod];
    }];
    
    return [[signalForLoggedInUser merge:[self.domainPicker selectUserSignal]] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (void)login
{
    [self loginWithSuggestedDomain:nil];
}

- (void)loginWithSuggestedDomain:(NSString *)host
{
    RACSignal *signalForClientForUsersDomain = [self clientForSuggestedDomain:host];
    
    [signalForClientForUsersDomain subscribeNext:^(CKIClient *currentClient) {
        [self setCurrentClient:currentClient];
        [[FXKeychain sharedKeychain] addClient:currentClient];
        [_subjectForClientLogin sendNext:currentClient];
    } error:^(NSError *error) {
        [self login];
    }];
    
    [_subjectForClientLogout sendNext:self.domainPickerNavigationController];
}

- (RACSignal *)signalForLogout
{
    return [_subjectForClientLogout deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)signalForCannotLoginAutomatically {
    return [_subjectForClientCannotLogInAutomatically deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)signalForLogin
{
    RACSignal *signalForInitialClient = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CKIClient *current = [self clientFromKeychain];
        if (current) {
            self.currentClient = current;
            [subscriber sendNext:self.currentClient];
        } else if (self.currentClient == nil) {
            [self login];
        } else {
            [_subjectForClientCannotLogInAutomatically sendNext:self.domainPickerNavigationController];
        }
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    if (self.fetchesBranding == NO) {
        return [[signalForInitialClient concat:_subjectForClientLogin] deliverOn:[RACScheduler mainThreadScheduler]];
    }
        
    return [[[signalForInitialClient concat:_subjectForClientLogin] flattenMap:^__kindof RACSignal * _Nullable(CKIClient * _Nullable client) {
        RACSignal *brandingSignal = [client fetchBranding];
        return [brandingSignal map:^id _Nullable(CKIBrand *  _Nullable brand) {
            client.branding = brand;
            return client;
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (BOOL)currentClientHasHost:(NSString *)host {
    return [self.currentClient.baseURL.host isEqualToString:host];
}

- (void)completeLogout {
    [self setCurrentClient:nil];
    [self login];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)logout
{
    [self logoutWithCompletionBlock:^{
        [self completeLogout];
    }];
}

- (void)logoutWithCompletionBlock:(void (^)(void))completionBlock
{
    if (!self.currentClient) {
        if (completionBlock) {
            completionBlock();
        }
        
        return;
    }
    
    // remove from keychain here because removeClient is tied to access token
    FXKeychain *keychain = [FXKeychain sharedKeychain];
    [keychain removeClient:self.currentClient];
    
    [[self.currentClient logout] subscribeError:^(NSError *error) {
        if (completionBlock) {
            completionBlock();
        }
    } completed:^{
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)switchUser
{
    [self completeLogout];
}

- (RACSignal *)masqueradeAsUserWithID:(NSString *)id {
    return [self masqueradeAsUserWithID:id domain:self.currentClient.baseURL.host];
}

- (RACSignal *)masqueradeAsUserWithID:(NSString *)id domain:(NSString *)domain
{
    if ([domain rangeOfString:@"."].location == NSNotFound) {
        // lets tack on a `.instructure.com`
        domain = [domain stringByAppendingString:@".instructure.com"];
    }
    RACSignal *newClientSignal;
    if ([self.currentClient.baseURL.host isEqualToString:domain]) {
        CKIClient *masqClient = [self.currentClient copy];
        masqClient.actAsUserID = id;
        newClientSignal = [RACSignal return:masqClient];
    } else {
        CKIAccountDomain *account = [[CKIAccountDomain alloc] initWithDomain:domain];
        newClientSignal = [[self clientForMobileVerifiedDomain:account] map:^CKIClient *(CKIClient *newClient) {
            [newClient setValue:self.currentClient.accessToken forKey:@"accessToken"];
            newClient.actAsUserID = id;
            newClient.originalBaseURL = self.currentClient.baseURL;
            return newClient;
        }];
    }

    __block CKIClient *newClient;
    RACSignal *newUserSignal = [[newClientSignal flattenMap:^__kindof RACStream *(CKIClient *client) {
        newClient = client;
        return [newClient fetchCurrentUser];
    }] replay];
    
    RACSignal *fetchUserID = [newUserSignal replay];
    
    [fetchUserID subscribeNext:^(CKIUser *masqueradingUser) {
        [newClient setValue:masqueradingUser forKeyPath:@"currentUser"];
        self.currentClient = newClient;
        [_subjectForClientLogin sendNext:newClient];
    }];
    
    return [fetchUserID deliverOn:[RACScheduler mainThreadScheduler]];
}

- (void)stopMasquerading
{
    if (self.currentClient.actAsUserID == nil) {
        return;
    }
    
    [[FXKeychain sharedKeychain] removeClient:self.currentClient];
    
    CKIClient *plainOlClient = [self.currentClient copy];
    plainOlClient.actAsUserID = nil;
    if (self.currentClient.originalBaseURL) {
        [plainOlClient setValue:self.currentClient.originalBaseURL forKey:@"baseURL"];
    }
    [[plainOlClient fetchCurrentUser] subscribeNext:^(id x) {
        [plainOlClient setValue:x forKeyPath:@"currentUser"];
        self.currentClient = plainOlClient;
        [[FXKeychain sharedKeychain] addClient:plainOlClient];
        [_subjectForClientLogin sendNext:plainOlClient];
    }];
}

- (void)resetKeymasterForTesting {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] removeCookiesSinceDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    BOOL shouldLogout = [[FXKeychain sharedKeychain].clients count] > 0;
    for (CKIClient *client in [[FXKeychain sharedKeychain].clients copy]) {
        [[FXKeychain sharedKeychain] removeClient:client];
    }
    if (shouldLogout) {
        [self logout];
    }
}

#pragma mark - URL Manipulation

/**
 Domainify takes whatever crap the user typed, strips off any schemes,
 trailing slashes, etc., to get just the domain. If it doesn't seem to have
 a top level domain, it adds instructure.com for good measure.
 */
- (NSString *)domainify:(NSString *)domainString
{
    NSString *urlString = [domainString lowercaseString];
    urlString = [self stripURLScheme:urlString];
    urlString = [self removeSlashes:urlString];
    urlString = [self addInstructureDotComIfNeeded:urlString];
    return urlString;
}

- (NSString *)addInstructureDotComIfNeeded:(NSString *)hostname
{
    if ([hostname rangeOfString:@"."].location == NSNotFound && [hostname rangeOfString:@":"].location == NSNotFound) {
        hostname = [NSString stringWithFormat:@"%@.instructure.com", hostname];
    }
    return hostname;
}

- (NSString *)removeSlashes:(NSString *)hostname
{
    hostname = [hostname stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    return hostname;
}

- (NSString *)stripURLScheme:(NSString *)url
{
    if ([url hasPrefix:@"https://"]) {
        url = [url substringFromIndex:8];
    }
    else if ([url hasPrefix:@"http://"]) {
        url = [url substringFromIndex:7];
    }
    return url;
}


@end


@implementation CKIClient (CanvasKeymaster)
+ (instancetype)currentClient
{
    return TheKeymaster.currentClient;
}
@end
