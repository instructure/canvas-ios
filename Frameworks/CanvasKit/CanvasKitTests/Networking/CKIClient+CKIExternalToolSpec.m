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