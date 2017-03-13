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