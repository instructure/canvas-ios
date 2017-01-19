//
//  CKIClient+CKIUserSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 10/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKIClient+TestingClient.h"
#import "CKICourse.h"
#import "CKIClient+CKIUser.h"
#import "CKIUser.h"

SPEC_BEGIN(CKIClient_CKIUserSpec)

describe(@"A CKIUser", ^{
    CKIClient *testClient = [CKIClient testClient];
    CKICourse *course = [CKICourse mock];
    [course stub:@selector(id) andReturn:@"123"];
    [course stub:@selector(path) andReturn:@"/api/v1/courses/123"];
    
    context(@"when fetching all users for a course", ^{
        NSString *testPath = @"/api/v1/courses/123/users";
        
        it(@"should call the CKIClient helper method with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchUsersForCourse:course success:nil failure:nil];
        });
    });
    context(@"when searching for users in a course", ^{
        NSString *testPath = @"/api/v1/courses/123/search_users";
        
        it(@"should call the CKIClient helper method with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchUsersMatchingSearchTerm:@"sheldon" course:course success:nil failure:nil];
        });
    });
});

SPEC_END
