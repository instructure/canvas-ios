//
//  CKIClient+CKIPage.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient+CKIPage.h"
#import "CKIPage.h"
#import "CKICourse.h"

@implementation CKIClient (CKIPage)

- (RACSignal *)fetchPagesForContext:(id<CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"pages"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPage class] context:context];
}

- (RACSignal *)fetchPage:(NSString *)pageID forContext:(id<CKIContext>)context
{
    NSString * path = [context.path stringByAppendingPathComponent:@"pages"];
    path = [path stringByAppendingPathComponent:pageID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPage class] context:context];
}

- (RACSignal *)fetchFrontPageForContext:(id<CKIContext>)context
{
    NSString * path = [context.path stringByAppendingPathComponent:@"front_page"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPage class] context:context];
}

@end
