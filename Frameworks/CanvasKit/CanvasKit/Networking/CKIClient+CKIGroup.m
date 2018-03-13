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

#import "CKIClient+CKIGroup.h"
#import "CKIGroup.h"
#import "CKICourse.h"
#import "CKIGroupCategory.h"

@implementation CKIClient (CKIGroup)

- (RACSignal *)fetchGroup:(NSString *)groupID
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"groups"];
    path = [path stringByAppendingPathComponent:groupID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIGroup class] context:nil];
}

- (RACSignal *)fetchGroupsForLocalUser
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"users/self/groups"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIGroup class] context:nil];
}

- (RACSignal *)fetchGroupsForAccount:(NSString *)accountID
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"accounts"];
    path = [path stringByAppendingPathComponent:accountID];
    path = [path stringByAppendingPathComponent:@"groups"];
    // TODO when we add Accounts, we should really set the context here.
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIGroup class] context:nil];
}

- (RACSignal *)fetchGroup:(NSString *)groupID forContext:(id<CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"groups"];
    path = [path stringByAppendingPathComponent:groupID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIGroup class] context:context];
}

- (RACSignal *)fetchGroupsForContext:(id <CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"groups"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIGroup class] context:context];
}

- (RACSignal *)fetchGroupsForGroupCategory:(CKIGroupCategory *)category
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"group_categories"];
    path = [path stringByAppendingPathComponent:category.id];
    path = [path stringByAppendingPathComponent:@"groups"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIGroup class] context:CKIRootContext];
}

- (RACSignal *)fetchGroupUsersForContext:(id <CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"users"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIGroup class] context:context];
}

- (RACSignal *)deleteGroup:(CKIGroup *)group
{
    NSString *path = [[group.context.path stringByAppendingPathComponent:@"groups"] stringByAppendingPathComponent:group.id];
    return [self deleteObjectAtPath:path modelClass:[CKIGroup class] parameters:nil context:group.context];
}

- (RACSignal *)createGroup:(CKIGroup *)group
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"groups"];
    NSDictionary *params = @{@"name": group.name, @"description": group.groupDescription, @"is_public": @(group.isPublic), @"join_level": group.joinLevel};
    return [self createModelAtPath:path parameters:params modelClass:[CKIGroup class] context:CKIRootContext];
}

- (RACSignal *)createGroup:(CKIGroup *)group category:(CKIGroupCategory *)category
{
    NSString *path = [category.path stringByAppendingPathComponent:@"groups"];
    NSDictionary *params = @{@"name": group.name, @"description": group.groupDescription, @"is_public": @(group.isPublic), @"join_level": group.joinLevel};
    return [self createModelAtPath:path parameters:params modelClass:[CKIGroup class] context:CKIRootContext];
}

- (RACSignal *)inviteUser:(NSString *)userEmail toGroup:(CKIGroup *)group
{
    NSString *path = [[[group.context.path stringByAppendingPathComponent:@"groups"] stringByAppendingPathComponent:group.id] stringByAppendingPathComponent:@"invite"];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self POST:path parameters:@{@"invitees": @[userEmail]} progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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

- (RACSignal *)createGroupMemebershipForUser:(NSString *)userID inGroup:(CKIGroup *)group
{
    NSString *path = [[[group.context.path stringByAppendingPathComponent:@"groups"] stringByAppendingPathComponent:group.id] stringByAppendingPathComponent:@"memberships"];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self POST:path parameters:@{@"user_id": userID} progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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

- (RACSignal *)removeGroupMemebershipForUser:(NSString *)userID inGroup:(CKIGroup *)group
{
    NSString *path = [[group.path stringByAppendingPathComponent:@"users"] stringByAppendingPathComponent:userID];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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


@end
