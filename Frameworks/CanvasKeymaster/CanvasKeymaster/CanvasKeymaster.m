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

@end

@implementation CanvasKeymaster {
    RACSubject *_subjectForClientLogout, *_subjectForClientLogin;
    CKIClient *_currentClient;
    dispatch_once_t _once;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _subjectForClientLogin = [RACSubject new];
        _subjectForClientLogout = [RACSubject new];
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
    FXKeychain *keychain = [FXKeychain sharedCanvasKeychain];
    NSArray *clients = [keychain clients];
    // if we only have 1 client, lets log them in automatically
    if (clients.count == 1) {
        return clients.firstObject;
    }
    
    // if we have more than one client, let the user decide which to use
    return nil;
}

- (RACSignal *)clientForMobileVerifiedDomain:(NSString *)domain
{
    return [[self mobileVerify:domain] map:^id(NSDictionary *mobileVerifyDetails) {
        NSString *clientID = mobileVerifyDetails[CBIMobileVerifyAPIClientIDName];
        NSString *clientSecret = mobileVerifyDetails[CBIMobileVerifyAPIClientSecretName];
        NSString *baseURLString = mobileVerifyDetails[CBIMobileVerifyBaseURLName];
        NSURL *baseURL = [NSURL URLWithString:baseURLString];
        
        CKIClient *client = [CKIClient clientWithBaseURL:baseURL clientID:clientID clientSecret:clientSecret];
        [client.requestSerializer setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
        return client;
    }];
}

#pragma mark - Client Management

- (void)accessTokenExpired:(NSNotification *)note
{
    NSString *expiredAlertMessage = NSLocalizedString(@"Your login has expired or has been removed by the server. Please log in again.", @"when the access token has been revoked");
    NSString *dismissButtonTitle = NSLocalizedString(@"Dismiss", @"Dismiss login expired/revoked alert button");
    
    [[[UIAlertView alloc] initWithTitle:@"" message:expiredAlertMessage delegate:nil cancelButtonTitle:dismissButtonTitle otherButtonTitles:nil] show];
    
    [self logout];
}

- (CKIClient *)currentClient
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

- (void)removeExtraClientsIfNecessary {
    // Previously we were saving a new client in the keychain each time the app was open.
    // We are removing all clients that are not needed.
    // This code can be removed after we are confident all users have run it one time... or most users...
    BOOL hasDeletedExtraClients = [[NSUserDefaults standardUserDefaults] boolForKey:DELETE_EXTRA_CLIENTS_USER_PREFS_KEY];
    if (!hasDeletedExtraClients) {
        NSMutableDictionary *deletedClients = [@{} mutableCopy];
        [[[FXKeychain sharedCanvasKeychain] clients] enumerateObjectsUsingBlock:^(CKIClient *client, NSUInteger idx, BOOL *stop) {
            if ([deletedClients objectForKey:client.accessToken]) {
                [[FXKeychain sharedCanvasKeychain] removeClient:client];        // removes all clients with same access token
                [[FXKeychain sharedCanvasKeychain] addClient:client];           // adds a single client back
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
                NSError *jsonError;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
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
    [self.domainPicker prepopulateWithDomain:host];
    
    RACSignal *signalForClientForUsersDomain =  [[self.domainPicker selecteADomainSignal] flattenMap:^__kindof RACStream * _Nullable(NSString *domain) {
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
        [[FXKeychain sharedCanvasKeychain] addClient:currentClient];
        [_subjectForClientLogin sendNext:currentClient];
    } error:^(NSError *error) {
        [self login];
    }];
    
    [_subjectForClientLogout sendNext:self.domainPicker];
}

- (RACSignal *)signalForLogout
{
    return [_subjectForClientLogout deliverOn:[RACScheduler mainThreadScheduler]];
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

- (RACSignal *)signalForLoginWithDomain:(NSString *)host
{
    // logged into the correct domain
    if ([self.currentClient.baseURL.host isEqualToString:host]) {
        //same domain, return current client as signal
        return [[RACSignal return:self.currentClient] deliverOn:[RACScheduler mainThreadScheduler]];
    }
    
    // check the keychain
    FXKeychain *keychain = [FXKeychain sharedCanvasKeychain];
    NSArray *clients = [keychain clients];
    NSArray *eligibleClients = [clients.rac_sequence filter:^BOOL(CKIClient *aClient) {
        return [aClient.baseURL.host isEqualToString:host];
    }].array;
    
    // only one client for the domain
    if (eligibleClients.count == 1) {
        self.currentClient = eligibleClients.firstObject;
        [_subjectForClientLogin sendNext:self.currentClient];
        return [[RACSignal return:self.currentClient] deliverOn:[RACScheduler mainThreadScheduler]];
    }
    
    //case eligibleClients.count > 1 || eligibleClients.count == 0
    [self logoutWithCompletionBlock:^{
        [self setCurrentClient:nil];
        [self loginWithSuggestedDomain:host];
        
        if (eligibleClients.count == 0) {
            //enter domain and send to user credentials page
            [self.domainPicker sendDomain];
        }
    }];

    return [[_subjectForClientLogin take:1] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (void)completeLogout
{
    [self setCurrentClient:nil];
    [self login];
}

- (void)logout
{
    [self logoutWithCompletionBlock:^{
        [self completeLogout];
    }];
}

- (void)logoutWithCompletionBlock:(void (^)())completionBlock
{
    if (!self.currentClient) {
        if (completionBlock) {
            completionBlock();
        }
        
        return;
    }
    
    // remove from keychain here because removeClient is tied to access token
    FXKeychain *keychain = [FXKeychain sharedCanvasKeychain];
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
        newClientSignal = [[self clientForMobileVerifiedDomain:domain] map:^CKIClient *(CKIClient *newClient) {
            [newClient setValue:self.currentClient.accessToken forKey:@"accessToken"];
            newClient.actAsUserID = id;
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
    
    [[FXKeychain sharedCanvasKeychain] removeClient:self.currentClient];
    
    CKIClient *plainOlClient = [self.currentClient copy];
    plainOlClient.actAsUserID = nil;
    [[plainOlClient fetchCurrentUser] subscribeNext:^(id x) {
        [plainOlClient setValue:x forKeyPath:@"currentUser"];
        self.currentClient = plainOlClient;
        [[FXKeychain sharedCanvasKeychain] addClient:plainOlClient];
        [_subjectForClientLogin sendNext:plainOlClient];
    }];
}

- (void)resetKeymasterForTesting {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] removeCookiesSinceDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    BOOL shouldLogout = [[FXKeychain sharedCanvasKeychain].clients count] > 0;
    for (CKIClient *client in [[FXKeychain sharedCanvasKeychain].clients copy]) {
        [[FXKeychain sharedCanvasKeychain] removeClient:client];
    }
    if (shouldLogout) {
        [self logout];
    }
}

@end


@implementation CKIClient (CanvasKeymaster)
+ (instancetype)currentClient
{
    return TheKeymaster.currentClient;
}
@end
