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

#import "CKIActivityStreamConversationItem.h"

SPEC_BEGIN(CKIActivityStreamConversationItemSpec)

registerMatchers(@"CKI");

describe(@"A dicussion topic activity stream item", ^{
    context(@"when created from json fixture", ^{
        NSDictionary *json = loadJSONFixture(@"activity_stream_conversation_item");
        CKIActivityStreamConversationItem *streamItem = [CKIActivityStreamConversationItem modelFromJSONDictionary:json];
        
        it(@"gets boolean value for private", ^{
            [[theValue(streamItem.isPrivate) should] equal:theValue(YES)];
        });
        
        it(@"gets the participant count", ^{
            [[theValue(streamItem.participantCount) should] equal:theValue(3)];
        });
    });
});

SPEC_END