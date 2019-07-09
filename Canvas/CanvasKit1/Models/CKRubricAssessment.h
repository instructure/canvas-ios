//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
