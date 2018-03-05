//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import <Foundation/Foundation.h>
#import "CKEnrollment.h"
#import "CKUser.h"
#import "CKModelObject.h"

typedef NS_ENUM(NSInteger, CKCourseHomepage) {
    CKCourseHomepageAssignments,
    CKCourseHomepageFeed,
    CKCourseHomepageFrontPage,
    CKCourseHomepageModules,
    CKCourseHomepageSyllabus,
    CKCourseHomepageOther,
};

@class CKCanvasAPI, CKContextInfo, CKAssignment, CKTerm;

@interface CKCourse : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *courseCode;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic, readonly) NSMutableArray *students;
@property (strong, nonatomic, readonly) NSMutableArray *assignments;
@property (strong, nonatomic, readonly) NSMutableArray *assignmentGroups;
@property (strong, nonatomic, readonly) NSMutableArray *calendarEvents;

@property (assign, getter = canCreateDiscussionTopics) BOOL createDiscussionTopics;

// derived from the api's default_view attribute
@property NSInteger homepage;

@property (strong, nonatomic) NSArray *loggedInUserEnrollments;

@property (nonatomic) NSInteger needsGradingCount;
@property (nonatomic, strong) NSURL *calendarFeedURL;

@property (assign) float currentScore;
@property (assign) float finalScore;
@property (strong) NSString *finalGrade;

@property (strong) NSString *syllabusBody;

@property (readonly) CKTerm *term;
@property (readonly) NSDate *startDate;
@property (readonly) NSDate *endDate;
@property (assign) BOOL hideFinalGrades;

- (id)initWithInfo:(NSDictionary *)info;
- (id)initWithID:(uint64_t)ident;
- (id)initPlaceholderCourse;

- (void)updateWithInfo:(NSDictionary *)info;
- (void)updateNeedsGradingCount;

- (NSArray *)enrollmentsForUserId:(uint64_t)ident;
- (void)addEnrollment:(CKEnrollment *)enrollment;
- (BOOL)userId:(uint64_t)userId hasEnrollmentOfType:(CKEnrollmentType)type;
- (BOOL)loggedInUserHasEnrollmentOfType:(CKEnrollmentType)type;

- (NSURL *)modulesURL;

@end

