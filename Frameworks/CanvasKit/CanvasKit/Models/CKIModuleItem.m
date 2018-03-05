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

#import "CKIModuleItem.h"
#import "CKIModule.h"

#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

NSString * const CKIModuleItemTypeFile = @"File";
NSString * const CKIModuleItemTypePage = @"Page";
NSString * const CKIModuleItemTypeDiscussion = @"Discussion";
NSString * const CKIModuleItemTypeAssignment = @"Assignment";
NSString * const CKIModuleItemTypeQuiz = @"Quiz";
NSString * const CKIModuleItemTypeSubHeader = @"SubHeader";
NSString * const CKIModuleItemTypeExternalURL = @"ExternalUrl";
NSString * const CKIModuleItemTypeExternalTool = @"ExternalTool";

NSString * const CKIModuleItemCompletionRequirementMustView = @"must_view";
NSString * const CKIModuleItemCompletionRequirementMustSubmit = @"must_submit";
NSString * const CKIModuleItemCompletionRequirementMustContribute = @"must_contribute";
NSString * const CKIModuleItemCompletionRequirementMinimumScore = @"min_score";
NSString * const CKIModuleItemCompletionRequirementMustMarkDone = @"must_mark_done";

@interface CKIModuleItem ()

@end

@implementation CKIModuleItem

@dynamic context;

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"contentID": @"content_id",
        @"pageID": @"page_url",
        @"htmlURL": @"html_url",
        @"apiURL": @"url",
        @"externalURL": @"external_url",
        @"completionRequirement": @"completion_requirement.type",
        @"minimumScore": @"completion_requirement.min_score",
        @"completed": @"completion_requirement.completed",
        @"pointsPossible": @"content_details.points_possible",
        @"dueAt": @"content_details.due_at",
        @"unlockAt": @"content_details.unlock_at",
        @"lockAt": @"content_details.lock_at"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)contentIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)htmlURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)apiURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)externalURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)dueAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)unlockAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)lockAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

- (NSString *)itemID
{
    return self.contentID ?: [self.pageID absoluteString];
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"items"] stringByAppendingPathComponent:self.id];
}
@end
