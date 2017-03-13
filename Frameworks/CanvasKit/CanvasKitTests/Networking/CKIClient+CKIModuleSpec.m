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
#import "CKIClient+CKIModule.h"
#import "CKIModule.h"
#import "CKICourse.h"

SPEC_BEGIN(CKIClient_CKIModuleSpec)

describe(@"A CKIModule", ^{
    CKIClient *testClient = [CKIClient testClient];
    CKICourse *course = [CKICourse mock];
    [course stub:@selector(id) andReturn:@"123"];
    [course stub:@selector(path) andReturn:@"/api/v1/courses/123"];
    
    context(@"when fetching a single module", ^{
        NSString *testPath = @"/api/v1/courses/123/modules/1";
        [testClient returnResponseObject:@{} forPath:testPath];
        
        it(@"should call the CKIClient helper method with the correct path", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchModuleWithID:@"1" forCourse:course success:nil failure:nil];
        });
    });
    
    context(@"when fetching modules for a course", ^{
        NSString *testPath = @"/api/v1/courses/123/modules";
        [testClient returnResponseObject:@[] forPath:testPath];
        
        it(@"should call the CKICLient helper method with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(),any()];
            [testClient fetchModulesForCourse:course success:nil failure:nil];
        });
    });
});

SPEC_END