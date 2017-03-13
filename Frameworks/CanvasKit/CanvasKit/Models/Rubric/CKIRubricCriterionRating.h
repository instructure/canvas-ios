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

#import "CKIModel.h"

/**
 A rubric criterion rating is one of the pre-defined
 ratings that can be selected for assignemnts that are graded
 on a rubric.
 
 For example, a rubric criterion for "Grammar" might have 3 ratings,
 5 points for "Perfect", 3 for "OK", and 1 for "Too many mistakes."
 
 In addition, some rubrics allow teachers to assign custom points
 when one of the pre-defined options is not fine-grained enough. In
 this case, they may choose to include a comment explaining the custom
 grade.
 */
@interface CKIRubricCriterionRating : CKIModel

/**
The points given to the student for the criteria when
this rating is selected.
*/
@property (nonatomic) double points;

/**
 A description for this rating, explaining the reasoning
 behind the points.
 */
@property (nonatomic, copy) NSString *ratingDescription;

/**
 Graders can add a comment for the rating when they give
 a grade that was not on the rubric.
 */
@property (nonatomic, copy) NSString *comments;

@end
