//
//  CKIClient+CKIFileSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 10/9/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKIClient+TestingClient.h"
#import "CKIClient+CKIFile.h"
#import "CKIFile.h"

SPEC_BEGIN(CKIClient_CKIFileSpec)

describe(@"A CKIFile", ^{
    context(@"when fetching a single file", ^{
        CKIClient *testClient = [CKIClient testClient];
        NSString *testPath = @"/api/v1/files/123";
        
        it(@"should call the CKIClient helper with the correct path", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchFile:@"123" success:nil failure:nil];
        });
    });
});

SPEC_END