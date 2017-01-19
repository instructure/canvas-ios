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

#import "CSGAppDataSource.h"
#import "CSGNotificationPermissionHandler.h"
@import CanvasKit;

NSString *const CSGSubmissionRecordUpdatedAtIndexNotification = @"CSGSubmissionRecordUpdatedAtIndexNotification";

NSString *const CSGStudentSubmissionSectionNeedsGrading = @"CSGStudentSubmissionSectionNeedsGrading";
NSString *const CSGStudentSubmissionSectionGraded = @"CSGStudentSubmissionSectionGraded";
NSString *const CSGStudentSubmissionSectionNoSubmission = @"CSGStudentSubmissionSectionNoSubmission";

@interface CSGAppDataSource ()

@property (nonatomic, strong) NSArray *students;
@property (nonatomic, strong) NSMutableDictionary *submissionsDictionary;
@property (nonatomic, strong) NSArray *submissionRecords;

@end

@implementation CSGAppDataSource

+ (instancetype)sharedInstance {
    static CSGAppDataSource *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Reload Data Methods

- (void)reloadCoursesWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    NSMutableArray *favCourses = [NSMutableArray new];
    RACSignal *fetchFavCoursesSignal = [[TheKeymaster currentClient] fetchFavoriteCourses];
    [fetchFavCoursesSignal subscribeNext:^(NSArray *courses) {
        //filter courses by Teacher / TA role
        [courses enumerateObjectsUsingBlock:^(CKICourse *course, NSUInteger idx, BOOL *stop) {
            [course.enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
                if (enrollment.type == CKIEnrollmentTypeTeacher || enrollment.type == CKIEnrollmentTypeTA) {
                    [favCourses addObject:course];
                    *stop = YES;
                    return;
                }
            }];
        }];
    } completed:^{
        [favCourses sortUsingComparator:^NSComparisonResult(CKICourse *course1, CKICourse *course2) {
            return [course1.name caseInsensitiveCompare:course2.name];
        }];
        self.favoriteCourses = [NSArray arrayWithArray:favCourses];
    }];
    
    NSMutableArray *allCourses = [NSMutableArray new];
    RACSignal *fetchAllCoursesSignal = [[TheKeymaster currentClient] fetchCoursesForCurrentUser];
    [fetchAllCoursesSignal subscribeNext:^(NSArray *courses) {
        //filter courses by Teacher / TA role
        [courses enumerateObjectsUsingBlock:^(CKICourse *course, NSUInteger idx, BOOL *stop) {
            [course.enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
                if (enrollment.type == CKIEnrollmentTypeTeacher || enrollment.type == CKIEnrollmentTypeTA) {
                    [allCourses addObject:course];
                    *stop = YES;
                    return;
                }
            }];
        }];
    } completed:^{
        [allCourses sortUsingComparator:^NSComparisonResult(CKICourse *course1, CKICourse *course2) {
            return [course1.name caseInsensitiveCompare:course2.name];
        }];
        self.courses = [NSArray arrayWithArray:allCourses];
    }];
    
    [[RACSignal merge:@[fetchAllCoursesSignal, fetchFavCoursesSignal]] subscribeError:^(NSError *error) {
        [self updateApplicationIconBadgeNumber];
        if (failure) {
            failure(error);
        }
    } completed:^{
        [self updateApplicationIconBadgeNumber];
        if (success) {
            success();
        }
    }];
}

- (void)reloadAssignmentsWithGroupsWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    CKIClient *client = [TheKeymaster currentClient];
    
    NSMutableArray *assignmentGroups = [NSMutableArray new];
    RACSignal *fetchAssignmentGroupsSignal = [client fetchAssignmentGroupsForContext:self.course includeAssignments:NO gradingPeriodID:nil includeSubmissions:YES scopeAssignmentsToStudent:NO];
    [fetchAssignmentGroupsSignal subscribeNext:^(NSArray *assignGroups) {
        [assignmentGroups addObjectsFromArray:assignGroups];
    } completed:^{
        [assignmentGroups sortedArrayUsingComparator:^NSComparisonResult(CKIAssignmentGroup *assignmentGroup1, CKIAssignmentGroup *assignmentGroup2) {
            return [@(assignmentGroup1.position) compare:@(assignmentGroup2.position)];
        }];
        
        self.assignmentGroups = assignmentGroups;
    }];
    
    NSMutableDictionary *assignmentsDictionary = [NSMutableDictionary new];
    RACSignal *fetchAssignmentsSignal = [client fetchAssignmentsForContext:self.course includeSubmissions:NO];
    [fetchAssignmentsSignal subscribeNext:^(NSArray *assignments) {
        [assignments enumerateObjectsUsingBlock:^(CKIAssignment *assignment, NSUInteger idx, BOOL *stop) {
            if (!assignment.published) {
                return;
            }
            
            NSMutableArray *assignmentGroupArray = assignmentsDictionary[assignment.assignmentGroupID];
            if (!assignmentGroupArray) {
                assignmentGroupArray = [NSMutableArray new];
            }
            
            [assignmentGroupArray addObject:assignment];
            assignmentsDictionary[assignment.assignmentGroupID] = assignmentGroupArray;
        }];
    } completed:^{
        self.assignmentsByGroupID = assignmentsDictionary;
    }];
    
    NSMutableArray *sectionsMutable = [NSMutableArray new];
    RACSignal *fetchSectionsSignal = [client fetchSectionsForCourse:self.course];
    [fetchSectionsSignal subscribeNext:^(NSArray *assignGroups) {
        [sectionsMutable addObjectsFromArray:assignGroups];
    } error:^(NSError *error) {
        
    } completed:^{
        // Sort here if necessary
        self.sections = sectionsMutable;
    }];
    
    RACSignal *mergedSignals = [RACSignal merge:@[fetchAssignmentGroupsSignal, fetchAssignmentsSignal, fetchSectionsSignal]];
    [mergedSignals  subscribeError:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    } completed:^{
        if (success) {
            success();
        }
    }];
}

- (void)reloadSubmissionsWithStudentsWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    
    RACSignal *fetchSubmissionRecordsSignal = [TheKeymaster.currentClient fetchSubmissionRecordsForAssignment:self.assignment];
    RACSignal *fetchUsersSignal = [TheKeymaster.currentClient fetchStudentsForContext:self.course];
    
    NSMutableArray *submissionRecords = [NSMutableArray new];
    [fetchSubmissionRecordsSignal subscribeNext:^(NSArray *newSubmissionRecords) {
        [submissionRecords addObjectsFromArray:newSubmissionRecords];
    } completed:^{
        self.submissionRecords = submissionRecords;
    }];
    
    NSMutableArray *users = [NSMutableArray new];
    [fetchUsersSignal subscribeNext:^(NSArray *newUsers) {
        [users addObjectsFromArray:newUsers];
    } completed:^{
        // filter to only students
        self.students = users;
    }];
    
    [[RACSignal merge:@[fetchSubmissionRecordsSignal, fetchUsersSignal]] subscribeError:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    } completed:^{
        [self reloadDataStructures];
        
        if (success) {
            success();
        }
    }];
}

#pragma mark - Needs Graded Badge Methods
- (void)updateApplicationIconBadgeNumber {
    if (![CSGNotificationPermissionHandler canSendNotifications]){
        return;
    }
    
    __block NSInteger ungradedCount = 0;
    [self.courses enumerateObjectsUsingBlock:^(CKICourse *course, NSUInteger idx, BOOL *stop) {
        ungradedCount += course.needsGradingCount;
    }];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:MAX(ungradedCount, 0)];
}

- (void)decrementNeedsGradingCount {
    [self decrementNeedsGradingCountForCourse:self.course];
    [self decrementNeedsGradingCountForAssignment:self.assignment];
}

- (void)decrementNeedsGradingCountForCourse:(CKICourse *)course {
    [self.courses enumerateObjectsUsingBlock:^(CKICourse *aCourse, NSUInteger idx, BOOL *stop) {
        if ([aCourse.id isEqualToString:course.id]) {
            aCourse.needsGradingCount--;
        }
    }];
    
    [self.favoriteCourses enumerateObjectsUsingBlock:^(CKICourse *aCourse, NSUInteger idx, BOOL *stop) {
        if ([aCourse.id isEqualToString:course.id]) {
            aCourse.needsGradingCount--;
        }
    }];
    
    [self updateApplicationIconBadgeNumber];
}

- (void)decrementNeedsGradingCountForAssignment:(CKIAssignment *)assignment {
    [self.assignmentGroups enumerateObjectsUsingBlock:^(CKIAssignmentGroup *assignmentGroup, NSUInteger idx, BOOL *stop) {
        NSArray *assignments = self.assignmentsByGroupID[assignmentGroup.id];
        [assignments enumerateObjectsUsingBlock:^(CKIAssignment *anAssignment, NSUInteger idx, BOOL *stop) {
            if ([anAssignment.id isEqualToString:assignment.id]) {
                // TODO: update needsGradingCountBySection here too
                anAssignment.needsGradingCount --;
            }
        }];
    }];
}


#pragma mark - Submission & User Fetching convenience methods
- (CKISubmissionRecord *)submissionRecordForStudentPriorTo:(CKISubmissionRecord *)submission {
    if (self.studentSortOrder == CSGStudentSortOrderAlphabetical) {
        return [self submissionForDelta:-1 fromSubmission:submission inStudentList:self.sortedStudentsByName];
    } else {
        NSArray *allTheStudents = [self flattenedUsersSortedByGrade];
        return [self submissionForDelta:-1 fromSubmission:submission inStudentList:allTheStudents];
    }
}

- (CKISubmissionRecord *)submissionRecordForStudentFollowing:(CKISubmissionRecord *)submission {
    if (self.studentSortOrder == CSGStudentSortOrderAlphabetical) {
        return [self submissionForDelta:1 fromSubmission:submission inStudentList:self.sortedStudentsByName];
    } else {
        NSArray *allTheStudents = [self flattenedUsersSortedByGrade];
        return [self submissionForDelta:1 fromSubmission:submission inStudentList:allTheStudents];
    }
}

- (CKISubmissionRecord *)initialSubmission {
    if (self.studentSortOrder == CSGStudentSortOrderAlphabetical) {
        CKIUser *user = self.sortedStudentsByName.firstObject;
        return [self submissionForUser:user];
    } else if (self.studentSortOrder == CSGStudentSortOrderGrade || self.studentSortOrder == CSGStudentSortOrderGradeRandom) {
        NSArray *allTheStudents = [self flattenedUsersSortedByGrade];
        if (![allTheStudents count]) {
            return nil;
        }
        
        CKIUser *user = allTheStudents.firstObject;
        return [self submissionForUser:user];
    }
    
    return nil;
}

- (CKISubmissionRecord *)submissionForDelta:(NSInteger)delta fromSubmission:(CKISubmissionRecord *)submission inStudentList:(NSArray *)list {
    NSUInteger nextEnrollmentIndex = 0;
    
    NSUInteger currentEnrollmentIndex = [self indexForUserSubmission:submission inList:list];
    
    if (currentEnrollmentIndex == NSNotFound) {
        return nil;
    }
    
    nextEnrollmentIndex = (currentEnrollmentIndex + delta) % [list count];
        
    CKIUser *currentEnrollment = [list objectAtIndex:nextEnrollmentIndex];
    return [self submissionForUser:currentEnrollment];
}

- (NSArray *)flattenedUsersSortedByGrade {
    NSArray *needsGrading = self.sortedStudentsByGrade[CSGStudentSubmissionSectionNeedsGrading];
    NSArray *graded = self.sortedStudentsByGrade[CSGStudentSubmissionSectionGraded];
    NSArray *unsubmitted = self.sortedStudentsByGrade[CSGStudentSubmissionSectionNoSubmission];
    
    NSMutableArray *allTheStudents = [NSMutableArray array];
    [allTheStudents addObjectsFromArray:needsGrading];
    [allTheStudents addObjectsFromArray:graded];
    [allTheStudents addObjectsFromArray:unsubmitted];
    
    return allTheStudents;
}

- (void)replaceSubmissionRecord:(CKISubmissionRecord *)record withSubmissionRecord:(CKISubmissionRecord *)submissionRecord {
    submissionRecord.submissionHistory = record.submissionHistory;
    submissionRecord.attachments = record.attachments;
    submissionRecord.rubricAssessment = record.rubricAssessment;
    
    self.submissionsDictionary[record.userID] = submissionRecord;
    if ([self.selectedSubmissionRecord.userID isEqualToString:submissionRecord.userID]) {
        self.selectedSubmissionRecord = submissionRecord;
    }
    
    __block NSUInteger idxReplaced = NSNotFound;
    NSMutableArray *mutableRecords = [NSMutableArray arrayWithArray:self.submissionRecords];
    [self.submissionRecords enumerateObjectsUsingBlock:^(CKISubmissionRecord *subRecord, NSUInteger idx, BOOL *stop) {
        if ([subRecord.id isEqualToString:record.id]) {
            mutableRecords[idx] = submissionRecord;
            idxReplaced = idx;
            *stop = YES;
        }
    }];
    if (idxReplaced != NSNotFound) {
        self.submissionRecords = [NSArray arrayWithArray:mutableRecords];
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGSubmissionRecordUpdatedAtIndexNotification object:@(idxReplaced)];
    }
}

#pragma warning
- (CKISubmissionRecord *)submissionForUser:(CKIUser *)user {
    if (!user) {
        return nil;
    }
    __block CKISubmissionRecord *submission = self.submissionsDictionary[user.id];
    if (!submission) {
        submission = [CKISubmissionRecord new];
        submission.userID = user.id;
        submission.context = self.assignment;
        submission.assignmentID = self.assignment.id;
        self.submissionsDictionary[user.id] = submission;
    }
    
    return submission;
}

- (NSUInteger)userIndexForSubmission:(CKISubmissionRecord *)submission {
    if (self.studentSortOrder == CSGStudentSortOrderAlphabetical) {
        return [self indexForUserSubmission:submission inList:self.sortedStudentsByName];
    } else {
        NSArray *allTheStudents = [self flattenedUsersSortedByGrade];
        return [self indexForUserSubmission:submission inList:allTheStudents];
    }
}

- (NSUInteger)indexForUserSubmission:(CKISubmissionRecord *)submission inList:(NSArray *)list {
    __block NSUInteger currentEnrollmentIndex = NSNotFound;
    [list enumerateObjectsUsingBlock:^(CKIUser *user, NSUInteger idx, BOOL *stop) {
        if ([user.id isEqualToString:submission.userID]) {
            currentEnrollmentIndex = idx;
            *stop = YES;
        }
    }];
    
    return currentEnrollmentIndex;
}

- (CKIUser *)userForSubmission:(CKISubmissionRecord *)submission {
    __block CKIUser *currentUser = nil;
    // This doesn't matter if it's sorted by name or grade - just getting a user, sort agnostic
    [self.sortedStudentsByName enumerateObjectsUsingBlock:^(CKIUser *user, NSUInteger idx, BOOL *stop) {
        if ([user.id isEqualToString:submission.userID]) {
            currentUser = user;
            *stop = YES;
        }
    }];
    return currentUser;
}

- (void)reloadDataWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    
    RACSignal *fetchSubmissionRecordsSignal = [TheKeymaster.currentClient fetchSubmissionRecordsForAssignment:self.assignment];
    RACSignal *fetchUsersSignal = [TheKeymaster.currentClient fetchUsersForContext:self.course];
    
    NSMutableArray *submissionRecords = [NSMutableArray new];
    [fetchSubmissionRecordsSignal subscribeNext:^(NSArray *newSubmissionRecords) {
        [submissionRecords addObjectsFromArray:newSubmissionRecords];
    } error:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    } completed:^{
        self.submissionRecords = submissionRecords;
    }];
    
    NSMutableArray *users = [NSMutableArray new];
    [fetchUsersSignal subscribeNext:^(NSArray *newUsers) {
        [users addObjectsFromArray:newUsers];
    } error:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    } completed:^{
        // filter to only students
        self.students = [[users.rac_sequence filter:^BOOL(CKIUser *user) {
            __block BOOL isStudent = NO;
            [user.enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
                isStudent = enrollment.type == CKIEnrollmentTypeStudent;
                if (isStudent) {
                    *stop = YES;
                }
            }];
            return isStudent;
        }] array];
    }];
    
    [[RACSignal merge:@[fetchSubmissionRecordsSignal, fetchUsersSignal]] subscribeError:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    } completed:^{
        [self reloadDataStructures];
        
        if (success) {
            success();
        }
    }];
}

- (void)reloadDataStructures {
    // Order matters here.  We need to populate the submission dictionary so we can easily look them up for comparison.
    [self reloadSubmissionDictionary];
    [self reloadSortedEnrollments];
}

- (void)reloadSortedEnrollments {
    // filter out users by section if needed
    self.sortedStudentsByName = [[self.students.rac_sequence filter:^BOOL(CKIUser *user) {
        if (self.section) {
            __block BOOL isStudentInSection = NO;
            [user.enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
                isStudentInSection = [self.section.id isEqualToString:enrollment.sectionID];
                if (isStudentInSection) {
                    *stop = YES;
                }
            }];
            return isStudentInSection;
        }
        return YES;
    }] array];
    
    if (self.studentSortOrder == CSGStudentSortOrderGradeRandom) {
        NSMutableArray *shuffledArray = [NSMutableArray arrayWithArray:self.sortedStudentsByName];
        
        NSUInteger count = [shuffledArray count];
        for (NSInteger i = 0; i < count; ++i) {
            NSUInteger nElements = count - i;
            NSInteger n = @(arc4random_uniform((uint32_t) nElements) + i).integerValue;
            [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
        }

        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSMutableArray *needsGrading = [NSMutableArray array];
        NSMutableArray *graded = [NSMutableArray array];
        NSMutableArray *unsubmitted = [NSMutableArray array];
        [shuffledArray enumerateObjectsUsingBlock:^(CKIUser *user, NSUInteger idx, BOOL *stop) {
            CKISubmissionRecord *submissionRecord = [self submissionForUser:user];
            if (submissionRecord.gradeMatchesCurrentSubmission) {
                [graded addObject:user];
            } else {
                if (!submissionRecord || [submissionRecord isDummySubmission]) {
                    [unsubmitted addObject:user];
                } else {
                    [needsGrading addObject:user];
                }
            }
        }];
        dict[CSGStudentSubmissionSectionNeedsGrading] = needsGrading;
        dict[CSGStudentSubmissionSectionGraded] = graded;
        dict[CSGStudentSubmissionSectionNoSubmission] = unsubmitted;
        
        self.sortedStudentsByGrade = dict;
        
    } else {
        
        NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:self.sortedStudentsByName];
        [sortedArray sortUsingComparator:^NSComparisonResult(CKIUser *user1, CKIUser *user2) {
            if (self.studentSortOrder == CSGStudentSortOrderGrade) {
                CKISubmissionRecord *submissionRecord1 = [self submissionForUser:user1];
                CKISubmissionRecord *submissionRecord2 = [self submissionForUser:user2];
                NSNumber *score1 = submissionRecord1.score ?: @(-1);
                NSNumber *score2 = submissionRecord2.score ?: @(-1);
                
                NSComparisonResult scoreResult = [score1 compare:score2];   // return lowest scores first
                if (scoreResult == NSOrderedSame) {
                    scoreResult = [user1.sortableName caseInsensitiveCompare:user2.sortableName];
                }
                return scoreResult;
            }
            
            return [user1.sortableName caseInsensitiveCompare:user2.sortableName];
        }];
        
        self.sortedStudentsByName = sortedArray;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSMutableArray *needsGrading = [NSMutableArray array];
        NSMutableArray *graded = [NSMutableArray array];
        NSMutableArray *unsubmitted = [NSMutableArray array];
        [sortedArray enumerateObjectsUsingBlock:^(CKIUser *user, NSUInteger idx, BOOL *stop) {
            CKISubmissionRecord *submissionRecord = [self submissionForUser:user];
            if (submissionRecord.gradeMatchesCurrentSubmission && submissionRecord.score != nil) {
                [graded addObject:user];
            } else {
                if (!submissionRecord || [submissionRecord isDummySubmission]) {
                    [unsubmitted addObject:user];
                } else {
                    [needsGrading addObject:user];
                }
            }
        }];
        dict[CSGStudentSubmissionSectionNeedsGrading] = needsGrading;
        dict[CSGStudentSubmissionSectionGraded] = graded;
        dict[CSGStudentSubmissionSectionNoSubmission] = unsubmitted;
        self.sortedStudentsByGrade = dict;
    }
}

- (void)reloadSubmissionDictionary {
    // put most recent submissions into a dictionary for fast retrieval
    [self.submissionsDictionary removeAllObjects];
    [self.submissionRecords enumerateObjectsUsingBlock:^(CKISubmissionRecord *submissionRecord, NSUInteger idx, BOOL *stop) {
        self.submissionsDictionary[submissionRecord.userID] = submissionRecord;
    }];
}

- (NSMutableDictionary *)submissionsDictionary {
    if (!_submissionsDictionary) {
        _submissionsDictionary = [NSMutableDictionary new];
    }
    
    return _submissionsDictionary;
}

- (void)setCourse:(CKICourse *)course {
    [self clearAssignmentsData];
    self.section = nil;
    
    _course = course;
}

- (void)setAssignment:(CKIAssignment *)assignment {
    [self clearSubmissionsData];
    [self clearStudentsData];
    
    _assignment = assignment;
}

- (void)setStudentSortOrder:(CSGStudentSortOrder)sortOrder success:(void(^)(void))success {
    self.studentSortOrder = sortOrder;
    
    [self reloadDataStructures];
    
    if (success) {
        success();
    }
}

- (void)setSection:(CKISection *)section {
    _section = section;
    
    [self reloadDataStructures];
}

- (void)setSelectedSubmissionRecord:(CKISubmissionRecord *)selectedSubmissionRecord {
    // don't return if they are equal because we want to set the submissionAttempt either way
    if (_selectedSubmissionRecord != selectedSubmissionRecord) {
        _selectedSubmissionRecord = selectedSubmissionRecord;
    }
    
    // pick default attempt (attachment will be called as well)
    self.selectedSubmission = [_selectedSubmissionRecord defaultAttempt];
    
}

- (void)setSelectedSubmission:(CKISubmission *)selectedSubmission {
    // don't return if they are equal because we want to set the attachment either way
    if (_selectedSubmission != selectedSubmission) {
        _selectedSubmission = selectedSubmission;
    }
    
    // pick default attachment
    if (_selectedSubmission && ![_selectedSubmission isEqual:[NSNull null]]) {
        self.selectedAttachment = [_selectedSubmission defaultAttachment];
    }
}

- (void)clearCoursesData {
    self.favoriteCourses = nil;
    self.courses = nil;
}

- (void)clearAssignmentsData {
    self.assignmentGroups = nil;
    self.assignmentsByGroupID = nil;
    
    self.sections = nil;
}

- (void)clearSubmissionsData {
    
    self.submissionsDictionary = nil;
    self.submissionRecords = nil;
    self.sortedSubmissionRecords = nil;
}

- (void)clearStudentsData {
    self.students = nil;
    self.sortedStudentsByName = nil;
    self.sortedStudentsByGrade = nil;
}

- (void)clearData {
    [self clearCoursesData];
    [self clearAssignmentsData];
    [self clearSubmissionsData];
    [self clearStudentsData];
    
    self.studentSortOrder = CSGStudentSortOrderGrade;

    self.course = nil;
    self.assignment = nil;
    self.section = nil;
    self.selectedStudent = nil;
    self.selectedSubmissionRecord = nil;
    self.selectedSubmission = nil;
    self.selectedAttachment = nil;
}

#pragma mark - Fetch Model Methods

- (void)fetchAssignmentModel:(CKIAssignment *)assignment withCourse:(CKICourse *)course withSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    RACSignal *fetchCourse = [[TheKeymaster currentClient] fetchCourseWithCourseID:[course id]];
    RACSignal *fetchAssignments = [[TheKeymaster currentClient] fetchAssignmentsForContext:course includeSubmissions:YES];
    
    RACSignal *fetchSelectedAssignment = [fetchAssignments flattenMap:^RACSignal *(NSArray *assignments) {
        __block CKIAssignment *selectedAssignment;
        [assignments enumerateObjectsUsingBlock:^(CKIAssignment *nextAssignment, NSUInteger idx, BOOL *stop) {
            if ([assignment.id isEqualToString:nextAssignment.id]) {
                selectedAssignment = nextAssignment;
                *stop = YES;
                return;
            }
        }];
        
        if (selectedAssignment) {
            return [RACSignal return:selectedAssignment];
        }
        
        return [RACSignal empty];
    }];
    
    RACSignal *assignmentWithCourse = [RACSignal combineLatest:@[fetchCourse, fetchSelectedAssignment] reduce:^(CKICourse *course, CKIAssignment *assignment){
        assignment.context = course;
        return assignment;
    }];
    
    [assignmentWithCourse subscribeNext:^(CKIAssignment *assignment) {
        [self setCourse:(CKICourse *)assignment.context];
        [self setAssignment:assignment];
    } error:^(NSError *error) {
        DDLogError(@"Error while fetching assignment models for course %@. Error: %@",[course id], error);
        failure(error);
    } completed:^{
        success();
    }];
 }

@end







