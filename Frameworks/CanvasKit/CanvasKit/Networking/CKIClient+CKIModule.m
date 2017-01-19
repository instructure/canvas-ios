//
//  CKIClient+CKIModule.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import ReactiveObjC;

#import "CKIClient+CKIModule.h"
#import "CKICourse.h"
#import "CKIModule.h"

@implementation CKIClient (CKIModule)

- (RACSignal *)fetchModulesForCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"modules"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIModule class] context:course];
}

- (RACSignal *)fetchModuleWithID:(NSString *)moduleID forCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"modules"];
    path = [path stringByAppendingPathComponent:moduleID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIModule class] context:course];
}

@end
