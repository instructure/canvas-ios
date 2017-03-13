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

#import "CKILockableModel.h"

@interface CKIQuiz : CKILockableModel

/**
 The title for the quiz.
 */
@property (nonatomic, copy) NSString *title;

/**
 The HTML url for the quiz.
 */
@property (nonatomic, strong) NSURL *htmlURL;

/**
 The mobile url for the quiz.
 */
@property (nonatomic, strong) NSURL *mobileURL;

/**
 The description for the quiz.
 */
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *descriptionHTML;

/**
 The type for the quiz.
 Possible values: practice_quiz, assignment, graded_survey, survey
 */
@property (nonatomic, copy) NSString *quizType;

/**
 The ID of the assignment group for the quiz.
 */
@property (nonatomic, copy) NSString *assignmentGroupID;

/**
 The time limit in minutes for the quiz.
 */
@property (nonatomic) NSInteger timeLimitMinutes;

/**
 Indicates if answers are shuffled for the quiz.
 */
@property (nonatomic) BOOL shuffleAnswers;

/**
 Indicates if results are hidden for the quiz.
 Possible values: null, always, until_after_last_attempt
 */
@property (nonatomic, copy) NSString *hideResults;

/**
 Indicates if correct answers are shown for the quiz.
 Only valid if hide_results == nil
 */
@property (nonatomic) BOOL showCorrectAnswers;

/**
 The scoring policy for the quiz.
 Possible values: keep_highest, keep_latest
 */
@property (nonatomic, copy) NSString *scoringPolicy;

/**
 The number of times a student can take the quiz.
 -1 = unlimited attempts
 */
@property (nonatomic) NSInteger allowedAttempts;

/**
 Indicates if one questions should be shown at a time for the quiz.
 */
@property (nonatomic) BOOL oneQuestionAtATime;

/**
 The number of questions for the quiz.
 */
@property (nonatomic) NSInteger questionCount;

/**
 The number of points possible for the quiz.
 */
@property (nonatomic) NSInteger pointsPossible;

/**
 Indicates if questions should be locked after answering for the quiz.
 Only valid if one_question_at_a_time == YES
 */
@property (nonatomic) BOOL cantGoBack;

/**
 Access code to restrict the quiz.
 */
@property (nonatomic, copy) NSString *accessCode;

/**
 IP Address or range that that access is limited to for the quiz.
 */
@property (nonatomic, strong) NSString *ipFilter;

/**
 The date when the quiz is due.
 */
@property (nonatomic, strong) NSDate *dueAt;

/**
 Indicates if the state is published for the quiz.
 */
@property (nonatomic) BOOL published;

@end
