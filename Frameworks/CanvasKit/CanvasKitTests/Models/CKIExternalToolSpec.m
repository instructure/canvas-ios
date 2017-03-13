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
#import "Helpers.h"
#import "CKIISO8601DateMatcher.h"

#import "CKIExternalTool.h"

SPEC_BEGIN(CKIExternalToolSpec)

registerMatchers(@"CKI");

describe(@"An External Tool", ^{
    
    context(@"when created from external_tool.json", ^{
        NSDictionary *json = loadJSONFixture(@"external_tool");
        CKIExternalTool *extTool = [CKIExternalTool modelFromJSONDictionary:json];
        
        it(@"gets consumer key", ^{
            [[extTool.consumerKey should] equal:@"test"];
        });
        it(@"gets created at", ^{
            [[extTool.createdAt should] equalISO8601String:@"2013-07-29T21:28:47Z"];
        });
        it(@"gets description", ^{
            [[extTool.description should] equal:@"This example LTI Tool Provider supports LIS Outcome pass-back and the content extension."];
        });
        it(@"gets domain", ^{
            NSURL *url = [NSURL URLWithString:@"lti-tool-provider.herokuapp.com"];
            [[extTool.domain should] equal:url];
        });
        it(@"gets id", ^{
            [[extTool.id should] equal:@"24506"];
        });
        it(@"gets name", ^{
            [[extTool.name should] equal:@"LTI Test Tool"];
        });
        it(@"gets updated at", ^{
            [[extTool.updatedAt should] equalISO8601String:@"2013-07-29T21:28:47Z"];
        });
        it(@"gets url", ^{
            NSURL *url = [NSURL URLWithString:@"http://lti-tool-provider.herokuapp.com/lti_tool"];
            [[extTool.url should] equal:url];
        });
        it(@"gets privacy level", ^{
            [[extTool.privacyLevel should] equal:@"public"];
        });
        it(@"gets custom fields", ^{
            [[extTool.customFields should] equal:@{@"key":@"value", @"key2":@"value2"}];
        });
        it(@"gets workflow state", ^{
            [[extTool.workflowState should] equal:@"public"];
        });
        it(@"gets vendor help link", ^{
            NSURL *url = [NSURL URLWithString:@"http://lti-tool-provider.herokuapp.com/lti_tool/help"];
            [[extTool.vendorHelpLink should] equal:url];
        });
        it(@"gets icon url", ^{
            NSURL *url = [NSURL URLWithString:@"http://lti-tool-provider.herokuapp.com/selector.png"];
            [[extTool.iconURL should] equal:url];
        });
    });
});

SPEC_END