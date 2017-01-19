//
//  CKIClient+CKIExternalTool.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKICourse;
@class CKIExternalTool;
@class RACSignal;

@interface CKIClient (CKIExternalTool)

/**
 Fetches all of the external tools for a course
 */
- (RACSignal *)fetchExternalToolsForCourse:(CKICourse *)course;

/**
 Get a sessionless launch url for an external tool with id.
 */
- (RACSignal *)fetchSessionlessLaunchURLWithURL:(NSString *)url course:(CKICourse *)course;

/**
 Get a single external tool
 */
- (RACSignal *)fetchExternalToolForCourseWithExternalToolID:(NSString *)externalToolID course:(CKICourse *)course;

@end
