//
//  CKIServiceSpec.m
//  CanvasKit
//
//  Created by Miles Wright on 10/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Helpers.h"

#import "CKIService.h"

SPEC_BEGIN(CKIServiceSpec)

describe(@"A service", ^{
    
    context(@"when created from service.json", ^{
        NSDictionary *json = loadJSONFixture(@"service");
        CKIService *service = [CKIService modelFromJSONDictionary:json];
        
        it(@"gets domain", ^{
            NSURL *url = [NSURL URLWithString:@"kaltura.example.com"];
            [[service.domain should] equal:url];
        });
        it(@"gets enabled", ^{
            [[theValue(service.enabled) should] beTrue];
        });
        it(@"gets partner id", ^{
            [[service.partnerID should] equal:@"123456"];
        });
        it(@"gets resource domain", ^{
            NSURL *url = [NSURL URLWithString:@"cdn.kaltura.example.com"];
            [[service.resourceDomain should] equal:url];
        });
        it(@"gets rmtp domain", ^{
            NSURL *url = [NSURL URLWithString:@"rmtp.example.com"];
            [[service.rmtpDomain should] equal:url];
        });
    });
});

SPEC_END