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

extern NSString * const CSGSubmissionRecordUpdatedAtIndexNotification;

extern NSString * const CSGStudentSubmissionSectionNeedsGrading;
extern NSString * const CSGStudentSubmissionSectionGraded;
extern NSString * const CSGStudentSubmissionSectionNoSubmission;

typedef NS_ENUM(NSInteger, CSGStudentSortOrder) {
    CSGStudentSortOrderGrade,
    CSGStudentSortOrderAlphabetical,
    CSGStudentSortOrderGradeRandom
};

@interface CSGAppDataSource : NSObject

+ (instancetype)sharedInstance;

// Data Sources
@property (nonatomic, strong) NSArray *favoriteCourses;
@property (nonatomic, strong) NSArray *courses;

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *assignmentGroups;
@property (nonatomic, strong) NSDictionary *assignmentsByGroupID;

@property (nonatomic) CSGStudentSortOrder studentSortOrder;
@property (nonatomic, strong) NSArray *sortedStudentsByName;
@property (nonatomic, strong) NSDictionary *sortedStudentsByGrade;
@property (nonatomic, strong) NSArray *sortedSubmissionRecords;

//  Current selected
@property (nonatomic, strong) CKICourse *course;
@property (nonatomic, strong) CKIAssignment *assignment;
@property (nonatomic, strong) CKISection *section;

@property (nonatomic, strong) CKIUser *selectedStudent;
@property (nonatomic, strong) CKISubmissionRecord *selectedSubmissionRecord;
@property (nonatomic, strong) CKISubmission *selectedSubmission;
@property (nonatomic, strong) CKIFile *selectedAttachment;

@property (nonatomic, assign) BOOL selectedSubmissionGradeOrAssessmentChanged;
@property (nonatomic, assign) BOOL selectedSubmissionCommentChanged;

- (void)clearData;

// Fetch Model Methods
- (void)fetchAssignmentModel:(CKIAssignment *)assignment withCourse:(CKICourse *)course withSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure;

// Reload Data Methods
- (void)reloadCoursesWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure;
- (void)reloadAssignmentsWithGroupsWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure;
- (void)reloadSubmissionsWithStudentsWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure;

- (CKISubmissionRecord *)initialSubmission;
- (CKISubmissionRecord *)submissionRecordForStudentPriorTo:(CKISubmissionRecord *)submission;
- (CKISubmissionRecord *)submissionRecordForStudentFollowing:(CKISubmissionRecord *)submission;

- (CKIUser *)userForSubmission:(CKISubmissionRecord *)submission;
- (NSUInteger)userIndexForSubmission:(CKISubmissionRecord *)submission;
- (CKISubmissionRecord *)submissionForUser:(CKIUser *)user;

- (void)replaceSubmissionRecord:(CKISubmissionRecord *)record withSubmissionRecord:(CKISubmissionRecord *)submissionRecord;
- (void)setStudentSortOrder:(CSGStudentSortOrder)sortOrder success:(void(^)(void))success;


- (void)decrementNeedsGradingCount;

@end
