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
    
    

#import "CKDiscussionEntry.h"
#import "CKDiscussionTopic.h"
#import "CKAttachment.h"
#import "ISO8601DateFormatter.h"
#import "CKSubmission.h"
#import "CKStudent.h"
#import "CKCourse.h"
#import "NSString+CKAdditions.h"
#import "NSDictionary+CKAdditions.h"
#import "CKMediaComment.h"

NSString *CKDiscussionEntryMediaToken = @"instructure_inline_media_comment_on_ipad";

@implementation CKDiscussionEntry

@synthesize discussionTopic, student, internalIdent, userIdent, entryMessage, createdAt, updatedAt, attachments;
@synthesize ident;
@synthesize parentEntryIdent;
@synthesize userName;
@synthesize replies;
@synthesize userAvatarURL;
@synthesize unread;
@synthesize parentEntry;
@synthesize deleted;
@synthesize allowsReplies = _allowsReplies;

// GET /api/v1/courses/:course_id/discussion_topics/:topic_id/entries
//[ {
//    "id": 1019,
//    "user_id": 7086,
//    "user_name": "nobody@example.com",
//    "message": "Newer entry",
//    "created_at": "2011-11-03T21:33:29Z",
//    "permissions": {
//        "delete": true, "reply": true, "read": true,
//        "attach": true, "create": true, "update": true },
//    "attachment": {
//        "content-type": "unknown/unknown",
//        "url": "http://www.example.com/files/681/download?verifier=JDG10Ruitv8o6LjGXWlxgOb5Sl3ElzVYm9cBKUT3",
//        "filename": "content.txt",
//        "display_name": "content.txt" }
//  },
// {
//     "id": 1016,
//     "user_id": 7086,
//     "user_name": "nobody@example.com",
//     "message": "first top-level entry",
//     "created_at": "2011-11-03T21:32:29Z",
//     "permissions": {
//         "delete": true, "reply": true, "read": true,
//         "attach": true, "create": true, "update": true },
//     "recent_replies": [
//                        {
//                            "id": 1017,
//                            "user_id": 7086,
//                            "user_name": "nobody@example.com",
//                            "message": "Reply message",
//                            "created_at": "2011-11-03T21:32:29Z",
//                            "permissions": {
//                                "delete": true, "reply": true, "read": true,
//                                "attach": true, "create": true, "update": true },
//                        } ],
//     "has_more_replies": false } ]

- (id)init
{
    self = [super init];
    if (self) {
        attachments = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)info andDiscussionTopic:(CKDiscussionTopic *)aDiscussionTopic entryRatings:(NSDictionary*)entryRatings
{
    self = [super init];
    if (self) {
        self.discussionTopic = aDiscussionTopic;
        
        self.ident = [info[@"id"] unsignedLongLongValue];
        self.userIdent = [info[@"user_id"] unsignedLongLongValue];
        self.userName = [info objectForKeyCheckingNull:@"user_name"];
        
        NSDictionary *user = info[@"user"];
        if (user) {
            NSString *displayName = user[@"display_name"];
            NSString *avatarURL = user[@"avatar_image_url"];
            if (displayName) {
                self.userName = displayName;
            }
            
            if (avatarURL) {
                self.userAvatarURL = [NSURL URLWithString:avatarURL];
            }
        }
        
        if([info valueForKey:@"rating_sum"] && [info valueForKey:@"rating_sum"] != [NSNull null]) {
            self.likeCount = [info[@"rating_sum"] integerValue];
            if(entryRatings && [entryRatings valueForKey:[NSString stringWithFormat:@"%@", @(self.ident)]]) {
                self.isLiked = [entryRatings[[NSString stringWithFormat:@"%@", @(self.ident)]] boolValue];
            }
        } else {
            self.likeCount = 0;
            self.isLiked = NO;
        }
        
        self.parentEntryIdent = [[info objectForKeyCheckingNull:@"parent_id"] unsignedLongLongValue];

        NSString *dateString = info[@"created_at"];
        if (dateString) {
            ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
            self.createdAt = [dateFormatter dateFromString:dateString];
        }
        
        // find student
        self.student = [CKSubmission studentForInfo:info andAssignment:self.discussionTopic.assignment];
        
        self.deleted = [[info objectForKeyCheckingNull:@"deleted"] boolValue];
        
        attachments = [[NSMutableDictionary alloc] init];
                
        [self updateWithInfo:info];
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    // replacing &amp; is a hack to get certain images to load. the issue was that in some cases the url for an image
    // in an entry would have it's query param's `&` escaped to `&amp;` this prevented the image from loading.
    // See MBL-1423
    self.entryMessage = [[info objectForKeyCheckingNull:@"message"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    NSString *dateString = info[@"updated_at"];
    if (dateString) {
        ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
        self.updatedAt = [dateFormatter dateFromString:dateString];
    }
    
    for (NSDictionary *entryAttachmentInfo in info[@"attachments"]) {        
        CKAttachment *attachment = [[CKAttachment alloc] initWithInfo:entryAttachmentInfo];
        attachments[@(attachment.ident)] = attachment;
    }
    
    NSMutableArray *tmpReplies = [NSMutableArray array];
    for (NSDictionary *replyInfo in info[@"recent_replies"]) {
        CKDiscussionEntry *entry = [[CKDiscussionEntry alloc] initWithInfo:replyInfo andDiscussionTopic:nil entryRatings:nil];
        [tmpReplies addObject:entry];
    }
    self.replies = tmpReplies;
}

- (BOOL)isEqual:(id)object {
    return [super isEqual:object];
}

- (NSUInteger)hash {
    return (NSUInteger)self->ident << (10 + self->entryMessage.hash);
}

- (NSString *)description {
    NSString *entryMessagePreview = nil;
    if (self.entryMessage.length < 100) {
        entryMessagePreview = self.entryMessage;
    }
    else {
        entryMessagePreview = [NSString stringWithFormat:NSLocalizedString(@"%@...",@"Word and ellipses"), [self.entryMessage substringToIndex:97]];
    }
    return [NSString stringWithFormat:@"<CKDiscussionEntry: %qu (%@)>", self.ident, entryMessagePreview];
}


- (NSString *)internalIdent
{
    if (internalIdent == nil) {
        internalIdent = [NSString stringWithFormat:@"%qu-%@", self.userIdent, [[self.createdAt description] md5Hash]];
    }
    return internalIdent;
}

- (NSString *)JSONString
{
    NSDateFormatter *dateFormatterDate = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatterTime = [[NSDateFormatter alloc] init];
    [dateFormatterDate setDateFormat:@"MMM d"];
    [dateFormatterTime setTimeStyle:NSDateFormatterShortStyle];
    NSString *formattedUpdatedAt = [NSString stringWithFormat:NSLocalizedString(@"%@ at %@",@"something at something"),
                           [dateFormatterDate stringFromDate:self.updatedAt],
                           [dateFormatterTime stringFromDate:self.updatedAt]];
    
    NSMutableArray *attachmentInfoArray = [NSMutableArray array];
    for (NSNumber *attachmentKey in self.attachments) {
        CKAttachment *tempAttachment = (self.attachments)[attachmentKey];
        if (tempAttachment.type == CKAttachmentTypeDefault) {
            [attachmentInfoArray addObject:[tempAttachment dictionaryValue]];
        }
    }
    
    [attachmentInfoArray sortUsingSelector:@selector(compareAttachmentsIndex:)];
    
    NSDictionary *entryInfo = @{@"internalIdent": self.internalIdent,
                               @"date": formattedUpdatedAt,
                               @"entryMessage": self.entryMessage,
                               @"attachments": attachmentInfoArray,
                               @"userName": self.userName};
    
    NSError *error;
    NSString *entryJSON;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:entryInfo options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        NSLog(@"Error getting json data from dictionary: %@", error);
    } else {
        entryJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return entryJSON;
}

- (BOOL)allowsReplies {
    if (self.deleted ||
        (self.discussionTopic.type == CKDiscussionTopicTypeSideComment && self.parentEntryIdent != 0)) {
        return NO;
    }
    else {
        return YES;
    }

}

- (int)recursiveReplyCount {
    int count = 0;
    for (CKDiscussionEntry *reply in replies) {
        count += 1; // 1 for every child
        count += reply.recursiveReplyCount; // plus whatever it reports
    }
    return count;
}

- (int)recursiveUnreadCount {
    int count = 0;
    for (CKDiscussionEntry *reply in replies) {
        if (reply.unread) {
            count += 1; // 1 for every child
        }
        count += reply.recursiveUnreadCount; // plus whatever it reports
    }
    return count;
}

- (BOOL) hasUnreadDescendant {
    for (CKDiscussionEntry *entry in replies) {
        if (entry.unread || entry.hasUnreadDescendant) {
            return YES;
        }
    }
    return NO;
}

- (void)setUnread:(BOOL)value {
    if (value == unread) {
        return;
    }
    
    unread = value;
    
    [self.discussionTopic recalculateUnreadChildren];
}

@end
