//
//  CKAssignment.h
//  CanvasKit
//
//  Created by Zach Wily on 5/17/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKSubmissionAttempt.h"
#import "CKContentLock.h"
#import "CKModelObject.h"

typedef enum {
    CKAssignmentTypeAssignment,
    CKAssignmentTypeDiscussion,
    CKAssignmentTypeQuiz,
    CKAssignmentTypeAttendance,
    CKAssignmentTypeExternalTool,
    CKAssignmentTypeNotGraded
} CKAssignmentType;

typedef enum {
    CKAssignmentScoringTypePoints,
    CKAssignmentScoringTypePercentage,
    CKAssignmentScoringTypePassFail,
    CKAssignmentScoringTypeLetter
} CKAssignmentScoringType;

@class CKCanvasAPI, CKCourse, CKSubmission, CKStudent, CKRubric, CKDiscussionTopic;

@interface CKAssignment : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, assign) CKAssignmentType type;
@property (nonatomic, strong) NSString *name;
@property uint64_t courseIdent;
@property (nonatomic, weak) CKCourse *course;
@property (nonatomic, copy) NSString *assignmentDescription;
@property (nonatomic, strong) NSDate *dueDate;
@property (strong, nonatomic, readonly) NSMutableDictionary *submissions;
@property (nonatomic, strong) CKRubric *rubric;
@property (nonatomic, assign) CKAssignmentScoringType scoringType;
@property (nonatomic, assign) double pointsPossible;
@property (nonatomic, assign) uint64_t assignmentGroupId;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, strong) CKDiscussionTopic *discussionTopic;
@property BOOL useRubricForGrading;
@property (nonatomic, assign) CKSubmissionType submissionTypes; //bitfield
@property (nonatomic) NSInteger needsGradingCount;
@property (nonatomic) BOOL anonymousSubmissions;
@property (nonatomic, strong) NSArray *allowedExtensions;
@property (nonatomic, assign) uint64_t quizIdent;
@property (nonatomic) NSURL *url;
@property (readonly) CKContentLock *contentLock;

- (id)initWithInfo:(NSDictionary *)info;

- (void)updateWithInfo:(NSDictionary *)info;

+ (CKAssignmentType)assignmentTypeForSubmissionsTypes:(NSArray *)submissionTypeStrings;

// Makes sure the provided extension is allowed by this assignment for submissions
- (BOOL)allowsExtension:(NSString *)extension;
// For informing the user that they're trying to submit a file with an unpermitted extension
- (NSString *)notAllowedAlertTitle:(NSString *)extension;
- (NSString *)notAllowedAlertMessage;

- (NSComparisonResult)comparePosition:(CKAssignment *)other;

- (NSString *)gradeStringForSubmission:(CKSubmission *)submission;
@end

@interface CKAssignment (SpeedGrader)
- (id)initWithInfo:(NSDictionary *)info andCourse:(CKCourse *)course __attribute__((deprecated("Use -setCourse:")));
- (void)updateNeedsGradingCount;
- (CKSubmission *)submissionForStudent:(CKStudent *)student;
@end
