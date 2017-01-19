//
//  CKITodoItem+NetworkinSpec.m
//  CanvasKit
//
//  Created by nlambson on 11/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKIClient+TestingClient.h"
#import "CKIClient+CKITodoItem.h"
#import "CKICourse.h"

SPEC_BEGIN(CKIClient_CKITodoItemSpec)

describe(@"A CKITodoItem", ^{
    CKIClient *testClient = [CKIClient testClient];
    
    CKICourse *course = [CKICourse mock];
    [course stub:@selector(id) andReturn:@"123"];
    [course stub:@selector(path) andReturn:@"/api/v1/courses/123"];
    
    context(@"when fetching the current user's course-specific todo items", ^{
        NSString *testPath = @"/api/v1/courses/123/todo";
        [testClient returnResponseObject:@{} forPath:testPath];
        
        it(@"should call the CKIClient helper method with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            
            [testClient fetchTodoItemsForCourse:course success:nil failure:nil];
        });
    });
    
    context(@"when fetching the current user's list of todo items, as seen on the user dashboard", ^{
        NSString *testPath = @"/api/v1/users/self/todo";
        [testClient returnResponseObject:@[] forPath:testPath];
        
        it(@"should call the CKICLient helper method with the correct path", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            
            [testClient fetchTodoItemsForCurrentUserWithSuccess:nil failure:nil];
        });
    });
});

SPEC_END