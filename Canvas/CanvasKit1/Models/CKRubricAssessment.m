//
//  CKRubricAssessment.m
//  CanvasKit
//
//  Created by Zach Wily on 7/7/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "CKRubricAssessment.h"
#import "CKRubricCriterion.h"
#import "CKRubricCriterionRating.h"

@implementation CKRubricAssessment


- (id)init
{
    self = [super init];
    if (self) {
        self.ratings = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)initWithInfo:(NSDictionary *)info
{
    self = [self init];
    if (self) {
        if (info && (id)info != [NSNull null]) {
            for (NSString *criterionId in info) {
                if (![criterionId isEqualToString:@""]) {
                    NSDictionary *ratingInfo = info[criterionId];
                    CKRubricCriterionRating *assessedRating = [[CKRubricCriterionRating alloc] initWithInfo:ratingInfo andCriterionIdent:criterionId];
                    (self.ratings)[criterionId] = assessedRating;
                }
            }
        }
        
        self.originalRatings = self.ratings;
    }
    
    return self;
}

- (NSUInteger)hash {
    return self.ratings.hash;
}

- (float)score
{
    float aScore = 0;
    for (CKRubricCriterionRating *assessedRating in [self.ratings objectEnumerator]) {
        aScore += assessedRating.points;
    }
    return aScore;
}

- (BOOL)isRatingSelected:(CKRubricCriterionRating *)rating
{
    NSString *criterionId = rating.criterionId;
    CKRubricCriterionRating *assessedRating = (self.ratings)[criterionId];
    if (assessedRating && rating.points == assessedRating.points) {
        return YES;
    }
    return NO;
}

- (CKRubricCriterionRating *)selectedRatingForCriterion:(CKRubricCriterion *)criterion {
    return self.ratings[criterion.identifier];
}

- (void)selectRating:(CKRubricCriterionRating *)rating
{
    (self.ratings)[rating.criterionId] = [rating copy];
}

- (void)setComment:(NSString *)comment forCriterion:(CKRubricCriterion *)criterion
{
    CKRubricCriterionRating *rating = (self.ratings)[criterion.identifier];
    if (!rating) {
        rating = [[CKRubricCriterionRating alloc] initWithRubricCriterion:criterion];
        (self.ratings)[criterion.identifier] = rating;
    }
    rating.comments = comment;
}

- (void)setPoints:(double)points forCriterion:(CKRubricCriterion *)criterion
{
    CKRubricCriterionRating *rating = self.ratings[criterion.identifier];
    if (!rating) {
        rating = [[CKRubricCriterionRating alloc] initWithRubricCriterion:criterion];
        self.ratings[criterion.identifier] = rating;
    }
    rating.points = points;
}

- (BOOL)changed
{
    if (!self.originalRatings) {
        return YES;
    }
    
    if ([self.ratings count] != [self.originalRatings count]) {
        return YES;
    }
    
    for (NSString *criterionId in self.ratings) {
        CKRubricCriterionRating *newRating = (self.ratings)[criterionId];
        CKRubricCriterionRating *oldRating = (self.originalRatings)[criterionId];
        if (!oldRating) {
            return YES;
        }
        
        if (newRating.points != oldRating.points) {
            return YES;
        }
        
        if (![newRating.comments isEqualToString:oldRating.comments]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setOriginalRatings:(NSDictionary *)someRatings
{
    if (someRatings != _originalRatings) {
        _originalRatings = [[NSDictionary alloc] initWithDictionary:someRatings copyItems:YES];
    }
}

- (void)resetOriginalRatings
{
    self.originalRatings = self.ratings;
}

- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (CKRubricCriterionRating *rating in [self.ratings objectEnumerator]) {
        NSString *criterionId = rating.criterionId;
        params[[NSString stringWithFormat:@"rubric_assessment[%@][points]", criterionId]] = [NSString stringWithFormat:@"%g", rating.points];
        NSString *comments = rating.comments;
        if (!comments) {
            comments = @"";
        }
        params[[NSString stringWithFormat:@"rubric_assessment[%@][comments]", criterionId]] = comments;
         
    }
    return params;
}

@end
