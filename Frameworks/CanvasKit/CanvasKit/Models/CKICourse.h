//
//  CKICourse.h
//  CanvasKit
//
//  Created by rroberts on 9/10/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"

@class CKITerm;

/**
 A Canvas course.
 */
@interface CKICourse : CKIModel

/**
 the SIS identifier for the course, if defined.
 */
@property (nonatomic, copy) NSString *sisCourseID;

/**
 The full name of the course.
 */
@property (nonatomic, copy) NSString *name;

/**
 The Course code.
 */
@property (nonatomic, copy) NSString *courseCode;

/**
 The current state of the course. 
 
 @note One of |unpublished|, |available|, or |deleted|
 */
@property (nonatomic, copy) NSString *workflowState;

/**
 The account associated with the course
 */
@property (nonatomic, copy) NSString *accountID;

/**
 The start date for the course, if applicable
 */
@property (nonatomic, strong) NSDate *startAt;

/**
 The end date for the course, if applicable
 */
@property (nonatomic, copy) NSDate *endAt;

/**
 A list of enrollments linking the current user to the course.
 
 @note Returned only if student and include[]=total_scored
  */
@property (nonatomic, copy) NSArray *enrollments;

/**
 Course calendar.
 */
@property (nonatomic, strong) NSURL *calendar;

/**
 The type of page that users will see when they first visit the course.
 
 - 'feed' : Recent Activity Dashboard
 - 'wiki' : Wiki Front Page
 - 'modules' : Course Modules/Sections Page
 - 'assignments' : Course Assignments List
 - 'syllabus' : Course Syllabus Page

 @note Other types may be added in the future
 */
@property (nonatomic, copy) NSString *defaultView;

/**
 User-generated HTML for the course syllabus
 */
@property (nonatomic, strong) NSString *syllabusBody;

/**
 The number of submissions needing grading. 
 
 @note Returned only if the current user has grading rights and include[]=needs_grading_count
 */
@property (nonatomic) NSInteger needsGradingCount;

/**
 The name of the enrollment term for the course
 
 @note Returned only if include[]=term
 */
@property (nonatomic, strong) CKITerm *term;

/**
 Weight final grade based on assignment group percentages
 */
@property (nonatomic) BOOL applyAssignmentGroupWeights;

@property (nonatomic) BOOL publicSyllabus;

@property (nonatomic) BOOL canCreateDiscussionTopics;

@property (nonatomic) BOOL hideFinalGrades;

@property (nonatomic, readonly) BOOL currentUserEnrolledAsStudentOrObserver;

@property (nonatomic, readonly) NSString *currentGradingPeriodID;

@end


