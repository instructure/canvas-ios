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

#import "CKIConversationRecipient.h"
#import "NSArray+CKIAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

NSString *const CKIRecipientTypeUser = @"user";
NSString *const CKIRecipientTypeContext = @"context";

@implementation CKIConversationRecipient

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error
{
    NSDictionary *defaults = @{
                               @"type": CKIRecipientTypeUser, // Default to user, unless context is set explicitly
                               @"userCount": @0,
                               };
    dictionaryValue = [defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue];
    return [super initWithDictionary:dictionaryValue error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"avatarURL": @"avatar_url",
                               @"commonGroups": @"common_groups",
                               @"commonCourses": @"common_courses",
                               @"userCount": @"user_count",
                               @"containingContextName": @"context_name"
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}


+ (NSValueTransformer *)idJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id ident) {
        if ([ident isKindOfClass:[NSNumber class]]) {
            return [ident stringValue];
        } else {
            return ident;
        }
    } reverseBlock:^id(NSString *ident) {
        // contexts can have an id of type string with format course_blahblah and such. (Non-integers)
        if ([[NSScanner scannerWithString:ident] scanLongLong:nil]) {
            return [NSNumber numberWithLongLong:[ident longLongValue]];
        } else {
            return ident;
        }
    }];
}

+ (NSValueTransformer *)avatarURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)commonGroupsJSONTransformer
{
    return [self courseEnrollmentJSONTransformer];
}

+ (NSValueTransformer *)commonCoursesJSONTransformer
{
    return [self courseEnrollmentJSONTransformer];
}


#pragma mark - Helpers

+ (NSValueTransformer *)courseEnrollmentJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSDictionary *json) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        for (NSNumber *key in [json allKeys]) {
            NSArray *jsonEnrollmentTypes = json[key];
            NSArray *enrollmentTypes = [jsonEnrollmentTypes arrayByMappingValues:@{
                                                                                   @"StudentEnrollment": @"student",
                                                                                   @"TeacherEnrollment": @"teacher",
                                                                                   @"TaEnrollment": @"ta",
                                                                                   @"ObserverEnrollment": @"observer",
                                                                                   @"Member": @"member"
                                                                                   }];
            result[key] = enrollmentTypes;
        }
        return [result copy];
    } reverseBlock:^id(NSDictionary *map) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        for (NSNumber *key in [map allKeys]) {
            NSArray *enrollmentTypes = map[key];
            NSArray *jsonEnrollmentTypes = [enrollmentTypes arrayByMappingValues:@{
                                                                                  @"student": @"StudentEnrollment",
                                                                                  @"teacher": @"TeacherEnrollment",
                                                                                  @"ta": @"TaEnrollment",
                                                                                  @"observer": @"ObserverEnrollment",
                                                                                  @"member": @"Member"
                                                                                  }];
            result[key] = jsonEnrollmentTypes;
        }
        return [result copy];
    }];
}

@end
