//
//  CKIClient+CKICourseSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 10/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKIClient+TestingClient.h"
#import "CKIClient+CKICourse.h"
#import "CKICourse.h"

SPEC_BEGIN(CKIClient_CKICourseSpec)

describe(@"A CKICourse", ^{
    context(@"when fetching courses for the a user", ^{
        CKIClient *testClient = [CKIClient testClient];
        NSString *testPath = @"/api/v1/courses";
        [testClient returnResponseObject:@[] forPath:testPath];
        
        it(@"should call the CKIClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchCoursesForCurrentUserWithSuccess:nil failure:nil];
        });
    });
});

SPEC_END