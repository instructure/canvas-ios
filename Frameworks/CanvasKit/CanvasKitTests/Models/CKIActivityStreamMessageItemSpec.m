//
//  CKIActivityStreamMessageItemSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Helpers.h"
#import "CKIISO8601DateMatcher.h"

#import "CKIActivityStreamMessageItem.h"

SPEC_BEGIN(CKIActivityStreamMessageItemSpec)

registerMatchers(@"CKI");

describe(@"A dicussion topic activity stream item", ^{
    context(@"when created from json fixture", ^{
        NSDictionary *json = loadJSONFixture(@"activity_stream_message_item");
        CKIActivityStreamMessageItem *streamItem = [CKIActivityStreamMessageItem modelFromJSONDictionary:json];
        
        it(@"gets the notification category", ^{
            [[streamItem.notificationCategory should] equal:@"Assignment Graded"];
        });
    });
});

SPEC_END