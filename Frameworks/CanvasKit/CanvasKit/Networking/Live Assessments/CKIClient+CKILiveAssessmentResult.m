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
