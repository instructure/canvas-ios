//
//  CKIAssignment.m
//  CanvasKit
//
//  Created by Jason Larsen on 8/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIAssignment.h"
#import "CKIRubricCriterion.h"
#import "CKICourse.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "CKISubmission.h"
#import "CKIRubric.h"
#import "CKIDiscussionTopic.h"

@interface CKIAssignment ()
@end

@implementation CKIAssignment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"position": @"position",
        @"descriptionHTML": @"description",
        @"dueAt": @"due_at",
        @"lockAt": @"lock_at",
        @"unlockAt": @"unlock_at",
        @"courseID": @"course_id",
        @"htmlURL": @"html_url",
        @"allowedExtensions": @"allowed_extensions",
        @"assignmentGroupID": @"assignment_group_id",
        @"automaticPeerReviews": @"automatic_peer_reviews",
        @"groupCategoryID": @"group_category_id",
        @"gradeGroupStudentsIndividually": @"grade_group_students_individually",
        @"needsGradingCount": @"needs_grading_count",
        @"peerReviewRequired": @"peer_reviews",
        @"peerReviewsAutomaticallyAssigned": @"automatic_peer_reviews",
        @"peerReviewsAutomaticallyAssignedCount": @"peer_review_count",
        @"peerReviewDueDate": @"peer_reviews_assign_at",
        @"submissionTypes": @"submission_types",
        @"discussionTopicID": @"discussion_topic_id",
        @"discussionTopic": @"discussion_topic",
        @"lockedForUser" : @"locked_for_user",
        @"pointsPossible" : @"points_possible",
        @"gradingType" : @"grading_type",
        @"rubricCriterion": @"rubric",
        @"rubric": @"rubric_settings",
        @"useRubricForGrading": @"use_rubric_for_grading",
        @"quizID": @"quiz_id",
        @"url": @"url",
        @"needsGradingCountBySection": @"needs_grading_count_by_section",
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)dueAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)lockAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)unlockAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)courseIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)htmlURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)assignmentGroupIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)groupCategoryIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)peerReviewDueDateJSONTransformer {
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)submissionJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id obj) {
        NSDictionary *submissionDictionary = obj;

        // chooses the first submission if it is an array (which is the case for observers)
        if ([obj isKindOfClass:[NSArray class]]) {
            submissionDictionary = [obj firstObject];
        }

        return [MTLJSONAdapter modelOfClass:[CKISubmission class] fromJSONDictionary:submissionDictionary error:nil];
    } reverseBlock:^id(CKISubmission *submission) {
        return submission != nil ? [MTLJSONAdapter JSONDictionaryFromModel:submission] : nil;
    }];
}

+ (NSValueTransformer *)discussionTopicIDJSONValueTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)discussionTopicJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKIDiscussionTopic class]];
}

+ (NSValueTransformer *)urlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)quizIDJSONTransformer {
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

#pragma mark - Rubric

/**
* Dealing with rubrics is special because we need to coalesce the rubric and rubric_settings
* keys together. The rubric key is an array of rubric criteria, and the rubric settings has the
* id, title, pointsPossible, etc.
*/

+ (NSValueTransformer *)rubricCriterionJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIRubricCriterion class]];
}

+ (NSValueTransformer *)rubricJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKIRubric class]];
}


#pragma mark - Needs Grading Count By Section

+ (NSValueTransformer *)needsGradingCountBySectionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *needsGradingCounts) {
        NSMutableDictionary *returnValue = [NSMutableDictionary new];
        for (NSDictionary *needsGradingCount in needsGradingCounts) {
            NSString *key = [needsGradingCount[@"section_id"] description];
            NSNumber *value = needsGradingCount[@"needs_grading_count"];
            
            returnValue[key] = value;
        }
        
        return returnValue;
        
    } reverseBlock:^id(NSDictionary *needsGradingCounts) {
        NSMutableArray *returnValue = [NSMutableArray new];
        
        for (NSString *key in needsGradingCounts.allKeys) {
            NSMutableDictionary *sectionWithGradingCount = [NSMutableDictionary new];
            sectionWithGradingCount[@"section_id"] = key;
            sectionWithGradingCount[@"needs_grading_count"] = needsGradingCounts[key];
            
            [returnValue addObject:sectionWithGradingCount];
        }
        
        return returnValue;
    }];
}


#pragma mark - Other Methods

- (NSString *)path
{
    return [[[self.context path] stringByAppendingPathComponent:@"assignments"] stringByAppendingPathComponent:self.id];
}

- (CKIAssignmentScoringType)scoringType
{
    NSString *scoringTypeString = self.gradingType;
    if ([scoringTypeString isEqual:@"pass_fail"]) {
        return CKIAssignmentScoringTypePassFail;
    } else if ([scoringTypeString isEqual:@"percent"]) {
        return CKIAssignmentScoringTypePercentage;
    } else if ([scoringTypeString isEqual:@"letter_grade"]) {
        return CKIAssignmentScoringTypeLetter;
    } else if ([scoringTypeString isEqual:@"not_graded"]) {
        return CKIAssignmentScoringTypeNotGraded;
    } else if ([scoringTypeString isEqual:@"gpa_scale"]) {
        return CKIAssignmentScoringTypeGPAScale;
    }
    
    return CKIAssignmentScoringTypePoints;
}

@end
