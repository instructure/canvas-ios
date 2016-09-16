//
//  CBIQuizViewModel.h
//  iCanvas
//
//  Created by Derrick Hathaway on 3/19/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"

@interface CBIQuizViewModel : CBIColorfulViewModel
@property (nonatomic) CKIQuiz *model;
@property (nonatomic) NSDate *dueAt;
@end
