//
//  CKIQuiz.m
//  CanvasKit
//
//  Created by Miles Wright on 10/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIQuiz.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKIQuiz
@synthesize description;

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"htmlURL": @"html_url",
        @"mobileURL": @"mobile_url",
        @"quizType": @"quiz_type",
        @"assignmentGroupID": @"assignment_group_id",
        @"timeLimitMinutes": @"time_limit",
        @"shuffleAnswers": @"shuffle_answers",
        @"hideResults": @"hide_results",
        @"showCorrectAnswers": @"show_correct_answers",
        @"scoringPolicy": @"scoring_policy",
        @"allowedAttempts": @"allowed_attempts",
        @"oneQuestionAtATime": @"one_question_at_a_time",
        @"questionCount": @"question_count",
        @"pointsPossible": @"points_possible",
        @"cantGoBack": @"cant_go_back",
        @"accessCode": @"access_code",
        @"ipFilter": @"ip_filter",
        @"dueAt": @"due_at",
        @"description": @"description",
        @"descriptionHTML": @"description"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)htmlURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)mobileURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)dueAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)assignmentGroupIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)shuffleAnswersJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"quizzes"] stringByAppendingPathComponent:self.id];
}

@end
