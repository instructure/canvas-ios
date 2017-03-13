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

#import "CKIUser.h"

SPEC_BEGIN(CKIUserSpec)

registerMatchers(@"CKI");

describe(@"A user", ^{
    context(@"when created from JSON", ^{
        NSDictionary *json = loadJSONFixture(@"user");
        CKIUser *user = [CKIUser modelFromJSONDictionary:json];
        
        it(@"gets the ID", ^{
            [[user.id should] equal:@"1"];
        });
        it(@"gets the name", ^{
            [[user.name should] equal:@"Sheldon Cooper"];
        });
        it(@"gets sortable name", ^{
            [[user.sortableName should] equal:@"Cooper, Sheldon"];
        });
        it(@"gets the short name", ^{
            [[user.shortName should] equal:@"Shelly"];
        });
        it(@"gets the SIS user ID", ^{
            [[user.sisUserID should] equal:@"scooper"];
        });
        it(@"gets the login ID", ^{
            [[user.loginID should] equal:@"sheldon@caltech.example.com"];
        });
        it(@"gets the email", ^{
            [[user.email should] equal:@"sheldon@caltech.example.com"];
        });
        it(@"gets the avatar url", ^{
            NSURL *url = [NSURL URLWithString:@"http://instructure.com/sheldon.png"];
            [[user.avatarURL should] equal:url];
        });
        it(@"gets the locale", ^{
            [[user.locale should] equal:@"tlh"];
        });
        it(@"gets the last login time", ^{
            [[user.lastLogin should] equalISO8601String:@"2012-05-30T17:45:25Z"];
        });
        it(@"gets the time zone", ^{
            [[user.timeZone should] equal:@"America/Denver"];
        });
    });
});

SPEC_END
