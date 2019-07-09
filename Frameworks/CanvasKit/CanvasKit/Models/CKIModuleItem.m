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
