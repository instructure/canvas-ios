//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
