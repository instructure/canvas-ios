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

#import "CKIPollSession.h"
#import "CKIPollSubmission.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKIPollSession

+ (NSString *)keyForJSONAPIContent
{
    return @"poll_sessions";
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"submissions": @"poll_submissions",
                               @"hasSubmitted":@"has_submitted",
                               @"courseID": @"course_id",
                               @"sectionID": @"course_section_id",
                               @"isPublished": @"is_published",
                               @"hasPublicResults": @"has_public_results",
                               @"pollID": @"poll_id",
                               @"created": @"created_at",
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)idJSONTransformer
{
    return nil;
}

+ (NSValueTransformer *)submissionsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIPollSubmission class]];
}

+ (NSValueTransformer *)createdJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)courseIDJSONTransformer
{
    return nil;
}

+ (NSValueTransformer *)pollIDJSONTransformer
{
    return nil;
}

+ (NSValueTransformer *)sectionIDJSONTransformer
{
    return nil;
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"poll_sessions"] stringByAppendingPathComponent:self.id];
}

@end
