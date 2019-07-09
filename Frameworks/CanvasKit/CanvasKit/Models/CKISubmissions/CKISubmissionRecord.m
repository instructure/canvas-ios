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
