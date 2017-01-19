//
//  CKIUserSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 10/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
