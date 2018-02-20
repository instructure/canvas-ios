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

@class CKICourse;
@class CKISubmission;
@class CKIRubric;
@class CKIDiscussionTopic;

typedef NS_ENUM(NSUInteger, CKIAssignmentScoringType) {
    CKIAssignmentScoringTypePoints,
    CKIAssignmentScoringTypePercentage,
    CKIAssignmentScoringTypePassFail,
    CKIAssignmentScoringTypeLetter,
    CKIAssignmentScoringTypeGPAScale,
    CKIAssignmentScoringTypeNotGraded
};

@interface CKIExternalToolTagAttributes: MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSURL *url;

@end

@interface CKIAssignment : CKILockableModel


#pragma mark - Assignment Info

/**
 The name of the assignment.
 */
@property (nonatomic, copy) NSString *name;

/**
* The index of the assignment in it's group.
*/
@property (nonatomic) NSInteger position;

/**
 The assignment description, in an HTML fragment.
 */
@property (nonatomic, copy) NSString *descriptionHTML;

/**
 The due date for the assignment. nil if no due date.
 
 @warning If this assignment has assignment overrides, use the date from
 the override instead.
 */
@property (nonatomic, strong) NSDate *dueAt;

/**
 The date after which the assignment is locked. nil if this assignment is
 never locked.

 @warning If this assignment has assignment overrides, use the date from
 the override instead.
 */
@property (nonatomic, strong) NSDate *lockAt;

/**
 The date the assignment is unlocked. nil if this assignment is
 never locked.
 
 @warning If this assignment has assignment overrides, use the date from
 the override instead.
 */
@property (nonatomic, strong) NSDate *unlockAt;

/**
 The ID of the course to which the assignment belongs.
 */
@property (nonatomic, copy) NSString *courseID;

/**
 The URL to the assignment's web page.
 */
@property (nonatomic, strong) NSURL *htmlURL;

/**
 List of the allowed extensions for file uploads.
 
 @note Only valid if submissionTypes includes "online_upload"
 */
@property (nonatomic, copy) NSArray *allowedExtensions;

/**
 The ID of the assignment's group.
 */
@property (nonatomic, copy) NSString *assignmentGroupID;

/**
 The ID of the assignment's group set.
 
 @note Only applies if this is a group assignment.
 */
@property (nonatomic, copy) NSString *groupCategoryID;

/**
 The assignment is muted.
 */
@property (nonatomic) BOOL muted;

/**
 Boolean indicating peer reviews are assigned automatically. If false, the teacher is expected to manually assign peer reviews.
 */
@property (nonatomic) BOOL automaticPeerReviews;

/**
 The assignment is published
 
 @note Only visible if 'enable draft' account setting is on
 */
@property (nonatomic) BOOL published;

/**
The discussion topic corresponding to this assignment.

@note Only valid if submissionTypes includes "discussion_topic"
*/
@property (nonatomic, copy) NSString *discussionTopicID;

/**
 The discussion topic corresponding to this assignment.
 
 @note Only valid if submissionTypes includes "discussion_topic"
 */
@property (nonatomic, strong) CKIDiscussionTopic *discussionTopic;


#pragma mark - Grading

/**
 The maximum points possible for the assignment.
 */
@property (nonatomic) double pointsPossible;

/**
 If this is a group assignment, boolean flag indicating whether or
 not students will be graded individually.
 */
@property (nonatomic) BOOL gradeGroupStudentsIndividually;

/**
 The type of grading the assignment receives; one of "pass_fail",
 "percent", "letter_grade", "points"
 */
@property (nonatomic, copy) NSString *gradingType;

/**
 The type of score the assignment submissions receive
 */
@property (nonatomic, assign) CKIAssignmentScoringType scoringType;


#pragma mark - Submissions

/**
 The types of submissions allowed for this assignment list
 containing one or more of the following: "discussion_topic",
 "online_quiz", "on_paper", "none", "external_tool",
 "online_text_entry", "online_url", "online_upload"
 "media_recording"
 */
@property (nonatomic, copy) NSArray *submissionTypes;

/**
 Submission for the assignment.
 */
@property (nonatomic, copy) CKISubmission *submission;

/**
 If the requesting user has grading rights, the number of
 submissions that need grading.
 */
@property (nonatomic) NSUInteger needsGradingCount;


#pragma mark - Rubric

/**
 Rubric Settings Object
 */
@property (nonatomic, strong) CKIRubric *rubric;

/**
 Array of CKIRubricCriterion
 */
@property (nonatomic, copy) NSArray *rubricCriterion;


#pragma mark - Peer Review

/**
 Boolean indicating if peer reviews are required for this assignment
 */
@property (nonatomic) BOOL peerReviewRequired;

/**
 Boolean indicating if rubric should be used to grade assignment
 */
@property (nonatomic) BOOL useRubricForGrading;

/**
 Boolean indicating peer reviews are assigned automatically.
 If false, the teacher is expected to manually assign peer reviews.
 */
@property (nonatomic) BOOL peerReviewsAutomaticallyAssigned;

/**
 Integer representing the amount of reviews each user is assigned.
 
 @note This is NOT valid unless you have peerReviewsAutomaticallyAssigned.
 */
@property (nonatomic) NSInteger peerReviewsAutomaticallyAssignedCount;

/**
 Date the reviews are due by. Must be a date that occurs after the default
 due date. If blank, or date is not after the assignment's due date, the
 assignment's due date will be used.
 
 @note This is NOT valid unless you have automatic_peer_reviews set to true.
 */
@property (nonatomic, strong) NSDate *peerReviewDueDate;

/**
 the url of the external tool
 */
@property (nonatomic) NSURL *url;

/**
 external tool attributes
 */
@property (nonatomic, strong) CKIExternalToolTagAttributes *externalToolTagAttributes;

/**
 the id of the quiz if this assignment represents a quiz
 */
@property (nonatomic) NSString *quizID;

/** 
 Dictionary containing section id as key and number of assignments
 for that section id that need grading as the value
 */
@property (nonatomic, strong) NSDictionary *needsGradingCountBySection;


@end
