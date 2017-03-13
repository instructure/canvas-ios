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
