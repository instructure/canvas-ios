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

#import "CKIClient+CKIUser.h"
#import "CKIUser.h"
#import "CKICourse.h"
#import "CKIEnrollment.h"

@implementation CKIClient (CKIUser)

- (RACSignal *)fetchUsersForContext:(id <CKIContext>)context
{
    return [self fetchUsersWithParameters:@{@"include" : @[@"avatar_url", @"enrollments"]} context:context];
}

- (RACSignal *)fetchUsersWithParameters:(NSDictionary *)parameters context:(id <CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"users"];
    return [[self fetchResponseAtPath:path parameters:parameters modelClass:[CKIUser class] context:context] map:^id(NSArray *users) {
        return [users.rac_sequence map:^id(CKIUser *user) {
            [user.enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
                enrollment.context = context;
            }];

            return user;
        }].array;
    }];
}

- (RACSignal *)fetchStudentsForContext:(id<CKIContext>)context {
    return [self fetchUsersWithParameters:@{@"include" : @[@"avatar_url", @"enrollments"], @"enrollment_type": @"student"} context:context];
}

- (RACSignal *)fetchCurrentUser
{
    if (self.accessToken == nil) {
        return [RACSignal empty];
    }
    
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"users/self/profile"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIUser class] context:nil];
}

@end
