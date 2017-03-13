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
#import "CKIClient+CKIModuleItem.h"
#import "CKIModuleItem.h"
#import "CKIModule.h"

SPEC_BEGIN(CKIClient_CKIModuleItemSpec)

describe(@"A CKIModuleItem", ^{
    CKIClient *testClient = [CKIClient testClient];
    CKIModule *module = [CKIModule mock];
    [module stub:@selector(id) andReturn:@"456"];
    [module stub:@selector(path) andReturn:@"/api/v1/courses/123/modules/456"];
    
    context(@"when fetching a single module item", ^{
        NSString *testPath = @"/api/v1/courses/123/modules/456/items/789";
        [testClient returnResponseObject:@{} forPath:testPath];
        
        it(@"should call the CKIClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any()];
            [testClient fetchModuleItem:@"789" forModule:module success:nil failure:nil];
        });
    });
    
    context(@"when fetching a page of module items", ^{
        NSString *testPath = @"/api/v1/courses/123/modules/456/items";
        [testClient returnResponseObject:@[] forPath:testPath];
        
        it(@"should call the CKIlClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchModuleItemsForModule:module success:nil failure:nil];
        });
    });
});

SPEC_END