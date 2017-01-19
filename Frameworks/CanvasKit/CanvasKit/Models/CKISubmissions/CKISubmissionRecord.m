//
//  CKISubmissionRecord.m
//  CanvasKit
//
//  Created by Brandon Pluim on 9/5/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKISubmissionRecord.h"

#import "CKISubmissionComment.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "CKIMediaComment.h"

@implementation CKISubmissionRecord

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