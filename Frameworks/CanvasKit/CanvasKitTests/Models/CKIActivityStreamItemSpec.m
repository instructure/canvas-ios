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

#import "CKIActivityStreamItem.h"
#import "CKIActivityStreamDiscussionTopicItem.h"
#import "CKIActivityStreamAnnouncementItem.h"
#import "CKIActivityStreamConversationItem.h"
#import "CKIActivityStreamMessageItem.h"
#import "CKIActivityStreamSubmissionItem.h"
#import "CKIActivityStreamConferenceItem.h"
#import "CKIActivityStreamCollaborationItem.h"

SPEC_BEGIN(CKIActivityStreamItemSpec)

registerMatchers(@"CKI");

describe(@"An activity stream item", ^{
    context(@"when created from json fixture", ^{
        NSDictionary *json = loadJSONFixture(@"activity_stream_item");
        CKIActivityStreamItem *streamItem = [CKIActivityStreamItem modelFromJSONDictionary:json];
        
        it(@"gets id", ^{
            [[streamItem.id should] equal:@"1234"];
        });
        
        it(@"gets the title", ^{
            [[streamItem.title should] equal:@"Stream Item Subject"];
        });
        
        it(@"gets the message", ^{
            [[streamItem.message should] equal:@"This is the body text of the activity stream item. It is plain-text, and can be multiple paragraphs."];
        });
        
        it(@"gets the course ID", ^{
            [[streamItem.courseID should] equal:@"1"];
        });
        
        it(@"gets the group ID", ^{
            [[streamItem.groupID should] equal:@"1"];
        });
        
        it(@"gets the created at date", ^{
            [[streamItem.createdAt should] equalISO8601String:@"2011-07-13T09:12:00Z"];
        });
        
        it(@"gets the updated at date", ^{
            [[streamItem.updatedAt should] equalISO8601String:@"2011-07-25T08:52:41Z"];
        });
        
        it(@"gets the canvas api endpoint URL", ^{
            NSURL *url = [NSURL URLWithString:@"http://canvas.instructure.com/api/v1/foo"];
            [[streamItem.url should] equal:url];
        });
        
        it(@"gets the canvas html URL", ^{
            NSURL *url = [NSURL URLWithString:@"http://canvas.instructure.com/api/v1/foo"];
            [[streamItem.htmlURL should] equal:url];
        });
        
        it(@"gets the read state", ^{
            [[theValue(streamItem.isRead) should] equal:theValue(YES)];
        });
    });
    context(@"transformer", ^{
        __block NSValueTransformer *transformer;
        beforeAll(^{
             transformer = [CKIActivityStreamItem activityStreamItemTransformer];
        });
        
        it(@"transforms discussion topics", ^{
            NSDictionary *json = loadJSONFixture(@"activity_stream_discussion_topic_item");
            id value = [transformer transformedValue:json];
            [[value should] beKindOfClass:[CKIActivityStreamDiscussionTopicItem class]];
        });
        it(@"transforms annoucnements", ^{
            NSDictionary *json = loadJSONFixture(@"activity_stream_announcement_item");
            id value = [transformer transformedValue:json];
            [[value should] beKindOfClass:[CKIActivityStreamAnnouncementItem class]];
        });
        it(@"transforms conversations", ^{
            NSDictionary *json = loadJSONFixture(@"activity_stream_conversation_item");
            id value = [transformer transformedValue:json];
            [[value should] beKindOfClass:[CKIActivityStreamConversationItem class]];
        });
        it(@"transforms messages", ^{
            NSDictionary *json = loadJSONFixture(@"activity_stream_message_item");
            id value = [transformer transformedValue:json];
            [[value should] beKindOfClass:[CKIActivityStreamMessageItem class]];
        });
        it(@"transforms submissions", ^{
            NSDictionary *json = loadJSONFixture(@"activity_stream_submission_item");
            id value = [transformer transformedValue:json];
            [[value should] beKindOfClass:[CKIActivityStreamSubmissionItem class]];
        });
        it(@"transforms conferences", ^{
            NSDictionary *json = loadJSONFixture(@"activity_stream_conference_item");
            id value = [transformer transformedValue:json];
            [[value should] beKindOfClass:[CKIActivityStreamConferenceItem class]];
        });
        it(@"transforms collaborations", ^{
            NSDictionary *json = loadJSONFixture(@"activity_stream_collaboration_item");
            id value = [transformer transformedValue:json];
            [[value should] beKindOfClass:[CKIActivityStreamCollaborationItem class]];
        });
    });
});

SPEC_END
