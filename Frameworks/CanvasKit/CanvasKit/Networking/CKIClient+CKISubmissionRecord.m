//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
