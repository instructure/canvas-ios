//
//  CKIClient+CKIExternalTool.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import ReactiveObjC;

#import "CKIClient+CKIExternalTool.h"
#import "CKIExternalTool.h"
#import "CKICourse.h"

@implementation CKIClient (CKIExternalTool)

- (RACSignal *)fetchExternalToolsForCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"external_tools"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIExternalTool class] context:course];
}

- (RACSignal *)fetchSessionlessLaunchURLWithURL:(NSString *)url course:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"external_tools/sessionless_launch"];
    
    NSDictionary *params = @{@"url":url};
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKIExternalTool class] context:course];
}

- (RACSignal *)fetchExternalToolForCourseWithExternalToolID:(NSString *)externalToolID course:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"external_tools"];
    path = [path stringByAppendingPathComponent:externalToolID];
    
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIExternalTool class] context:course];
}


@end
