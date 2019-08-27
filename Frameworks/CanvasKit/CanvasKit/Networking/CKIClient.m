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

@import ReactiveObjC;
@import AFNetworking;
@import Core;
#import <Mantle/Mantle.h>

#import "CKIClient.h"
#import "CKIClient+CKIUser.h"
#import "CKIModel.h"
#import "CKIUser.h"
#import "CKIBrand.h"
#import "NSHTTPURLResponse+Pagination.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

NSString *const CKIClientAccessTokenExpiredNotification = @"CKIClientAccessTokenExpiredNotification";

@interface CKIClient ()
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *effectiveLocale;
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

- (nullable instancetype)initWithBaseURL:(nonnull NSURL *)url token:(nonnull NSString *)token refreshToken:(nullable NSString *)refreshToken clientID:(nullable NSString *)clientID clientSecret:(nullable NSString *)clientSecret {
    self = [self initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.refreshToken = refreshToken;
    self.clientID = clientID;
    self.clientSecret = clientSecret;
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

#pragma mark - JSON API Helpers

- (RACSignal *)deleteObjectAtPath:(NSString *)path modelClass:(Class)modelClass parameters:(NSDictionary *)parameters context:(id<CKIContext>)context
{
    NSValueTransformer *transformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:modelClass];
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        NSError *serializationError = nil;
        NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
        if (serializationError) {
            [subscriber sendError:serializationError];
            return [RACDisposable disposableWithBlock:^{}];
        }
        [request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];

        NSURLSessionDataTask *deletionTask = [[NSURLSession getDefaultURLSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) { dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [subscriber sendError:[self errorForResponse:(NSHTTPURLResponse *)response]];
                return [subscriber sendCompleted];
            }
            NSError *serializationError = nil;
            id responseObject = [self.responseSerializer responseObjectForResponse:response data:data error:&serializationError];
            if (serializationError) {
                [subscriber sendError:serializationError];
            } else if (responseObject) {
                CKIModel *model = [self parseModel:transformer fromJSON:responseObject context:nil];
                [subscriber sendNext:model];
            }
            [subscriber sendCompleted];
        });}];
        [deletionTask resume];
        
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
    return [self fetchResponseAtPath:path parameters:parameters modelClass:modelClass context:context exhaust:YES];
}

- (RACSignal *)fetchResponseAtPath:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass context:(id<CKIContext>)context exhaust:(BOOL)exhaust
{
    NSAssert([modelClass isSubclassOfClass:[CKIModel class]], @"Can only fetch CKIModels");

    NSValueTransformer *transformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:modelClass];
    return [self fetchResponseAtPath:path parameters:parameters jsonAPIKey:[modelClass keyForJSONAPIContent] transformer:transformer context:context exhaust:exhaust];
}

- (RACSignal *)fetchResponseAtPath:(NSString *)path parameters:(NSDictionary *)parameters transformer:(NSValueTransformer *)transformer context:(id<CKIContext>)context
{
    return [self fetchResponseAtPath:path parameters:parameters jsonAPIKey:nil transformer:transformer context:context];
}

- (RACSignal *)fetchResponseAtPath:(NSString *)path parameters:(NSDictionary *)parameters jsonAPIKey:(NSString *)jsonAPIKey transformer:(NSValueTransformer *)transformer context:(id<CKIContext>)context
{
    return [self fetchResponseAtPath:path parameters:parameters jsonAPIKey:jsonAPIKey transformer:transformer context:context exhaust:YES];
}

- (RACSignal *)fetchResponseAtPath:(NSString *)path parameters:(NSDictionary *)parameters jsonAPIKey:(NSString *)jsonAPIKey transformer:(NSValueTransformer *)transformer context:(id<CKIContext>)context exhaust:(BOOL)exhaust
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

        NSError *serializationError = nil;
        NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString] parameters:finalParameters error:&serializationError];
        if (serializationError) {
            [subscriber sendError:serializationError];
            return [RACDisposable disposableWithBlock:^{}];
        }
        [request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];

        NSURLSessionDataTask *task = [[NSURLSession getDefaultURLSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) { dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                return [subscriber sendError:[self errorForResponse:(NSHTTPURLResponse *)response]];
            }
            NSError *serializationError = nil;
            id responseObject = [self.responseSerializer responseObjectForResponse:response data:data error:&serializationError];
            if (serializationError) {
                return [subscriber sendError:serializationError];
            }
            if (!responseObject) {
                return [subscriber sendCompleted];
            }

            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            // check for pagination in the headers
            NSURL *currentPage = httpResponse.currentPage;
            NSURL *nextPage = httpResponse.nextPage;
            NSURL *lastPage = httpResponse.lastPage;

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

            if (nextPage && ![currentPage isEqual:lastPage] && exhaust) {
                nextPageSignal = [self fetchResponseAtPath:nextPage.relativeString parameters:newParameters jsonAPIKey:jsonAPIKey transformer:transformer context:context];
            }

            [[thisPageSignal concat:nextPageSignal] subscribe:subscriber];
        });}];
        [task resume];

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

@end
