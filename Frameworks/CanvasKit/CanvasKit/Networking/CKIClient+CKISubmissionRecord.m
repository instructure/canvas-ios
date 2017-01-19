//
//  CKIClient+CKISubmissionRecord.m
//  CanvasKit
//
//  Created by Brandon Pluim on 9/5/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient+CKISubmissionRecord.h"

@import ReactiveObjC;
#import "CKIAssignment.h"
#import "CKISubmission.h"
#import "CKIRubricAssessment.h"
#import "CKISubmissionRecord.h"

static const NSString *CKISubmissionHistory = @"submission_history";
static const NSString *CKISubmissionComments = @"submission_comments";
static const NSString *CKISubmissionRubricAssessment = @"rubric_assessment";

static const NSString *CKISubmissionPutParameter = @"submission";
static const NSString *CKISubmissionPostedGradeParameter = @"posted_grade";
static const NSString *CKISubmissionRubricAssessmentParameter = @"rubric_assessment";

@implementation CKIClient (CKISubmissionRecord)

- (RACSignal *)fetchSubmissionRecordsForAssignment:(CKIAssignment *)assignment
{
    NSString *path = [assignment.path stringByAppendingPathComponent:@"submissions"];
    NSDictionary *parameters = @{@"include" : @[CKISubmissionHistory, CKISubmissionComments, CKISubmissionRubricAssessment]};
    return [self fetchResponseAtPath:path parameters:parameters modelClass:[CKISubmissionRecord class] context:assignment];
}

- (RACSignal *)fetchSubmissionRecordForAssignment:(CKIAssignment *)assignment forStudentWithID:(NSString *)studentID {
    NSString *path = [[assignment.path stringByAppendingPathComponent:@"submissions"] stringByAppendingPathComponent:studentID];
    NSDictionary *parameters = @{@"include" : @[CKISubmissionHistory, CKISubmissionComments, CKISubmissionRubricAssessment]};
    return [self fetchResponseAtPath:path parameters:parameters modelClass:[CKISubmissionRecord class] context:assignment];
}

- (RACSignal *)updateGrade:(NSString *)gradeString forSubmissionRecord:(CKISubmissionRecord *)submission {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (gradeString) {
        parameters[CKISubmissionPutParameter] = @{CKISubmissionPostedGradeParameter: gradeString};
    }
    if ([submission.rubricAssessment parametersDictionary]) {
        parameters[CKISubmissionRubricAssessmentParameter] = [submission.rubricAssessment parametersDictionary];
    }
    
    return [self updateModel:submission parameters:parameters];
}

- (RACSignal *)addComment:(NSString *)comment forSubmissionRecord:(CKISubmissionRecord *)submission {
    return [self updateModel:submission parameters:@{@"comment": @{@"text_comment": comment}}];
}

@end
