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

//
// CKIRubric.h
// Created by Jason Larsen on 5/20/14.
//

#import <Foundation/Foundation.h>
#import "CKIModel.h"


/**
* Every assignment may have a rubric. The rubric is used as a template
* to standardize grading on an assignment. A rubric is composed of rubric
* criteria, and each individual criterion has several rating options, each
* option represented by a rating object.
*
* @see CKIRubricCriterion
* @see CKIRubricCriterionRating
*/
@interface CKIRubric : CKIModel

/**
* The title of the rubric.
*/
@property (nonatomic, copy) NSString *title;

/**
* The total number of points possible.
*
* @note a submission may score over 100%, and therefore the actual points
* may be greater than pointsPossible.
*/
@property (nonatomic) double pointsPossible;

/**
* Indicates whether or not the grader should be presented with
* the option to include a special free-form comment along with
* the rating selection on a particular criterion.
*/
@property (nonatomic) BOOL allowsFreeFormCriterionComments;

@end