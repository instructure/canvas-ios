//
//  CKIClient+CKIGroupSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 10/3/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKIClient+TestingClient.h"
#import "CKIClient+CKIGroup.h"
#import "CKIGroup.h"
#import "CKICourse.h"

SPEC_BEGIN(CKIClient_CKIGroupSpec)

describe(@"A CKIGroup", ^{
    CKIClient *testClient = [CKIClient testClient];
    
    context(@"when fetching a group", ^{
        NSString *testPath = @"/api/v1/groups/1";
        [testClient returnResponseObject:@{} forPath:testPath];
        
        it(@"should call the CKIClient helper with correct path", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchGroup:@"1" success:nil failure:nil];
        });
    });
    
    context(@"when fetching the current user's groups", ^{
        NSString *testPath = @"/api/v1/self/groups";
        [testClient returnResponseObject:@[] forPath:testPath];
        
        it(@"should call the CKIClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath,any(),any(),any(),any(),any()];
            [testClient fetchGroupsForLocalUserWithSuccess:nil failure:nil];
        });
    });
    
    context(@"when fetching groups for an account", ^{
        NSString *testPath = @"/api/v1/accounts/1/groups";
        [testClient returnResponseObject:@[] forPath:testPath];
        
        it(@"should call the CKIClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath,any(),any(),any(),any(),any()];
            [testClient fetchGroupsForAccount:@"1" success:nil failure:nil];
        });
    });
    
    context(@"when fetching groups for an account", ^{
        NSString *testPath = @"/api/v1/courses/123/groups";
        [testClient returnResponseObject:@[] forPath:testPath];
        id course = [CKICourse mock];
        [course stub:@selector(id) andReturn:@"123"];
        
        it(@"should call the CKIClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath,any(),any(),any(),any(),any()];
            [testClient fetchGroupsForCourse:course success:nil failure:nil];
        });
    });
});

SPEC_END