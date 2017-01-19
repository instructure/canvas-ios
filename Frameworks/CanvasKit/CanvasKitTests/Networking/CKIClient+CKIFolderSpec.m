//
//  CKIClient+CKIFolderSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 10/14/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKIClient+TestingClient.h"
#import "CKIClient+CKIFolder.h"
#import "CKICourse.h"
#import "CKIFolder.h"

SPEC_BEGIN(CKIClient_CKIFolderSpec)

context(@"The CKIFolder class", ^{
    CKIClient *testClient = [CKIClient testClient];
    
    describe(@"when fetching a single folder", ^{
        NSString *testPath = @"/api/v1/folders/123";
        
        it(@"should call the correct helper method", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchFolder:@"123" success:nil failure:nil];
        });
    });
    describe(@"when fetching the root folder for a course", ^{
        NSString *testPath = @"/api/v1/courses/123/folders/root";
        CKICourse *course = [CKICourse mock];
        [course stub:@selector(path) andReturn:@"/api/v1/courses/123"];
        
        it(@"should call the correct helper method", ^{
            [[testClient should] receive:@selector(fetchModelAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchRootFolderForCourse:course success:nil failure:nil];
        });
    });
});

context(@"A CKIFolder instance", ^{
    CKIClient *testClient = [CKIClient testClient];
    
    CKIFolder *folder = [CKIFolder new];
    NSURL *fileURL = [NSURL URLWithString:@"http://blah.instructure.com/api/v1/folders/123/files"];
    NSURL *folderURL = [NSURL URLWithString:@"http://blah.instructure.com/api/v1/folders/123/folders"];
    folder.filesURL = fileURL;
    folder.foldersURL = folderURL;
    
    describe(@"when fetching its folders", ^{
        NSString *testPath = folderURL.relativeString;
        
        it(@"should call the correct helper method", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchFoldersForFolder:folder success:nil failure:nil];
        });
    });
    
    describe(@"when fetching its files", ^{
        NSString *testPath = fileURL.relativeString;
        
        it(@"should call the correct helper method", ^{
            [[testClient should] receive:@selector(fetchPagedResponseAtPath:parameters:modelClass:context:success:failure:) withArguments:testPath, any(), any(), any(), any(), any()];
            [testClient fetchFilesForFolder:folder success:nil failure:nil];
        });
    });
});

SPEC_END
