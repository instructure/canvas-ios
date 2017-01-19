//
//  NSValueTransformer+CKIPredefinedTransformerAdditions.m
//  CanvasKit
//
//  Created by Jason Larsen on 8/26/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
@import Mantle;
#import "CKISO8601DateFormatter.h"

#import "CKIRubricAssessment.h"
#import "CKIRubricCriterionRating.h"

NSString * const CKINumberStringTransformerName = @"CKINumberStringTransformerName";
NSString * const CKINumberOrStringToStringTransformerName = @"CKINumberOrStringToStringTransformerName";
NSString * const CKIDateTransformerName = @"CKIDateTransformerName";
NSString * const CKIRubricAssessmentTransformerName = @"CKIRubricAssessmentTransformerName";


static NSString *const CKIRubricCriterionRatingCommentsKey = @"comments";
static NSString *const CKIRubricCriterionRatingPointsKey = @"points";

@implementation NSValueTransformer (CKIPredefinedTransformerAdditions)

#pragma mark Category Loading

+ (void)load {
	@autoreleasepool {
		MTLValueTransformer *NumberStringTransformer = [NSValueTransformer numberStringTransformer];
		
		[NSValueTransformer setValueTransformer:NumberStringTransformer forName:CKINumberStringTransformerName];
        
        MTLValueTransformer *NumberOrStringToStringTransformer = [NSValueTransformer numberOrStringToStringTransformer];
        
        [NSValueTransformer setValueTransformer:NumberOrStringToStringTransformer forName:CKINumberOrStringToStringTransformerName];
        
		MTLValueTransformer *ISODateTransfomer = [NSValueTransformer ISODateTransformer];
        
		[NSValueTransformer setValueTransformer:ISODateTransfomer forName:CKIDateTransformerName];
        
        MTLValueTransformer *RubricAssessmentTransformer = [NSValueTransformer rubricAssessmentTransformer];
        
        [NSValueTransformer setValueTransformer:RubricAssessmentTransformer forName:CKIRubricAssessmentTransformerName];
	}
}

+ (MTLValueTransformer *)numberStringTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ id (NSNumber *number) {
        return [number stringValue];
    } reverseBlock:^ id (NSString *stringifiedNumber) {
        return [NSNumber numberWithLongLong:[stringifiedNumber longLongValue]];
    }];
}

+ (MTLValueTransformer *)numberOrStringToStringTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ id (id value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return [value stringValue];
        }

        return value;
    } reverseBlock:^ id (NSString *stringifiedNumber) {
        return stringifiedNumber;
    }];
}

+ (MTLValueTransformer *)ISODateTransformer;
{
    static CKISO8601DateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [CKISO8601DateFormatter new];
        dateFormatter.includeTime = YES;
    });
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *dateString) {
        if (dateString == nil) {
            return nil;
        }
        return [dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date) {
        if (date == nil) {
            return nil;
        }
        return [dateFormatter stringFromDate:date];
    }];
}

+ (MTLValueTransformer *)rubricAssessmentTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ id (NSDictionary *value) {
        CKIRubricAssessment *assessment = [CKIRubricAssessment new];
        
        NSMutableArray *ratings = [NSMutableArray array];
        NSMutableString *assessmentID = [NSMutableString new];
        [value.allKeys enumerateObjectsUsingBlock:^(NSString *idString, NSUInteger idx, BOOL *stop) {
            CKIRubricCriterionRating *rating = [CKIRubricCriterionRating new];
            rating.id = idString;
            [assessmentID appendString:idString];
                
            NSDictionary *contentDictionary = [value objectForKey:idString];
            rating.comments = [contentDictionary objectForKey:CKIRubricCriterionRatingCommentsKey];
            rating.points = [[contentDictionary objectForKey:CKIRubricCriterionRatingPointsKey] floatValue];
            [ratings addObject:rating];
        }];
        
        assessment.ratings = ratings;
        assessment.id = assessmentID;
        return assessment;
    } reverseBlock:^ id (CKIRubricAssessment *assessment) {
        NSMutableDictionary *assessmentDictionary = [NSMutableDictionary new];
        
        [assessment.ratings enumerateObjectsUsingBlock:^(CKIRubricCriterionRating *rating, NSUInteger idx, BOOL *stop) {
            NSDictionary *ratingDictionary = @{
                                              CKIRubricCriterionRatingPointsKey : @(rating.points),
                                              CKIRubricCriterionRatingCommentsKey : @(rating.points),
                                              };
         
            [assessmentDictionary setObject:ratingDictionary forKey:rating.id];

        }];
        
        return assessmentDictionary;
    }];
}

@end
