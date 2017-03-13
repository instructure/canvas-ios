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
#import "CKIClient+CKIQuiz.h"
#import "CKIQuiz.h"
#import "CKICourse.h"

SPEC_BEGIN(CKIClient_CKIQuizSpec)

describe(@"A CKIQuiz", ^{
    CKIClient *testClient = [CKIClient testClient];
    id course = [CKICourse mock];
    [course stub:@selector(path) andReturn:@"/api/v1/courses/1"];
    
    context(@"when fetching a quiz", ^{
        NSString *testPath = @"/api/v1/courses/1/quizzes/2";
        [testClient returnResponseObject:@{} forPath:testPath];
        
        it(@"should call the CKIClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchQuiz:@"2" forCourse:course success:nil failure:nil];
        });
    });
    
    context(@"when fetching quizzes for a course", ^{
        NSString *testPath = @"/api/v1/courses/1/quizzes";
        [testClient returnResponseObject:@{} forPath:testPath];
        
        it(@"should call the CKIClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchQuizzesForCourse:course success:nil failure:nil];
        });
    });
});


SPEC_END