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
