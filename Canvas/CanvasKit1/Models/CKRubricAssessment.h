//
//  CKRubricAssessment.h
//  CanvasKit
//
//  Created by Zach Wily on 7/7/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKRubricCriterion;
@class CKRubricCriterionRating;

@interface CKRubricAssessment : CKModelObject

@property (nonatomic, strong) NSMutableDictionary *ratings;
@property (nonatomic, strong) NSDictionary *originalRatings;

- (id)initWithInfo:(NSDictionary *)info;

- (float)score;

- (BOOL)isRatingSelected:(CKRubricCriterionRating *)rating;
- (void)selectRating:(CKRubricCriterionRating *)rating;
- (CKRubricCriterionRating *)selectedRatingForCriterion:(CKRubricCriterion *)criterion;

- (void)setPoints:(double)points forCriterion:(CKRubricCriterion *)criterion;
- (void)setComment:(NSString *)comment forCriterion:(CKRubricCriterion *)criterion;

- (BOOL)changed;
- (void)resetOriginalRatings;

- (NSDictionary *)parametersDictionary;

@end
