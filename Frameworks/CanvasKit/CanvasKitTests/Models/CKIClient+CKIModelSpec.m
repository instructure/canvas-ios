//
//  CKIModel+NetworkingSpec.m
//  CanvasKit
//
//  Created by derrick on 11/5/13.
//  Copyright 2013 Instructure. All rights reserved.
//

#import "Kiwi.h"
#import "CKIClient+TestingClient.h"
#import "CKIClient+CKIModel.h"
#import "CKIModel.h"

SPEC_BEGIN(CKIModel_NetworkingSpec)

describe(@"A CKIModel", ^{
    CKIClient *testClient = [CKIClient testClient];
    context(@"when fetching a model by ID", ^{
        CKIModel *model = [CKIModel modelWithID:@"foo"];
        it(@"should call the path method", ^{
            [testClient returnResponseObject:@{@"id": @(1234)} forPath:@"path"];
            [[model should] receive:@selector(path) andReturn:@"path"];
            [testClient refreshModel:model success:nil failure:nil];
            [[model.id should] equal:@"1234"];
        });
    });
});
SPEC_END
