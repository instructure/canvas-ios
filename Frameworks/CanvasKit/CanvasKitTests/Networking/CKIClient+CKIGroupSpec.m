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