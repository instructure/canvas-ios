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

#import "CKIClient+TestingClient.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface CKITestClient : CKIClient
@property (nonatomic) NSMutableSet *errorPaths;
@property (nonatomic) NSMutableDictionary *objectsByPath;
@end

@implementation CKIClient (TestingClient)

+ (instancetype)testClient
{
    return [CKITestClient new];
}

- (void)returnErrorForPath:(NSString *)path
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)returnResponseObject:(id)responseObject forPath:(NSString *)path
{
    [self doesNotRecognizeSelector:_cmd];
}

@end


@implementation CKITestClient

- (id)init
{
    self = [super init];
    if (self) {
        self.errorPaths = [NSMutableSet set];
        self.objectsByPath = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)returnErrorForPath:(NSString *)path
{
    [self.errorPaths addObject:path];
}

- (void)returnResponseObject:(id)responseObject forPath:(NSString *)path
{
    // path is required to be non-nil
    NSParameterAssert(path);
    
    if (responseObject == nil) {
        [self.objectsByPath removeObjectForKey:path];
    } else {
        [self.errorPaths removeObject:path];
        self.objectsByPath[path] = responseObject;
    }
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSParameterAssert(URLString);
    
    if ([self.errorPaths containsObject:URLString]) {
        failure(nil, [NSError errorWithDomain:@"com.instructure.CanvasKit" code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"CKITestClient error.", @"Error only used in testing")}]);
        return nil;
    }
    
    id responseObject = self.objectsByPath[URLString];
    if (responseObject != nil) {
        success(nil, responseObject);
        return nil;
    }
    
    [NSException raise:NSInvalidArgumentException format:@"There is no test configuration for the given path (%@)", URLString];
    return nil;
}

@end
