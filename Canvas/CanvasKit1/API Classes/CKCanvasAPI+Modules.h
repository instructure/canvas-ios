//
//  CKCanvasAPI+Modules.h
//  CanvasKit
//
//  Created by Jason Larsen on 3/25/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI.h"

@class CKModule;

@interface CKCanvasAPI (Modules)
- (void)fetchModulesForCourseID:(uint64_t)course pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block;
- (void)fetchModuleItemsForCourseID:(uint64_t)course moduleID:(uint64_t)module pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block;
@end
