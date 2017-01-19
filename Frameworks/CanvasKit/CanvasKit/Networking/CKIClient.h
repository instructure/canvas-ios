//
//  CKIClient.h
//  CanvasKit
//
//  Copyright (c) 2013 Instructure. All rights reserved.
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
 The ID of the user that the current user should masquerade as
 */
@property (nonatomic) NSString *actAsUserID;

/**
 Instantiates a canvas client with the given information.

 @param baseURL the base URL to be used by the client
 @param clientID the special client ID that uniquely identifies this application
 @param clientSecret the client secret for the application
 */
+ (instancetype)clientWithBaseURL:(NSURL *)baseURL clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;

/**
 Instantiates a canvas client with the given information.

 @param baseURL the base URL to be used by the client
 @param clientID the special client ID that uniquely identifies this application
 @param clientSecret the client secret for the application
 */
- (instancetype)initWithBaseURL:(NSURL *)baseURL clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;


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

@end
