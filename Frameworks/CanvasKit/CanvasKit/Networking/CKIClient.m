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

@import ReactiveObjC;
@import AFNetworking;
#import <Mantle/Mantle.h>

#import "CKIClient.h"
#import "CKIClient+CKIUser.h"
#import "CKIModel.h"
#import "CKIUser.h"
#import "CKIBrand.h"
#import "NSHTTPURLResponse+Pagination.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "CKILoginFinishedViewController.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "CKILoginViewController.h"
#endif

NSString *const CKIClientAccessTokenExpiredNotification = @"CKIClientAccessTokenExpiredNotification";

@interface CKIClient ()
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) CKIUser *currentUser;
@property (nonatomic, assign) BOOL invalidated;
@property (nonatomic, strong) NSString *authenticationProvider;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
@property (nonatomic, weak) UIViewController *webLoginViewController;
#endif

@end

@implementation CKIClient

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        RAC(self, isLoggedIn) = [RACObserve(self, accessToken) map:^id(id value) {
            return @(value != nil);
        }];

        [self setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [self setResponseSerializer:[AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments]];
        
        @weakify(self);
        [self setSessionDidBecomeInvalidBlock:^(NSURLSession *session, NSError *error) {
            @strongify(self);
            
            self.invalidated = true;
        }];
    }
    return self;
}

+ (instancetype)clientWithBaseURL:(NSURL *)baseURL clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret authenticationProvider:(NSString *)authenticationProvider
{
    return [[CKIClient alloc] initWithBaseURL:baseURL clientID:clientID clientSecret:clientSecret authenticationProvider:authenticationProvider];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret authenticationProvider:(NSString *)authenticationProvider
{
    NSParameterAssert(baseURL);
    NSParameterAssert(clientID);
    NSParameterAssert(clientSecret);

    self = [self initWithBaseURL:baseURL];
    if (!self) {
        return nil;
    }

    self.clientID = clientID;
    self.clientSecret = clientSecret;
    self.authenticationProvider = authenticationProvider;

    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url token:(NSString *)token {
    self = [self initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self setAccessToken:token];
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    CKIClient *dup = (CKIClient *) [super copyWithZone:zone];
    dup.clientID = self.clientID;
    dup.clientSecret = self.clientSecret;
    dup.accessToken = self.accessToken;
    dup.currentUser = [self.currentUser copy];
    dup.actAsUserID = self.actAsUserID;
    dup.ignoreUnauthorizedErrors = self.ignoreUnauthorizedErrors;
    @weakify(dup);
    [dup setSessionDidBecomeInvalidBlock:^(NSURLSession *session, NSError *error) {
        @strongify(dup);
        dup.invalidated = true;
    }];
    return dup;
}

#pragma mark - Properties

- (void)setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
}

#pragma mark - OAuth

- (RACSignal *)postAuthCode:(NSString *)temporaryCode
{
    NSDictionary *params = @{
            @"client_id": self.clientID,
            @"client_secret": self.clientSecret,
            @"code": temporaryCode
    };

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self POST:@"/login/oauth2/token" parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
            [subscriber sendCompleted];
        }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal *)logout
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [self clearCookiesAndCache];
        NSString *path = @"/login/oauth2/token";
        NSURLSessionDataTask *task = [self DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [self revokeClient];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self revokeClient];
            [subscriber sendError:error];
        }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (void)revokeClient
{
    self.accessToken = nil;
    self.currentUser = nil;
}

- (NSURLRequest *)authenticationRequestWithMethod:(CKIAuthenticationMethod)method
{
    NSAssert(method < CKIAuthenticationMethodCount, @"Invalid authentication method");
    
    NSString *urlString = [NSString stringWithFormat:@"%@/login/oauth2/auth?client_id=%@&response_type=code&redirect_uri=https://canvas/login&mobile=1&session_locale=%@",
                           self.baseURL.absoluteString,
                           self.clientID,
                           [self sessionLocale]];
    
    if (method == CKIAuthenticationMethodForcedCanvasLogin) {
        urlString = [urlString stringByAppendingString:@"&canvas_login=1"];
    }

    if (self.authenticationProvider) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&authentication_provider=%@", self.authenticationProvider]];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"CanvasKit/1.0" forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

- (NSString *)sessionLocale
{
    NSString *language = [[NSLocale preferredLanguages] firstObject];

    // strip region
    NSRange dash = [language rangeOfString:@"-"];
    if (dash.location != NSNotFound) {
        language = [language substringToIndex:dash.location];
    }

    return language;
}

#pragma mark - Caching & Cookies

- (void)clearCookiesAndCache
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

#pragma mark - JSON API Helpers

- (RACSignal *)deleteObjectAtPath:(NSString *)path modelClass:(Class)modelClass parameters:(NSDictionary *)parameters context:(id<CKIContext>)context
{
    NSValueTransformer *transformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:modelClass];
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSURLSessionDataTask *deletionTask = [self DELETE:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            if (responseObject) {
                CKIModel *model = [self parseModel:transformer fromJSON:responseObject context:nil];
                [subscriber sendNext:model];
            }
            [subscriber sendCompleted];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            [subscriber sendError:[self errorForResponse:response]];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [deletionTask cancel];
        }];
        
    }] setNameWithFormat:@"-deleteObjectAtPath: %@", path];
}

- (NSError *)errorForResponse:(NSHTTPURLResponse *)response
{

    NSDictionary *userInfo;
    
    switch (response.statusCode) {
        case 401: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"You are not authorized to perform this action.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)};
        }
            break;
        default: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"An error occurred", nil),
                            NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil),
                            NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"", nil)};
        }
            break;
    }
    
    NSError *error = [[NSError alloc] initWithDomain:@"com.instructure.canvaskit.APIRequestError" code:response.statusCode userInfo:userInfo];
    return error;
}

- (RACSignal *)fetchResponseAtPath:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass context:(id<CKIContext>)context
{
    NSAssert([modelClass isSubclassOfClass:[CKIModel class]], @"Can only fetch CKIModels");

    NSValueTransformer *transformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:modelClass];
    return [self fetchResponseAtPath:path parameters:parameters jsonAPIKey:[modelClass keyForJSONAPIContent] transformer:transformer context:context];
}


- (RACSignal *)fetchResponseAtPath:(NSString *)path parameters:(NSDictionary *)parameters transformer:(NSValueTransformer *)transformer context:(id<CKIContext>)context
{
    return [self fetchResponseAtPath:path parameters:parameters jsonAPIKey:nil transformer:transformer context:context];
}

- (RACSignal *)fetchResponseAtPath:(NSString *)path parameters:(NSDictionary *)parameters jsonAPIKey:(NSString *)jsonAPIKey transformer:(NSValueTransformer *)transformer context:(id<CKIContext>)context
{
    NSParameterAssert(path);
    NSParameterAssert(transformer);

    NSDictionary *newParameters = [@{@"per_page": @50} dictionaryByAddingObjectsFromDictionary:parameters];

    return [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        if (self.invalidated) {
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{}];
        }
        
        NSDictionary *finalParameters = newParameters;
        if ([self.actAsUserID length]) {
            finalParameters = [@{@"as_user_id": self.actAsUserID} dictionaryByAddingObjectsFromDictionary:finalParameters];
        }
        NSURLSessionDataTask *task = [self GET:path parameters:finalParameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *) task.response;
            
            // check for pagination in the headers
            NSURL *currentPage = response.currentPage;
            NSURL *nextPage = response.nextPage;
            NSURL *lastPage = response.lastPage;

            // check for JSONAPI pagination
            if (currentPage == nil && [responseObject isKindOfClass:[NSDictionary class]]){
                currentPage = [NSURL URLWithString:[responseObject valueForKeyPath:@"meta.pagination.current"]];
                nextPage = [NSURL URLWithString:[responseObject valueForKeyPath:@"meta.pagination.next"]];
                lastPage = [NSURL URLWithString:[responseObject valueForKeyPath:@"meta.pagination.last"]];
            }
            
            if ([jsonAPIKey length]) {
                responseObject = responseObject[jsonAPIKey];
            }

            RACSignal *thisPageSignal = [self parseResponseWithTransformer:transformer fromJSON:responseObject context:context];
            RACSignal *nextPageSignal = [RACSignal empty];

            if (nextPage && ![currentPage isEqual:lastPage]) {
                nextPageSignal = [self fetchResponseAtPath:nextPage.relativeString parameters:newParameters jsonAPIKey:jsonAPIKey transformer:transformer context:context];
            }

            [[thisPageSignal concat:nextPageSignal] subscribe:subscriber];

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            // don't try this if we are attempting to masquerade!
            if ([self isUnauthorizedError:error] &&
                [self actAsUserID].length == 0 &&
                !self.ignoreUnauthorizedErrors) {
                // if the user gets a 401 that might be a server issue, lets
                // do one more check to see if our access token has expired
                // or been revoked
                [[self fetchCurrentUser] subscribeError:^(NSError *error) {
                    if ([self isUnauthorizedError:error]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:CKIClientAccessTokenExpiredNotification object:self userInfo:nil];
                        [self revokeClient];
                    }
                }];
            }
            [subscriber sendError:error];
        }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"-fetchResponseAtPath: %@ parameters: %@ transformer: %@ context: %@", path, newParameters, transformer, context]
            replay];
}

- (BOOL)isUnauthorizedError:(NSError *)error
{
    NSHTTPURLResponse *failingResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    return failingResponse != nil || failingResponse.statusCode == 401;
}

- (RACSignal *)parseResponseWithTransformer:(NSValueTransformer *)transformer fromJSON:(id)responseObject context:(id<CKIContext>)context
{
    NSParameterAssert(transformer);
    NSParameterAssert(responseObject);
    NSAssert([responseObject isKindOfClass:NSArray.class] || [responseObject isKindOfClass:NSDictionary.class], @"Response object must be either an array or dictionary");

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        if ([responseObject isKindOfClass:NSArray.class]) {
            NSArray *jsonModels = responseObject;
            NSArray *models = [[jsonModels.rac_sequence map:^id(id jsonModel) {
                return [self parseModel:transformer fromJSON:jsonModel context:context];
            }] array];
            [subscriber sendNext:models];
        }
        else {
            NSDictionary *jsonModel = responseObject;
            CKIModel *model = [self parseModel:transformer fromJSON:jsonModel context:context];
            [subscriber sendNext:model];
        }

        [subscriber sendCompleted];
        return nil;
    }];
}

- (CKIModel *)parseModel:(NSValueTransformer *)transformer fromJSON:(NSDictionary *)jsonDictionary context:(id)context
{
    NSParameterAssert(transformer);
    NSParameterAssert(jsonDictionary);
    
    id tranformedValue = [transformer transformedValue:jsonDictionary];
    
    NSAssert([tranformedValue isKindOfClass:CKIModel.class], @"Transformer gave back an object of type %@, expected a CKIModel subclass.", [tranformedValue class]);
    CKIModel *model = (CKIModel *)tranformedValue;
    model.baseURL = self.baseURL;
    model.context = context;
    return model;
}

#pragma mark - POSTing

- (RACSignal *)createModelAtPath:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass context:(id<CKIContext>)context
{
    
    NSAssert([modelClass isSubclassOfClass:[CKIModel class]], @"Can only create CKIModels");

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.invalidated) {
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{}];
        }
        
        NSURLSessionDataTask *task = [self POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSString *jsonContentKey = [modelClass keyForJSONAPIContent];
            NSLog(@"created a model %@", responseObject);
            if ([jsonContentKey length]) {
                responseObject = responseObject[jsonContentKey];
            }
            
            [[self parseResponseWithTransformer:[NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:modelClass] fromJSON:responseObject context:context] subscribe:subscriber];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

#pragma mark - PUTing

- (RACSignal *)updateModel:(CKIModel *)model parameters:(NSDictionary *)parameters
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.invalidated) {
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{}];
        }
        
        NSURLSessionDataTask *task = [self PUT:model.path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            Class modelClass = model.class;
            NSAssert([modelClass isSubclassOfClass:[CKIModel class]], @"Can only create CKIModels");

            NSString *jsonContentKey = [modelClass keyForJSONAPIContent];
            
            if ([jsonContentKey length]) {
                responseObject = responseObject[jsonContentKey];
            }
            
            [[self parseResponseWithTransformer:[NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[model class]] fromJSON:responseObject context:model.context] subscribe:subscriber];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#pragma mark - UIKit Methods

- (RACSignal *)login {
    return [self loginWithAuthenticationMethod:CKIAuthenticationMethodDefault];
}

- (RACSignal *)loginWithAuthenticationMethod:(CKIAuthenticationMethod)method
{
    // don't log in again if already logged in
    if (self.isLoggedIn) {
        return nil;
    }
    
    RACSignal *client = [[[[[self authorizeWithServerUsingWebBrowserUsingAuthenticationMethod:method] flattenMap:^__kindof RACSignal * _Nullable(NSString *temporaryCode) {
        return [self postAuthCode:temporaryCode];
    }] flattenMap:^__kindof RACStream * _Nullable(NSDictionary *responseObject) {
        self.accessToken = responseObject[@"access_token"];
        return [self fetchCurrentUser];
    }] map:^id(CKIUser *user) {
        self.currentUser = user;
        return self;
    }] doError:^(NSError *error) {
        NSLog(@"CanvasKit OAuth failed with error: %@", error);
        [self clearCookiesAndCache];
    }];

    return client;
}

- (RACSignal *)authorizeWithServerUsingWebBrowserUsingAuthenticationMethod:(CKIAuthenticationMethod)method
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLRequest *request = [self authenticationRequestWithMethod:method];
        CKILoginViewController *loginViewController = [[CKILoginViewController alloc] initWithRequest:request method:method];
        loginViewController.successBlock = ^(NSString *authToken) {
            [subscriber sendNext:authToken];
            [subscriber sendCompleted];
        };
        loginViewController.failureBlock = ^(NSError *error) {
            [subscriber sendError:error];
            [subscriber sendCompleted];
        };

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:loginViewController action:@selector(cancelOAuth)];
        [button setAccessibilityIdentifier:@"cancelLoginButton"];
        [button setAccessibilityLabel:NSLocalizedString(@"Cancel", nil)];
        [loginViewController.navigationItem setLeftBarButtonItem:button]; 
        [navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [navigationController.navigationBar setBarTintColor:nil];
        [navigationController.navigationBar setTintColor:nil];
        [navigationController.navigationBar setTitleTextAttributes:nil];
        
        UIViewController *presentingViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
        [presentingViewController presentViewController:navigationController animated:YES completion:nil];
        self.webLoginViewController = navigationController;

        return [RACDisposable disposableWithBlock:^{
            CKILoginFinishedViewController *finished = [CKILoginFinishedViewController new];
            [finished setLoadingImage:[CKILoginViewController loadingImage]];
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            [UIView transitionWithView:window duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                window.rootViewController = finished;
            } completion:^(BOOL finished) {
                [self.webLoginViewController.presentingViewController dismissViewControllerAnimated:NO completion:^{
                    self.webLoginViewController = nil;
                }];
            }];
        }];
    }];
}

#endif

#pragma mark - Branding

- (RACSignal *)fetchBranding {
    NSURL *branding = [self.baseURL URLByAppendingPathComponent:@"/api/v1/brand_variables"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id < RACSubscriber >_Nonnull subscriber) {
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:branding completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            
            void (^handleError)(NSError *) = ^(NSError *error) {
                // Failing to fetch branding is not a fatal error, the user can still log into the app and use it
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            };
            
            if (error) {
                handleError(error);
                return;
            }
            
            NSError *parsingError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parsingError];

            if (parsingError) {
                handleError(parsingError);
                return;
            }

            if (json) {
                CKIBrand *brandModel = [MTLJSONAdapter modelOfClass:CKIBrand.class fromJSONDictionary:json error:&parsingError];
                if (parsingError) {
                    handleError(parsingError);
                    return;
                }
                [subscriber sendNext:brandModel];
                [subscriber sendCompleted];
            }
        }];
        [task resume];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
    return signal;
}

@end
