//
//  CKIGroupSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 10/1/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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