//
//  RubricViewController.h
//  iCanvas
//
//  Created by Mark Suman on 2/17/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKSubmission, CKAssignment, CKCanvasAPI, CKContextInfo;

@interface RubricViewController : UIViewController

/** @name Initializers */

- (id)init;

/**
 Designated initializer.
 */
- (id)initWithSubmission:(CKSubmission *)aSubmission;

/** @name Required properties */

/**
 The canvas API is required unless the assignment and submission
 are both provided.
 */
@property CKCanvasAPI *canvasAPI;

/**
 The assignment id may be provided, if the assignment is not
 available in the contstructing context.
 */
@property (nonatomic) uint64_t assignmentId;

/**
 If the assignmentId is provided, then the contextInfo must
 also be provided.
 */
@property CKContextInfo *contextInfo;

/**
 Either the assignment or the assignment id must be provided.
 */
@property (nonatomic) CKAssignment *assignment;

/** @name Optional properties */

/**
 The submission may be provided if it is available in the
 constructing context.
 */
@property (nonatomic) CKSubmission *submission;

@property (nonatomic, readonly) UITableView *rubricTableView;
@end
