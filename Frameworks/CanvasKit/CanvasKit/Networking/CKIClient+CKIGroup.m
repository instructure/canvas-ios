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
