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
