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
    
    

#import "CKCourse.h"
#import "CKAssignment.h"
#import "CKEnrollment.h"
#import "CKSubmission.h"
#import "CKTerm.h"
#import "ISO8601DateFormatter.h"
#import "NSDictionary+CKAdditions.h"

@interface CKCourse ()
@property (strong, nonatomic) NSMutableDictionary *enrollments;
@end

@implementation CKCourse

- (id)init {
    return [self initWithInfo:nil];
}

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        _students = [[NSMutableArray alloc] init];
        _assignments = [[NSMutableArray alloc] init];
        _assignmentGroups = [[NSMutableArray alloc] init];
        _calendarEvents = [[NSMutableArray alloc] init];
        _enrollments = [NSMutableDictionary new];
        
        [self updateWithInfo:info];
    }
    return self;
}

- (id)initWithID:(uint64_t)ident {
    self = [super init];
    if (self) {
        _ident = ident;
    }
    return self;
}

- (id)initPlaceholderCourse
{
    NSDictionary *info = @{@"id": @0,
                          @"name": @"Placeholder",
                          @"course_code": @"placeholder",
                          @"needs_grading_count": @0};
    self = [self initWithInfo:info];
    
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.ident = [[info objectForKeyCheckingNull:@"id"] unsignedLongLongValue];
    self.name = [info objectForKeyCheckingNull:@"name"];
    self.courseCode = [info objectForKeyCheckingNull:@"course_code"];
    self.needsGradingCount = [[info objectForKeyCheckingNull:@"needs_grading_count"] integerValue];
    self.hideFinalGrades = [[info objectForKeyCheckingNull:@"hide_final_grades"] boolValue];
    
    NSDictionary *permissions = [info objectForKeyCheckingNull:@"permissions"];
    if (permissions) {
        self.createDiscussionTopics = [permissions[@"create_discussion_topic"] boolValue];
    }

    NSString *defaultView = [info objectForKeyCheckingNull:@"default_view"];
    if ([defaultView isEqualToString:@"feed"]) {
        self.homepage = CKCourseHomepageFeed;
    } else if ([defaultView isEqualToString:@"wiki"]) {
        self.homepage = CKCourseHomepageFrontPage;
    } else if ([defaultView isEqualToString:@"modules"]) {
        self.homepage = CKCourseHomepageModules;
    } else if ([defaultView isEqualToString:@"assignments"]) {
        self.homepage = CKCourseHomepageAssignments;
    } else if ([defaultView isEqualToString:@"syllabus"]) {
        self.homepage = CKCourseHomepageSyllabus;
    } else {
        self.homepage = CKCourseHomepageOther;
    }
    
    if ([info objectForKeyCheckingNull:@"term"]) {
        CKTerm *term = [[CKTerm alloc] initWithInfo:[info objectForKeyCheckingNull:@"term"]];
        _term = term;
    }
    
    NSMutableArray *tempLoggedInUserEnrollments = [NSMutableArray new];
    for (NSDictionary *dictionary in [info objectForKeyCheckingNull:@"enrollments"]) {        
        CKEnrollment *enrollment = [CKEnrollment new];
        enrollment.courseId = self.ident;
        
        NSString *enrollmentTypeShort = [dictionary objectForKeyCheckingNull:@"type"];
        if ([enrollmentTypeShort isEqualToString:@"student"]) {
            enrollment.type = CKEnrollmentTypeStudent;
            
            self.currentScore = [[dictionary objectForKeyCheckingNull:@"computed_current_score"] floatValue];
            self.finalScore = [[dictionary objectForKeyCheckingNull:@"computed_final_score"] floatValue];
            self.finalGrade = [dictionary objectForKeyCheckingNull:@"computed_final_grade"];
        }
        else if ([enrollmentTypeShort isEqualToString:@"teacher"]) {
            enrollment.type = CKEnrollmentTypeTeacher;
        }
        else if ([enrollmentTypeShort isEqualToString:@"ta"]) {
            enrollment.type = CKEnrollmentTypeTA;
        }
        else if ([enrollmentTypeShort isEqualToString:@"observer"]) {
            enrollment.type = CKEnrollmentTypeObserver;
        }
        [tempLoggedInUserEnrollments addObject:enrollment];
    }
    self.loggedInUserEnrollments = tempLoggedInUserEnrollments;
    
    if ([info objectForKeyCheckingNull:@"start_at"]) {
        _startDate = [self.apiDateFormatter dateFromString:[info objectForKeyCheckingNull:@"start_at"]];
    }
    if ([info objectForKeyCheckingNull:@"end_at"]) {
        _endDate = [self.apiDateFormatter dateFromString:[info objectForKeyCheckingNull:@"end_at"]];
    }
    
    self.syllabusBody = [info objectForKeyCheckingNull:@"syllabus_body"];
}

- (ISO8601DateFormatter *)dateFormatter {
    static ISO8601DateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [ISO8601DateFormatter new];
    });
    return dateFormatter;
}

- (void)updateNeedsGradingCount
{
    NSInteger count = 0;
    for (CKAssignment *assignment in self.assignments) {
        count += assignment.needsGradingCount;
    }
    
    self.needsGradingCount = count;
}

- (NSArray *)enrollmentsForUserId:(uint64_t)userId
{
    return self.enrollments[@(userId)];
}

- (void)addEnrollment:(CKEnrollment *)enrollment
{
    NSMutableArray *userEnrollments = [NSMutableArray arrayWithArray:[self enrollmentsForUserId:enrollment.userId]];
        
    BOOL enrollmentFound = NO;
    for (CKEnrollment *userEnrollment in userEnrollments) {
        if (userEnrollment.ident == enrollment.ident) {
            enrollmentFound = YES;
        }
    }
    if (!enrollmentFound) {
        [userEnrollments addObject:enrollment];
    }
    (self.enrollments)[@(enrollment.userId)] = userEnrollments;
}

- (BOOL)userId:(uint64_t)userId hasEnrollmentOfType:(CKEnrollmentType)type
{
    NSArray *userEnrollments = self.enrollments[@(userId)];
    for (CKEnrollment *enrollment in userEnrollments) {
        if (enrollment.type == type) {
            return true;
        }
    }
    return false;
}

- (BOOL)loggedInUserHasEnrollmentOfType:(CKEnrollmentType)type
{
    for (CKEnrollment *enrollment in self.loggedInUserEnrollments) {
        if (type == enrollment.type) {
            return true;
        }
    }
    return false;
}

+ (NSArray *)propertiesToExcludeFromEqualityComparison {
    return @[ @"students", @"assignments", @"assignmentGroups", @"calendarEvents", @"loggedInUserEnrollments", @"currentScore", @"finalScore", @"finalGrade", @"syllabusBody", @"enrollments"];
}

- (NSUInteger)hash {
    return (NSUInteger)self.ident;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<CKCourse: %p  (%@)>", self, self.name];
}

#pragma mark - URLs

- (NSURL *)modulesURL {
    NSString *urlString = [NSString stringWithFormat:@"/courses/%qu/modules", self.ident];
    return [NSURL URLWithString:urlString];
}

@end
