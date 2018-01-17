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

#import <AFNetworking/AFHTTPSessionManager.h>
@class CKIMediaServer;

typedef NS_ENUM(NSUInteger, CKIAuthenticationMethod) {
    CKIAuthenticationMethodDefault,
    CKIAuthenticationMethodForcedCanvasLogin,
    CKIAuthenticationMethodSiteAdmin,
    CKIAuthenticationMethodCount,
};

@class CKIModel;
@class CKIUser;
@class CKIBrand;
@class RACSignal;

extern NSString *const CKIClientAccessTokenExpiredNotification;

@protocol CKIContext;

/**
 The client responsible for processing all networking requests to
 the canvas API.
 */
@interface CKIClient : AFHTTPSessionManager <NSCopying>

@property (nonatomic, strong) CKIMediaServer *mediaServer;

/**
 The access token for making oauth requests (if logged in)
*/
@property (nonatomic, readonly) NSString *accessToken;

/**
 The user that is currently logged in via this client.
 */
@property (nonatomic, readonly) CKIUser *currentUser;


/**
 Branding info for current user organization.
 */
@property (nonatomic) CKIBrand *branding;


/**
 The ID of the user that the current user should masquerade as
 */
@property (nonatomic) NSString *actAsUserID;

/**
 When acting as a user, the original base url to revert to once masquerading has finished
 */
@property (nonatomic) NSURL *originalBaseURL;

/**
 By default, instances of CKIClient will send notifications logout users if api calls return unauthorized errors
 This behavior is good if there is only one CKIClient
 However, there are instances when many CKIClients exist. (Such as the login screen)
 Set this property to NO to ignore those errors
 */
@property (nonatomic) BOOL ignoreUnauthorizedErrors;

/**
 Instantiates a canvas client with the given information.

 @param baseURL the base URL to be used by the client
 @param clientID the special client ID that uniquely identifies this application
 @param clientSecret the client secret for the application
 */
+ (instancetype)clientWithBaseURL:(NSURL *)baseURL clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret authenticationProvider:(NSString *)authenticationProvider;

/**
 Instantiates a canvas client with the given information.

 @param baseURL the base URL to be used by the client
 @param clientID the special client ID that uniquely identifies this application
 @param clientSecret the client secret for the application
 */
- (instancetype)initWithBaseURL:(NSURL *)baseURL clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret authenticationProvider:(NSString *)authenticationProvider;


/**
 This method is intended for testing only. It should not be used in a production app
 
 @param baseURL the base URL to be used by the client
 @param token the auth token acquired from Canvas web for the user
 */
- (instancetype)initWithBaseURL:(NSURL *)url token:(NSString *)token;

#pragma mark - OAuth

/**
 Tell the server to revoke the access token.
*/
- (RACSignal *)logout;

/**
 Checks to see if the user is logged in.
 */
@property (nonatomic) BOOL isLoggedIn;

#pragma mark - JSON API Helpers

/**
 Delete an object at the given path
 
 @param path the api endpoint for the object
 @param modelClass the class of the model that is being deleted
 @param context the context for the deleted object
 */
- (RACSignal *)deleteObjectAtPath:(NSString *)path modelClass:(Class)modelClass parameters:(NSDictionary *)parameters context:(id<CKIContext>)context;

/**
 Fetch a paginated response from the given JSON API endpoint.
 
 @param path the paginated JSON API endpoint (ex. @"api/v1/courses/123/modules")
 @param parameters the parameters to be applied to the request
 @param modelClass the class of the model to generate
 @param context the context for the created object(s)
 */
- (RACSignal *)fetchResponseAtPath:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass context:(id<CKIContext>)context;
/**
 Fetch a paginated response from the given JSON API endpoint.
 
 @param path the paginated JSON API endpoint (ex. @"api/v1/courses/123/modules")
 @param parameters the parameters to be applied to the request
 @param valueTransformer an NSValueTransformer that transforms dictionaries into CKIModels
 @param context the context for the created object(s)
 */
- (RACSignal *)fetchResponseAtPath:(NSString *)path parameters:(NSDictionary *)parameters transformer:(NSValueTransformer *)transformer context:(id<CKIContext>)context;


/**
 Performs a POST to the give path with the give parameters
 
 @param path the path for creating the object
 @param parameters the POST parameters to be sent
 @param modelClass the class of the resulting object
 @param context the context for the created object
 */
- (RACSignal *)createModelAtPath:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass context:(id<CKIContext>)context;


/**
 Does a PUT do the model's `path` with the given parameters
 */
- (RACSignal *)updateModel:(CKIModel *)model parameters:(NSDictionary *)parameters;

/**
 Creates a model from json
 */
- (CKIModel *)parseModel:(NSValueTransformer *)transformer fromJSON:(NSDictionary *)jsonDictionary context:(id)context;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#pragma mark - UIKit Exclusive Methods
/**
 Starts the OAuth2 authentication process. The user will be asked to login to Canvas. Once logged in the user will have the option to allow the app to authenticate via Canvas.

 @warning CanvasKit must be prepared for OAuth2 before this method is called.
 @see CanvasKit.h
 */
- (RACSignal *)login;

- (RACSignal *)loginWithAuthenticationMethod:(CKIAuthenticationMethod)method;
#endif

- (RACSignal *)fetchBranding;

@end
