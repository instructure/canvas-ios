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

#import "Kiwi.h"
#import "Helpers.h"
#import "CKIISO8601DateMatcher.h"

#import "CKIDiscussionTopic.h"
#import "CKILockInfo.h"
#import "CKIAttachment.h"


SPEC_BEGIN(CKIDiscussionTopicSpec)

describe(@"a discussion topic", ^{
    context(@"when created from a fixture", ^{
        NSDictionary *json = loadJSONFixture(@"discussion_topic");
        CKIDiscussionTopic *topic = [CKIDiscussionTopic modelFromJSONDictionary:json];
        
        it(@"gets the title", ^{
            [[topic.title should] equal:@"Topic 1"];
        });
        
        it(@"gets the message", ^{
            [[topic.messageHTML should] equal:@"<p>content here</p>"];
        });
        
        it(@"gets the htmlURL", ^{
            [[topic.htmlURL should] equal:[NSURL URLWithString:@"https://<canvas>/courses/1/discussion_topics/2"]];
        });
        
        it(@"gets the postedAt date", ^{
            [[topic.postedAt should] equalISO8601String:@"2037-07-21T13:29:31Z"];
        });
        
        it (@"gets the lastRepyAt date", ^{
            [[topic.lastReplyAt should] equalISO8601String:@"2037-07-28T19:38:31Z"];
        });
        
        it (@"gets the require initial post", ^{
            [[theValue(topic.requireInitialPost) should] beTrue];
        });
        
        it (@"gets the user can see post value", ^{
            [[theValue(topic.userCanSeePosts) shouldNot] beTrue];
        });
        
        it (@"get the subentryCount", ^{
            [[theValue(topic.subentryCount) should] equal:@(3)];
        });
        
        it (@"get the read state", ^{
            [[theValue(topic.isRead) should] beTrue];
        });
        
        it (@"get the unreadCount", ^{
            [[theValue(topic.unreadCount) should] equal:@(5)];
        });

        it (@"get the subscription status", ^{
            [[theValue(topic.isSubscribed) should] beTrue];
        });
        
        it (@"get the subscription hold", ^{
            [[theValue(topic.subscriptionHold) should] equal:@(CKIDiscussionTopicSubscriptionHoldNotInGroup)];
        });

        it (@"get the assignment ID", ^{
            [[topic.assignmentID should] equal:@"847"];
        });
        
        it (@"get the delayed post date", ^{
            [[topic.delayedPostAt should] equalISO8601String:@"2037-07-21T13:29:31Z"];
        });

        it (@"get the published status", ^{
            [[theValue(topic.isPublished) should] equal:@YES];
        });
        
        it (@"get the lock date", ^{
            [[topic.lockAt should] equalISO8601String:@"2037-07-21T13:29:31Z"];
        });

        it (@"get the locked status", ^{
            [[theValue(topic.isLocked) shouldNot] beTrue];
        });

        it (@"isPinned", ^{
            [[theValue(topic.isPinned) shouldNot] beTrue];
        });
        
        it (@"locked for user", ^{
            [[theValue(topic.isLockedForUser) should] beTrue];
        });
        
        it (@"should have the lock info", ^{
            [[topic.lockInfo.class should] equal:[CKILockInfo class]];
        });

        it (@"should get the lock explanation", ^{
            [[topic.lockExplanation should] equal:@"This discussion is locked until September 1 at 12:00am"];
        });

        it (@"user name", ^{
            [[topic.userName should] equal:@"User Name"];
        });

        it (@"should get children topic ids", ^{
            [[topic.childrenTopicIDs should] equal:@[@"5", @"7", @"10"]];
        });

        it (@"rootTopicID", ^{
            [[topic.rootTopicID should] equal:@"1236"];
        });
        
        it (@"podcast url", ^{
            [[topic.podcastURL should] equal:[NSURL URLWithString:@"/feeds/topics/1/enrollment_1XAcepje4u228rt4mi7Z1oFbRpn3RAkTzuXIGOPe.rss"]];
        });

        it (@"get the type", ^{
            [[theValue(topic.type) should] equal:@(CKIDiscussionTopicTypeSideComment)];
        });

        it (@"get the attachments", ^{
            [[[topic.attachments[0] class] should] equal:[CKIAttachment class]];
        });


        it (@"get the attachment permissions", ^{
            [[theValue(topic.canAttachPermission) should] beTrue];
        });

    });
});

SPEC_END
