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

#import "CKISubmissionRecord.h"

#import "CKISubmissionComment.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "CKIMediaComment.h"

@implementation CKISubmissionRecord

@dynamic context;

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"comments": @"submission_comments",
                               @"submissionHistory" : @"submission_history",
                               @"rubricAssessment" : @"rubric_assessment"
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)commentsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKISubmissionComment class]];
}

+ (NSValueTransformer *)submissionHistoryJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKISubmission class]];
}

+ (NSValueTransformer *)rubricAssessmentJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIRubricAssessmentTransformerName];
}

- (BOOL)isDummySubmission {
    return self.attempt == 0;
}

- (CKISubmission *)defaultAttempt {
    if (![self.submissionHistory count]) {
        return nil;
    }
    
    NSArray *sortedAttempts = [self.submissionHistory sortedArrayUsingComparator:^NSComparisonResult(CKISubmission *submission1, CKISubmission *submission2) {
        return [@(submission2.attempt) compare:@(submission1.attempt)];
    }];
    return sortedAttempts.firstObject;
}

@end
