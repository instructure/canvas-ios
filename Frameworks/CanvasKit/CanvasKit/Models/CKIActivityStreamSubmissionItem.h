//
//  CKIActivityStreamSubmissionItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIActivityStreamItem.h"

@interface CKIActivityStreamSubmissionItem : CKIActivityStreamItem

/**
 The ID of the submission.
 */
@property (nonatomic, copy) NSString *submissionID;

/**
 The ID of the assignment this submission pertains to.
 */
@property (nonatomic, copy) NSString *assignmentID;

@end
