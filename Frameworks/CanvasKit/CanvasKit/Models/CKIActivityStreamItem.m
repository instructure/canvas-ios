//
//  CKIActivityStreamItem.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIActivityStreamItem.h"
#import "CKIActivityStreamDiscussionTopicItem.h"
#import "CKIActivityStreamAnnouncementItem.h"
#import "CKIActivityStreamConversationItem.h"
#import "CKIActivityStreamMessageItem.h"
#import "CKIActivityStreamSubmissionItem.h"
#import "CKIActivityStreamConferenceItem.h"
#import "CKIActivityStreamCollaborationItem.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKIActivityStreamItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"courseID": @"course_id",
        @"groupID": @"group_id",
        @"createdAt": @"created_at",
        @"updatedAt": @"updated_at",
        @"htmlURL": @"html_url",
        @"isRead": @"read_state"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)courseIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)groupIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)createdAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)updatedAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)urlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)htmlURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

#pragma mark - Factory

static NSString *kCKIActivityStreamDicussionItemType = @"DiscussionTopic";
static NSString *kCKIActivityStreamAnnouncementItemType = @"Announcement";
static NSString *kCKIActivityStreamConversationItemType = @"Conversation";
static NSString *kCKIActivityStreamMessageItemType = @"Message";
static NSString *kCKIActivityStreamSubmissionItemType = @"Submission";
static NSString *kCKIActivityStreamConferenceItemType = @"WebConference";
static NSString *kCKIActivityStreamCollaborationItemType = @"Collaboration";

+ (NSValueTransformer *)activityStreamItemTransformer
{
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *jsonDictionary) {
        NSDictionary *itemKeyToClassMapping = @{
            kCKIActivityStreamDicussionItemType: [CKIActivityStreamDiscussionTopicItem class],
            kCKIActivityStreamAnnouncementItemType: [CKIActivityStreamAnnouncementItem class],
            kCKIActivityStreamConversationItemType: [CKIActivityStreamConversationItem class],
            kCKIActivityStreamMessageItemType: [CKIActivityStreamMessageItem class],
            kCKIActivityStreamSubmissionItemType: [CKIActivityStreamSubmissionItem class],
            kCKIActivityStreamConferenceItemType: [CKIActivityStreamConferenceItem class],
            kCKIActivityStreamCollaborationItemType: [CKIActivityStreamCollaborationItem class]
        };
        
        NSString *type = jsonDictionary[@"type"];
        Class targetClass = itemKeyToClassMapping[type];
        CKIActivityStreamItem *streamItem = [targetClass modelFromJSONDictionary:jsonDictionary];
        return streamItem;
    }];
}

@end
