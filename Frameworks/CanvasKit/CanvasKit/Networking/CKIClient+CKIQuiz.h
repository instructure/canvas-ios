//
//  CKIClient+CKIQuiz.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKIQuiz;
@class CKICourse;
@class RACSignal;

@interface CKIClient (CKIQuiz)

- (RACSignal *)fetchQuiz:(NSString *)quizID forCourse:(CKICourse *)course;

- (RACSignal *)fetchQuizzesForCourse:(CKICourse *)course;

@end
