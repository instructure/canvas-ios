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

@property (nonatomic) BOOL hidePoints;

@end
