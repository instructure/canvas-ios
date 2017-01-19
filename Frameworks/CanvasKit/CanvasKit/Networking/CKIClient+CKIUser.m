//
//  CKIClient+CKIUser.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
