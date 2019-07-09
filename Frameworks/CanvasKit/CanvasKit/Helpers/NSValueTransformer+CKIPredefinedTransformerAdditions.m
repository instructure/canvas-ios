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

#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
@import Mantle;

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
    static NSISO8601DateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSISO8601DateFormatter new];
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
