//
//  CKIClient+CKIModule.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKICourse;
@class CKIModule;
@class RACSignal;

@interface CKIClient (CKIModule)

/**
 Fetch all the modules for a given course.
 
 @param course the course that the modules are in
 @param success the block to be executed if the API call succeeds
 @param failure the block to be executed if the API call fails
 */
- (RACSignal *)fetchModulesForCourse:(CKICourse *)course;

/**
 Fetch a specific module for a course.
 
 @param course the course that the module is in
 @param success the block to be executed if the API call succeeds
 @param failure the block to be executed if the API call fails
 */
- (RACSignal *)fetchModuleWithID:(NSString *)moduleID forCourse:(CKICourse *)course;

@end
