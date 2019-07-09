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
