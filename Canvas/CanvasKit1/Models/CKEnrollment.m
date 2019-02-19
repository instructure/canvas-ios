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
    
    

#import "CKEnrollment.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKEnrollment

@synthesize ident, courseId, courseSectionId, enrollmentState, limitPrivilegesToCourseSection;
@synthesize rootAccountId, typeString, type, userId, associatedUserId, htmlURL, gradeURL;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        [self updateWithInfo:info];
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    ident = [info[@"id"] unsignedLongLongValue];
    courseId = [info[@"course_id"] unsignedLongLongValue];
    courseSectionId = [info[@"course_section_id"] unsignedLongLongValue];
    enrollmentState = [info objectForKeyCheckingNull:@"enrollment_state"];
    limitPrivilegesToCourseSection = [[info objectForKeyCheckingNull:@"limit_privileges_to_course_section"] boolValue];
    rootAccountId = [info[@"root_account_id"] unsignedLongLongValue];
    [self setTypeFromString:[info objectForKeyCheckingNull:@"type"]];
    userId = [info[@"user_id"] unsignedLongLongValue];
    associatedUserId = [[info objectForKeyCheckingNull:@"associated_user_id"] unsignedLongLongValue];
    
    NSString *htmlURLString = [info objectForKeyCheckingNull:@"html_url"];
    if (htmlURLString) {
        htmlURL = [NSURL URLWithString:htmlURLString];
    }
    
    NSDictionary *grade = [info objectForKeyCheckingNull:@"grades"];
    if (grade) {
        NSString *gradeURLString = [grade objectForKeyCheckingNull:@"html_url"];
        if (gradeURLString) {
            gradeURL = [NSURL URLWithString:gradeURLString];
        }
    }
}

- (NSString *)typeString
{
    NSString *enrollment = @"";
    switch (type) {
        case CKEnrollmentTypeTeacher:
            enrollment = @"TeacherEnrollment";
            break;
        case CKEnrollmentTypeTA:
            enrollment = @"TaEnrollment";
            break;
        case CKEnrollmentTypeStudent:
            enrollment = @"StudentEnrollment";
            break;
        case CKEnrollmentTypeObserver:
            enrollment = @"ObserverEnrollment";
            break;
        default:
            break;
    }
    return enrollment;
}

- (NSString *)shortName
{
    NSString *name = @"";
    switch (type) {
        case CKEnrollmentTypeTeacher:
            name = NSLocalizedString(@"Teacher", @"Short name for teacher enrollment");
            break;
        case CKEnrollmentTypeTA:
            name = NSLocalizedString(@"TA", @"Short name for TA enrollment");;
            break;
        case CKEnrollmentTypeStudent:
            name = NSLocalizedString(@"Student", @"Short name for student enrollment");;
            break;
        case CKEnrollmentTypeObserver:
            name = NSLocalizedString(@"Observer", @"Short name for observer enrollment");;
            break;
        default:
            break;
    }
    return name;
}

- (void)setTypeFromString:(NSString *)aString
{
    if ([aString isEqualToString:@"StudentEnrollment"]) {
        type = CKEnrollmentTypeStudent;
    }
    else if ([aString isEqualToString:@"TeacherEnrollment"]) {
        type = CKEnrollmentTypeTeacher;
    }
    else if ([aString isEqualToString:@"TaEnrollment"]) {
        type = CKEnrollmentTypeTA;
    }
    else if ([aString isEqualToString:@"ObserverEnrollment"]) {
        type = CKEnrollmentTypeObserver;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<CKEnrollment: %p  (%@)>", self, self.typeString];
}

+ (NSString *)simpleEnrollmentStringForType:(CKEnrollmentType)type
{
    NSString *enrollment = @"";
    switch (type) {
        case CKEnrollmentTypeTeacher:
            enrollment = @"teacher";
            break;
        case CKEnrollmentTypeTA:
            enrollment = @"ta";
            break;
        case CKEnrollmentTypeStudent:
            enrollment = @"student";
            break;
        case CKEnrollmentTypeObserver:
            enrollment = @"observer";
            break;
        default:
            break;
    }
    return enrollment;
}

- (NSUInteger)hash {
    return (NSUInteger)ident;
}

@end
