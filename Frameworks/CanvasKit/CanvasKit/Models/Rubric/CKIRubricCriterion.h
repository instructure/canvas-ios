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

#import <Mantle/Mantle.h>
#import "CKIModel.h"

@class CKIRubricCriterionRating;

/**
 A rubric is made up of various criteria.
 
 For example, a criterion might be "Grammar" and have a score
 of 4 for a student. It may also have a list of pre-defined
 ratings the grader can use that were set up with the rubric.
 */
@interface CKIRubricCriterion : CKIModel

/**
 Points scored on this criterion.
 */
@property (nonatomic) double points;

/**
 Description of the criterion.
 */
@property (nonatomic, copy) NSString *criterionDescription;

/**
 A more detailed description of the criterion.
 */
@property (nonatomic, copy) NSString *longDescription;

/**
 Array of CKIRubricCriterionRating for this criterion.
 */
@property (nonatomic, copy) NSArray *ratings;

/**
 The position of the Rubric Criterion
 */
@property (nonatomic) NSInteger position;

/**
 The currently selected rating for this criterion, if any.
 */
@property (nonatomic, readonly) CKIRubricCriterionRating *selectedRating;

/**
 Ranges enabled.
 */
@property (nonatomic, assign) BOOL useRange;

@end
