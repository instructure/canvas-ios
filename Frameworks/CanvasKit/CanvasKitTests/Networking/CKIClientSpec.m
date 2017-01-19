//
//  CKIClientSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 10/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "CKIClient+TestingClient.h"
#import "CKIModel.h"

SPEC_BEGIN(CKIClientSpec)

describe(@"The CKIClient", ^{
    __block CKIClient *testClient;
    beforeEach(^{
        testClient = [CKIClient testClient];
    });
    
    context(@"when fetching a single model", ^{
        __block NSString *testPath;
        __block CKIModel *contxt;
        beforeEach(^{
            testPath = @"api/v1/models";
            contxt = [CKIModel modelFromJSONDictionary:@{@"id":@1}];
        });
        
        
        context(@"and there is an error", ^{
            __block BOOL ranFailureBlock = NO;
            __block BOOL ranSuccessBlock = NO;
            beforeEach(^{
                ranFailureBlock = NO;
                ranSuccessBlock = NO;
                [testClient returnErrorForPath:testPath];
                [testClient fetchModelAtPath:testPath parameters:nil modelClass:[CKIModel class] context:contxt success:^(CKIModel *model) {
                    ranSuccessBlock = YES;
                } failure:^(NSError *error) {
                    ranFailureBlock = YES;
                }];
            });
            
            it(@"should not run the success block", ^{
                [[theValue(ranSuccessBlock) shouldNot] beTrue];
            });
            it(@"should run the error block", ^{
                [[theValue(ranFailureBlock) should] beTrue];
            });
        });

        context(@"and there is no error", ^{
            __block BOOL ranSuccessBlock;
            __block BOOL ranFailureBlock;
            beforeEach(^{
                [testClient returnResponseObject:@{} forPath:testPath];
                ranSuccessBlock = NO;
                ranFailureBlock = NO;
                [testClient fetchModelAtPath:testPath parameters:nil modelClass:[CKIModel class] context:contxt success:^(CKIModel *model) {
                    ranSuccessBlock = YES;
                } failure:^(NSError *error) {
                    ranFailureBlock = YES;
                }];
            });
            
            
            it(@"should run the success block", ^{
                [[theValue(ranSuccessBlock) should] beTrue];
            });
            it(@"should not run the error block", ^{
                [[theValue(ranFailureBlock) shouldNot] beTrue];
            });
        });
        
        context(@"and recieves a model", ^{
            __block CKIModel *fetchedModel;
            beforeEach(^{
                [testClient returnResponseObject:@{} forPath:testPath];
                [testClient fetchModelAtPath:testPath parameters:nil modelClass:[CKIModel class] context:contxt success:^(CKIModel *model) {
                    fetchedModel = model;
                } failure:nil];
            });
            
            
            it(@"should return model of the correct class", ^{
                [[fetchedModel should] beKindOfClass:[CKIModel class]];
            });
            it(@"should set the context", ^{
                [[contxt should] equal:fetchedModel.context];
            });
        });
    });
});

SPEC_END