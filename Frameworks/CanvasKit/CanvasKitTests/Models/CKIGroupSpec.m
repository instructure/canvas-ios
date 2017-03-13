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

#import "CKIGroup.h"

SPEC_BEGIN(CKIGroupSpec)

describe(@"The group", ^{
    context(@"when created from group.json", ^{
        NSDictionary *json = loadJSONFixture(@"group");
        CKIGroup *group = [CKIGroup modelFromJSONDictionary:json];
        
        it(@"gets the id", ^{
            [[group.id should] equal:@"17"];
        });
        it(@"gets the description", ^{
            [[group.groupDescription should] equal:@"An awesome group about math"];
        });
        it(@"gets the public", ^{
            [[theValue(group.isPublic) should] beTrue];
        });
        it(@"gets the followed by user", ^{
            [[theValue(group.followedByUser) should] beTrue];
        });
        it(@"gets the member count", ^{
            [[theValue(group.membersCount) should] equal:theValue(7)];
        });
        it(@"gets the join level", ^{
            [[group.joinLevel should] equal:CKIGroupJoinLevelInvitationOnly];
        });
        it(@"gets the avatar URL", ^{
            NSURL *url = [NSURL URLWithString:@"https://instructure.com/files/avatar_image.png"];
            [[group.avatarURL should] equal:url];
        });
        it(@"gets the course ID", ^{
            [[group.courseID should] equal:@"3"];
        });
    });
});

SPEC_END