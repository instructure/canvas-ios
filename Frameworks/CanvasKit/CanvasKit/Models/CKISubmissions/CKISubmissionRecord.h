//
//  CKISubmissionRecord.h
//  CanvasKit
//
//  Created by Brandon Pluim on 9/5/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CanvasKit.h"
#import "CKIAssignment.h"
#import "CKISubmission.h"

@interface CKISubmissionRecord : CKISubmission

/**
 Comments left by graders. An array of CKISubmissionComment objects.
 */
@property (nonatomic, copy) NSArray *comments;

/**
 * An array of CKISubmissions history of submissions for this particular
 * user on this particular assignment, in order of least to most recent.
 */
@property (nonatomic, copy) NSArray *submissionHistory;

/**
 * RubricAssessment associated with submission, nil if no assessment
 */
@property (nonatomic, copy) CKIRubricAssessment *rubricAssessment;

@property (nonatomic) CKIAssignment *context;

- (BOOL)isDummySubmission;

- (CKISubmission *)defaultAttempt;

@end
