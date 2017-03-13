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

#import "CKIService.h"

SPEC_BEGIN(CKIServiceSpec)

describe(@"A service", ^{
    
    context(@"when created from service.json", ^{
        NSDictionary *json = loadJSONFixture(@"service");
        CKIService *service = [CKIService modelFromJSONDictionary:json];
        
        it(@"gets domain", ^{
            NSURL *url = [NSURL URLWithString:@"kaltura.example.com"];
            [[service.domain should] equal:url];
        });
        it(@"gets enabled", ^{
            [[theValue(service.enabled) should] beTrue];
        });
        it(@"gets partner id", ^{
            [[service.partnerID should] equal:@"123456"];
        });
        it(@"gets resource domain", ^{
            NSURL *url = [NSURL URLWithString:@"cdn.kaltura.example.com"];
            [[service.resourceDomain should] equal:url];
        });
        it(@"gets rmtp domain", ^{
            NSURL *url = [NSURL URLWithString:@"rmtp.example.com"];
            [[service.rmtpDomain should] equal:url];
        });
    });
});

SPEC_END