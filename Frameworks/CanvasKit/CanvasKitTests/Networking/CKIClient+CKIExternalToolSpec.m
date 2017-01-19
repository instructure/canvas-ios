//
//  CKIClient+CKIExternalToolSpec.m
//  CanvasKit
//
//  Created by nlambson on 10/10/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKIClient+TestingClient.h"
#import "CKIClient+CKIExternalTool.h"
#import "CKIExternalTool.h"
#import "CKICourse.h"

SPEC_BEGIN(CKIClient_CKIExternalToolSpec)

describe(@"A CKIExternalTool", ^{
    CKICourse *course = [CKICourse mock];
    CKIClient *testClient = [CKIClient testClient];
    
    [course stub:@selector(id) andReturn:@"123"];
    [course stub:@selector(path) andReturn:@"/api/v1/courses/123"];
    
    context(@"when fetching all external tools for a course", ^{
        NSString *testPath = @"/api/v1/courses/123/external_tools";
        [testClient returnResponseObject:@[] forPath:testPath];
        
        it(@"should call the CKIClient helper method with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];

            [testClient fetchExternalToolsForCourse:course success:nil failure:nil];
        });
    
    });
    
    context(@"when fetching a sessionless launch url for an external tool with url", ^{
        NSString *testPath = @"/api/v1/courses/123/external_tools/sessionless_launch";
        [testClient returnResponseObject:@{} forPath:testPath];
        
        it(@"should call the CKIClient helper method with the correct path", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            
            [testClient fetchSessionlessLaunchURLWithURL:@"http://lti-tool-provider.herokuapp.com/lti_tool" andCourse:course success:nil failure:nil];
        });
    });
    
    context(@"when fetching a single external tool for a course with an external tool id", ^{
        NSString *testPath = @"/api/v1/courses/123/external_tools/24506";
        [testClient returnResponseObject:@{} forPath:testPath];
        
        it(@"should call the CKIClient helper method with the correct path", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];

            [testClient fetchExternalToolForCourseWithExternalToolID:@"24506" andCourse:course success:nil failure:nil];
        });
    });
    
});

SPEC_END