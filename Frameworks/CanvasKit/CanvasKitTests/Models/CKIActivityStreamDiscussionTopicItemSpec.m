//
//  CKIActivityStreamDiscussionTopicItemSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Helpers.h"
#import "CKIISO8601DateMatcher.h"

#import "CKIActivityStreamDiscussionTopicItem.h"

SPEC_BEGIN(CKIActivityStreamDiscussionTopicItemSpec)

registerMatchers(@"CKI");

describe(@"A dicussion topic activity stream item", ^{
    context(@"when created from json fixture", ^{
        NSDictionary *json = loadJSONFixture(@"activity_stream_discussion_topic_item");
        CKIActivityStreamDiscussionTopicItem *streamItem = [CKIActivityStreamDiscussionTopicItem modelFromJSONDictionary:json];
        
        it(@"gets the total root discussion entries", ^{
            [[theValue(streamItem.totalRootDiscussionEntries) should] equal:theValue(5)];
        });
        
        it(@"gets the boolean for require initial post", ^{
            [[theValue(streamItem.requireInitialPost) should] equal:theValue(YES)];
        });
        
        it(@"gets gets the boolean for user has posted", ^{
            [[theValue(streamItem.userHasPosted) should] equal:theValue(YES)];
        });
    });
});

SPEC_END
