//
//  CKIClient+CKIAssignment.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKIAssignment;
@class CKICourse;
@class RACSignal;

@interface CKIClient (CKIAssignment)

- (RACSignal *)fetchAssignmentsForContext:(id<CKIContext>)context;
- (RACSignal *)fetchAssignmentsForContext:(id<CKIContext>)context includeSubmissions:(BOOL)includeSubmissions;
- (RACSignal *)updateMutedForAssignment:(CKIAssignment *)assignment;

@end
