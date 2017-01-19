//
//  CKIActivityStreamConversationItemSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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