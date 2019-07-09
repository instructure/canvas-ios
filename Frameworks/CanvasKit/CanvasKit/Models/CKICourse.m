//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "CKICourse.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "CKITerm.h"
#import "CKIEnrollment.h"
@import ReactiveObjC;

@implementation CKICourse

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"sisCourseID": @"sis_course_id",
        @"name": @"name",
        @"courseCode": @"course_code",
        @"workflowState": @"workflow_state",
        @"accountID": @"account_id",
        @"startAt": @"start_at",
        @"endAt": @"end_at",
        @"enrollments": @"enrollments",
        @"calendar": @"calendar.ics",
        @"defaultView": @"default_view",
        @"syllabusBody": @"syllabus_body",
        @"term": @"term",
        @"applyAssignmentGroupWeights": @"apply_assignment_group_weights",
        @"publicSyllabus" : @"public_syllabus",
        @"canCreateDiscussionTopics" : @"permissions.create_discussion_topic",
        @"hideFinalGrades" : @"hide_final_grades",
        @"needsGradingCount" : @"needs_grading_count"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)calendarJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)startAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)endAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)termJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKITerm class]];
}

+ (NSValueTransformer *)enrollmentsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIEnrollment class]];
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"courses"] stringByAppendingPathComponent:self.id];
}

- (BOOL)currentUserEnrolledAsStudentOrObserver {
    return [self.enrollments.rac_sequence filter:^BOOL(CKIEnrollment *enrollment) {
        return enrollment.type == CKIEnrollmentTypeStudent || enrollment.type == CKIEnrollmentTypeObserver;
    }].array.count > 0;
}

- (NSString *)currentGradingPeriodID {
    return [[[self.enrollments.rac_sequence filter:^BOOL(CKIEnrollment *enrollment) {
        return enrollment.multipleGradingPeriodsEnabled;
    }] map:^id(CKIEnrollment *studentEnrollment) {
        return studentEnrollment.currentGradingPeriodID;
    }].array firstObject];
}

@end
