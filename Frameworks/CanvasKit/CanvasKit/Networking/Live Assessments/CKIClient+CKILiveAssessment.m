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

#import "CKIClient+CKILiveAssessment.h"
#import "CKILiveAssessment.h"
#import "CKICourse.h"
@import ReactiveObjC;

@implementation CKIClient (CKILiveAssessment)

- (RACSignal *)createLiveAssessments:(NSArray *)assessments forCourseID:(NSString *)courseID
{
    NSArray *json = [[NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKILiveAssessment class]] reverseTransformedValue:assessments];
    
    json = [json.rac_sequence map:^id(NSDictionary *dictionary) {
        NSMutableDictionary *removeID = [dictionary mutableCopy];
        [removeID removeObjectForKey:@"id"];
        return removeID;
    }].array;
    
    NSString *path = [[[CKIRootContext.path stringByAppendingPathComponent:@"courses"] stringByAppendingPathComponent:courseID] stringByAppendingPathComponent:@"live_assessments"];
    
    RACSignal *createAssessments = [self createModelAtPath:path parameters:@{[CKILiveAssessment keyForJSONAPIContent]: json} modelClass:[CKILiveAssessment class] context:CKIRootContext];
    return createAssessments;

}

- (RACSignal *)createLiveAssessments:(NSArray *)assessments {
    
    NSMutableDictionary *assessmentsByCourseID = [NSMutableDictionary dictionary];
    for (CKILiveAssessment *assessment in assessments) {
        NSString *courseID = ((CKICourse *)assessment.context).id;
        if (courseID == nil) {
            continue; // prevent a crash
        }
        NSMutableArray *assessmentsForCourse = assessmentsByCourseID[courseID];
        if (!assessmentsForCourse) {
            assessmentsForCourse = [NSMutableArray array];
            assessmentsByCourseID[courseID] = assessmentsForCourse;
        }
        [assessmentsForCourse addObject:assessment];
    }
    
    return [assessmentsByCourseID.rac_sequence.signal flattenMap:^(RACTuple *keyAndValue) {
        return [self createLiveAssessments:keyAndValue.second forCourseID:keyAndValue.first];
    }];
}
@end
