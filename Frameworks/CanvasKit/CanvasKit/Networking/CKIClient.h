//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

extern NSString * _Nonnull const CKIClientAccessTokenExpiredNotification;

@protocol CKIContext;

/**
 The client responsible for processing all networking requests to
 the canvas API.
 */
@interface CKIClient : AFHTTPSessionManager <NSCopying>

@property (nonatomic, strong, nonnull) CKIMediaServer *mediaServer;

/**
 The access token for making oauth requests (if logged in)
*/
@property (nonatomic, readonly, nonnull) NSString *accessToken;

/**
 THe current effective locale (if logged in)
*/
@property (nonatomic, readonly, nullable) NSString *effectiveLocale;

/**
 The user that is currently logged in via this client.
 */
@property (nonatomic, readonly, nonnull) CKIUser *currentUser;


/**
 Branding info for current user organization.
 */
@property (nonatomic, nonnull) CKIBrand *branding;


/**
 The ID of the user that the current user should masquerade as
 */
@property (nonatomic, nullable) NSString *actAsUserID;

/**
 The ID of the masquerading user
 */
@property (nonatomic, nullable) NSString *originalIDOfMasqueradingUser;

/**
 When acting as a user, the original base url to revert to once masquerading has finished
 */
@property (nonatomic, nullable) NSURL *originalBaseURL;

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
+ (nullable instancetype)clientWithBaseURL:(nonnull NSURL *)baseURL clientID:(nonnull NSString *)clientID clientSecret:(nonnull NSString *)clientSecret authenticationProvider:(nullable NSString *)authenticationProvider;

/**
 Instantiates a canvas client with the given information.

 @param baseURL the base URL to be used by the client
 @param clientID the special client ID that uniquely identifies this application
 @param clientSecret the client secret for the application
 */
- (nullable instancetype)initWithBaseURL:(nonnull NSURL *)baseURL clientID:(nonnull NSString *)clientID clientSecret:(nonnull NSString *)clientSecret authenticationProvider:(nullable NSString *)authenticationProvider;


/**
 This method is intended for testing only. It should not be used in a production app
 
 @param url the base URL to be used by the client
 @param token the auth token acquired from Canvas web for the user
 */
- (nullable instancetype)initWithBaseURL:(nonnull NSURL *)url token:(nonnull NSString *)token;

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
- (nonnull RACSignal *)deleteObjectAtPath:(nonnull NSString *)path modelClass:(nonnull Class)modelClass parameters:(nullable NSDictionary *)parameters context:(nullable id<CKIContext>)context;

/**
 Fetch a paginated response from the given JSON API endpoint.
 
 @param path the paginated JSON API endpoint (ex. @"api/v1/courses/123/modules")
 @param parameters the parameters to be applied to the request
 @param modelClass the class of the model to generate
 @param context the context for the created object(s)
 */
- (nonnull RACSignal *)fetchResponseAtPath:(nonnull NSString *)path parameters:(nullable NSDictionary *)parameters modelClass:(nonnull Class)modelClass context:(nullable id<CKIContext>)context;
- (nonnull RACSignal *)fetchResponseAtPath:(nonnull NSString *)path parameters:(nullable NSDictionary *)parameters modelClass:(nonnull Class)modelClass context:(nullable id<CKIContext>)context exhaust:(BOOL)exhaust;
/**
 Fetch a paginated response from the given JSON API endpoint.
 
 @param path the paginated JSON API endpoint (ex. @"api/v1/courses/123/modules")
 @param parameters the parameters to be applied to the request
 @param transformer an NSValueTransformer that transforms dictionaries into CKIModels
 @param context the context for the created object(s)
 */
- (nonnull RACSignal *)fetchResponseAtPath:(nonnull NSString *)path parameters:(nullable NSDictionary *)parameters transformer:(nonnull NSValueTransformer *)transformer context:(nullable id<CKIContext>)context;


/**
 Performs a POST to the give path with the give parameters
 
 @param path the path for creating the object
 @param parameters the POST parameters to be sent
 @param modelClass the class of the resulting object
 @param context the context for the created object
 */
- (nonnull RACSignal *)createModelAtPath:(nonnull NSString *)path parameters:(nullable NSDictionary *)parameters modelClass:(nonnull Class)modelClass context:(nullable id<CKIContext>)context;


/**
 Does a PUT do the model's `path` with the given parameters
 */
- (nonnull RACSignal *)updateModel:(nonnull CKIModel *)model parameters:(nullable NSDictionary *)parameters;

/**
 Creates a model from json
 */
- (nonnull CKIModel *)parseModel:(nonnull NSValueTransformer *)transformer fromJSON:(nonnull NSDictionary *)jsonDictionary context:(nullable id)context;

@end
