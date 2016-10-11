//
//  CSGAppDataSource.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 1/5/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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
