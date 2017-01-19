//
//  CKIClient+CKITab.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import ReactiveObjC;

#import "CKIClient+CKITab.h"
#import "CKITab.h"
#import "CKICourse.h"
#import "CKIGroup.h"

@implementation CKIClient (CKITab)

- (RACSignal *)fetchTabsForContext:(id<CKIContext>)context
{
    NSString *path = [[context path] stringByAppendingPathComponent:@"tabs"];
    return [self fetchResponseAtPath:path parameters:@{@"include": @[@"external"]} modelClass:[CKITab class] context:context];
}

@end
