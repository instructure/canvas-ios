//
//  CKIClient+CKILiveAssessmentResult.m
//  CanvasKit
//
//  Created by Derrick Hathaway on 6/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient+CKILiveAssessmentResult.h"
#import "CKILiveAssessment.h"
#import "CKILiveAssessmentResult.h"
@import ReactiveObjC;

@implementation CKIClient (CKILiveAssessmentResult)

- (RACSignal *)createResults:(NSArray *)results forLiveAssessment:(CKILiveAssessment *)assessment
{
    NSString *path = [assessment.path stringByAppendingPathComponent:@"results"];
    
    NSArray *json = [[NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKILiveAssessmentResult class]] reverseTransformedValue:results];
    
    json = [json.rac_sequence map:^id(NSDictionary *result) {
        NSMutableDictionary *updated = [result mutableCopy];
        [updated removeObjectForKey:@"id"];
        updated[@"links"] = @{@"user": [updated valueForKeyPath:@"links.user"]};
        return updated;
    }].array;
    
    return [self createModelAtPath:path parameters:@{[CKILiveAssessmentResult keyForJSONAPIContent]: json} modelClass:[CKILiveAssessmentResult class] context:assessment];
}

@end
