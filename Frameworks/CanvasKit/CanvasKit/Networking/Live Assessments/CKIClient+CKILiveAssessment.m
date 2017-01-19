//
//  CKIClient+CKILiveAssessment.m
//  CanvasKit
//
//  Created by Derrick Hathaway on 6/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
