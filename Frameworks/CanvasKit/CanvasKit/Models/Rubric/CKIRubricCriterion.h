//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
