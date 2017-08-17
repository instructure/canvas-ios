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

#import "CKIEnrollment.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

static NSString *const STUDENT_ENROLLMENT_KEY1 = @"student";
static NSString *const STUDENT_ENROLLMENT_KEY2 = @"StudentEnrollment";

static NSString *const TEACHER_ENROLLMENT_KEY1 = @"teacher";
static NSString *const TEACHER_ENROLLMENT_KEY2 = @"TeacherEnrollment";

static NSString *const TA_ENROLLMENT_KEY1 = @"ta";
static NSString *const TA_ENROLLMENT_KEY2 = @"TAEnrollment";

static NSString *const OBSERVER_ENROLLMENT_KEY1 = @"observer";
static NSString *const OBSERVER_ENROLLMENT_KEY2 = @"ObserverEnrollment";

static NSString *const MEMBER_ENROLLMENT_KEY1 = @"member";
static NSString *const MEMBER_ENROLLMENT_KEY2 = @"MemberEnrollment";

static NSString *const DESIGNER_ENROLLMENT_KEY1 = @"designer";
static NSString *const DESIGNER_ENROLLMENT_KEY2 = @"DesignerEnrollment";

@implementation CKIEnrollment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
       @"computedFinalScore": @"computed_final_score",
       @"computedCurrentScore": @"computed_current_score",
       @"computedFinalGrade": @"computed_final_grade",
       @"computedCurrentGrade": @"computed_current_grade",
       @"currentGradingPeriodID": @"current_grading_period_id",
       @"currentGradingPeriodScore": @"current_period_computed_current_score",
       @"currentGradingPeriodGrade": @"current_period_computed_current_grade",
       @"multipleGradingPeriodsEnabled": @"multiple_grading_periods_enabled",
       @"sectionID": @"course_section_id",
       @"state": @"enrollment_state",
       @"limitPrivilegesToCourseSection": @"limit_privileges_to_course_section",
   };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)sectionIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)typeJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *type) {
        if ([type isEqualToString:STUDENT_ENROLLMENT_KEY1] || [type isEqualToString:STUDENT_ENROLLMENT_KEY2]) {
            return @(CKIEnrollmentTypeStudent);
        } else if ([type isEqualToString:TEACHER_ENROLLMENT_KEY1] || [type isEqualToString:TEACHER_ENROLLMENT_KEY2]) {
            return @(CKIEnrollmentTypeTeacher);
        } else if ([type isEqualToString:TA_ENROLLMENT_KEY1] || [type isEqualToString:TA_ENROLLMENT_KEY2]) {
            return @(CKIEnrollmentTypeTA);
        } else if ([type isEqualToString:OBSERVER_ENROLLMENT_KEY1] || [type isEqualToString:OBSERVER_ENROLLMENT_KEY2]) {
            return @(CKIEnrollmentTypeObserver);
        } else if ([type isEqualToString:DESIGNER_ENROLLMENT_KEY1] || [type isEqualToString:DESIGNER_ENROLLMENT_KEY2]) {
            return @(CKIEnrollmentTypeStudent);
        }
        return @(CKIEnrollmentTypeUnknown);
    } reverseBlock:^id(NSNumber *state) {
        switch ([state integerValue]) {
            case CKIEnrollmentTypeStudent:
                return STUDENT_ENROLLMENT_KEY1;
            case CKIEnrollmentTypeTeacher:
                return TEACHER_ENROLLMENT_KEY1;
            case CKIEnrollmentTypeTA:
                return TA_ENROLLMENT_KEY1;
            case CKIEnrollmentTypeObserver:
                return OBSERVER_ENROLLMENT_KEY1;
            case CKIEnrollmentTypeDesigner:
                return DESIGNER_ENROLLMENT_KEY1;
            default:
                return @"";
        }
        return @"";
    }];
}

- (BOOL)isStudent
{
    return self.type == CKIEnrollmentTypeStudent;
}

@end
