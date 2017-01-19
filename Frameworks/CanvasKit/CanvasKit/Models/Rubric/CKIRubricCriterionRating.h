//
//  CKIRubricCriterionRating.h
//  CanvasKit
//
//  Created by Jason Larsen on 8/29/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
