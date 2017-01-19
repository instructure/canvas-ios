//
//  CKIClient+CKIServiceSpec.m
//  CanvasKit
//
//  Created by Miles Wright on 10/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKIClient+TestingClient.h"
#import "CKIClient+CKIService.h"
#import "CKIService.h"

SPEC_BEGIN(CKIClient_CKIServiceSpec)

describe(@"A CKIService", ^{
    
    context(@"when fetching a service", ^{
        CKIClient *testClient = [CKIClient testClient];
        NSString *testPath = @"/api/v1/services/kaltura";
        [testClient returnResponseObject:@{} forPath:testPath];
        
        it(@"should call the CKIClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchServiceSuccess:nil failure:nil];
        });
    });
});


SPEC_END