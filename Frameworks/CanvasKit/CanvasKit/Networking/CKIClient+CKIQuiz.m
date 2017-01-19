//
//  CKIClient+CKIQuiz.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient+CKIQuiz.h"
#import "CKIQuiz.h"
#import "CKICourse.h"

@implementation CKIClient (CKIQuiz)

- (RACSignal *)fetchQuiz:(NSString *)quizID forCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"quizzes"];
    path = [path stringByAppendingPathComponent:quizID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIQuiz class] context:course];
}

- (RACSignal *)fetchQuizzesForCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"quizzes"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIQuiz class] context:course];
}

@end
