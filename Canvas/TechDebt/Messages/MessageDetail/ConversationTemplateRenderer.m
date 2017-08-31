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
    
    

#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit1/NSArray+CKAdditions.h>

#import "ConversationTemplateRenderer.h"
#import "NSArray_in_additions.h"
#import "NSString+IN_Additions.h"

@implementation ConversationTemplateRenderer {
    NSDateFormatter *conversationDateFormatter;
    
    __weak CKConversation *currentConversation;
}

@synthesize currentUserID;

- (id)init {
    self = [super init];
    if (self) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.doesRelativeDateFormatting = YES;
        
        conversationDateFormatter = formatter;
    }
    return self;
}

- (NSString *)conversationBodyHTMLAfterCollapsingQuotes:(CKConversationMessage *)message {
    NSMutableArray *mainBodyLines = [NSMutableArray array];
    NSMutableArray *quotedBodyLines = [NSMutableArray array];
    
    [message.text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if ([line hasPrefix:@">"] || [line hasPrefix:@"&gt;"]) {
            [quotedBodyLines addObject:line];
        }
        else {
            [mainBodyLines addObject:line];
        }
    }];
    
    NSMutableString *finalString = [NSMutableString string];
    [finalString appendString:[mainBodyLines componentsJoinedByString:@"\n"]];
    if (quotedBodyLines.count > 0) {
        [finalString appendFormat:
         @"\n<a onclick='show_quotes(%1$llu);' id='show_quotes_%1$qu'>Show quoted text</a>"
         @"\n<div class='quoted_text' id='quoted_text_%1$llu'>%2$@</div>",
         message.ident,
         [quotedBodyLines componentsJoinedByString:@"\n"]];
    }
    
    return finalString;
}

- (NSString *)resolvedTemplate:(NSString *)constMessageAttachmentTemplate forAttachment:(CKConversationAttachment *)attachment onMessage:(CKConversationMessage *)message {
    
    NSMutableString *attachmentTemplate = [constMessageAttachmentTemplate mutableCopy];
    
    [attachmentTemplate in_replaceOccurrencesOfString:@"{$ATTACHMENT_URL$}" withString:[attachment.directDownloadURL absoluteString]];
    
    
    [attachmentTemplate in_replaceOccurrencesOfString:@"{$ATTACHMENT_NAME$}" withString:attachment.displayName];
    
    return attachmentTemplate;
}

- (NSString *)resolvedTemplate:(NSString *)constSubmissionCommentTemplate forSubmissionComment:(CKSubmissionComment *)comment {
    
    NSMutableString *commentTemplate = [constSubmissionCommentTemplate mutableCopy];
    
    CKConversationRecipient *author = [currentConversation.participants in_firstObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj ident] == comment.authorIdent;
    }];
    
    //Todo: get more info from the API to cover cases where a non-participant in the conversation makes a comment like on a group submission.
    //This is a temporary fix.
    NSString *authorName = [NSString stringWithFormat:@"User %qu", comment.authorIdent];
    NSString *authorAvatarURL = [[[NSBundle bundleForClass:[self class]] URLForResource:@"avatar-default-50" withExtension:@"png"] absoluteString];
    if (author) {
        authorName = author.name;
        authorAvatarURL = [author.avatarURL absoluteString];
    }
        
    [commentTemplate in_replaceOccurrencesOfString:@"{$USER_IDENT$}" withString:[NSString stringWithFormat:@"%lld", comment.authorIdent]];
    
    [commentTemplate in_replaceOccurrencesOfString:@"{$AVATAR_URL$}" withString:authorAvatarURL];
    
    [commentTemplate in_replaceOccurrencesOfString:@"{$DATE$}" withString:[conversationDateFormatter stringFromDate:comment.createdAt]];
    
    [commentTemplate in_replaceOccurrencesOfString:@"{$AUTHOR$}" withString:authorName];
    
    NSString *content = comment.body;
    if (comment.mediaComment) {
        CKMediaComment *mediaComment = comment.mediaComment;
        switch (mediaComment.mediaType) {
            case CKAttachmentMediaTypeAudio:
                
                content = [NSString stringWithFormat:@"<audio controls='controls'><source src='%@' type='%@' /></audio>", mediaComment.directDownloadURL, mediaComment.mediaTypeString];
                
                break;
            case CKAttachmentMediaTypeVideo:
                content = [NSString stringWithFormat:@"<video controls='controls'><source src='%@' type='%@' /></video>", mediaComment.directDownloadURL, mediaComment.mediaTypeString];
                break;
            default:
                break;
        }
    }
    [commentTemplate in_replaceOccurrencesOfString:@"{$CONTENT$}" withString:content];
        
    [commentTemplate in_replaceOccurrencesOfString:@"{$ATTACHMENTS$}" withString:@""];
    
    [commentTemplate in_replaceOccurrencesOfString:@"{$FORWARDS$}" withString:@""];
    
    
    NSString *classes = @"";
    if (author.ident == currentUserID) {
        classes = @"self_author";
    }
    [commentTemplate in_replaceOccurrencesOfString:@"{$CLASSES$}" withString:classes];
    
    return commentTemplate;
}

- (NSString *)resolvedTemplate:(NSString *)constSubmissionTemplate forSubmission:(CKConversationRelatedSubmission *)submission {
    NSMutableString *submissionTemplate = [constSubmissionTemplate mutableCopy];
    
    NSString *dateString = @"";
    if (submission.submittedAt != nil) {
        dateString = [conversationDateFormatter stringFromDate:submission.submittedAt];
    }
    [submissionTemplate in_replaceOccurrencesOfString:@"{$SUBMISSION_DATE$}" withString:dateString];
    
    [submissionTemplate in_replaceOccurrencesOfString:@"{$TITLE$}" withString:submission.assignment.name];
    
    CKConversationRecipient *author = [currentConversation.participants in_firstObjectPassingTest:
                                       ^BOOL(CKConversationRecipient *obj, NSUInteger idx, BOOL *stop) {
                                           return obj.ident == submission.userIdent;
                                       }];
    
    [submissionTemplate in_replaceOccurrencesOfString:@"{$SUBMITTER$}" withString:author.name];
    
    NSString *gradeString = @"";
    if (submission.grade) {
        if (CKAssignmentScoringTypePassFail == submission.assignment.scoringType) {
            gradeString = [NSString stringWithFormat:NSLocalizedString(@"Grade: %@", nil), submission.grade];
        }
        else if (CKAssignmentScoringTypeLetter == submission.assignment.scoringType) {
            gradeString = [NSString stringWithFormat:NSLocalizedString(@"Grade: %@", nil), submission.grade];
        }
        else if (CKAssignmentScoringTypePercentage == submission.assignment.scoringType) {
            gradeString = [NSString stringWithFormat:NSLocalizedString(@"Grade: %@", nil), submission.grade];
        }
        else {
            gradeString = [NSString stringWithFormat:NSLocalizedString(@"Grade: %i / %g", nil), submission.score, submission.assignment.pointsPossible];
        }
    }

    [submissionTemplate in_replaceOccurrencesOfString:@"{$GRADE$}" withString:gradeString];
    
    NSURL *templateURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ConversationEntry" withExtension:@"html"];
    NSString *template = [NSString stringWithContentsOfURL:templateURL encoding:NSUTF8StringEncoding error:NULL];
    
    NSMutableString *renderedComments = [NSMutableString string];
    for (CKSubmissionComment *comment in submission.recentComments) {
        NSString *commentStr = [self resolvedTemplate:template forSubmissionComment:comment];
        [renderedComments appendString:commentStr];
    }
    
    [submissionTemplate in_replaceOccurrencesOfString:@"{$COMMENTS$}" withString:renderedComments];
    
    return submissionTemplate;
}

- (NSString *)resolvedTemplate:(NSString *)constEntryTemplate forEntry:(CKConversationMessage *)entry {
    NSMutableString *entryTemplate = [constEntryTemplate mutableCopy];
    
    CKConversationRecipient *author = [currentConversation.participants in_firstObjectPassingTest:
                                       ^BOOL(CKConversationRecipient *obj, NSUInteger idx, BOOL *stop) {
                                           return obj.ident == entry.authorIdent;
                                       }];
    
    
    NSString *classes = @"";
    if (author.ident == currentUserID) {
        classes = @"self_author";
    }
    if (entry.isSystemGenerated) {
        classes = @"system_message";
    }
    
    [entryTemplate in_replaceOccurrencesOfString:@"{$CLASSES$}" withString:classes];
    
    [entryTemplate in_replaceOccurrencesOfString:@"{$USER_IDENT$}" withString:[NSString stringWithFormat:@"%lld", author.ident]];
    
    [entryTemplate in_replaceOccurrencesOfString:@"{$AVATAR_URL$}" withString:[author.avatarURL absoluteString]];
    
    [entryTemplate in_replaceOccurrencesOfString:@"{$AUTHOR$}" withString:author.name];
    
    [entryTemplate in_replaceOccurrencesOfString:@"{$CONTENT$}" withString:[self conversationBodyHTMLAfterCollapsingQuotes:entry]];
    
    [entryTemplate in_replaceOccurrencesOfString:@"{$DATE$}" withString:[conversationDateFormatter stringFromDate:entry.creationTime]];
    
    [entryTemplate in_replaceOccurrencesOfString:@"{$MESSAGE_ID$}" withString:[NSString stringWithFormat:@"%qu", entry.ident]];
    
    
    NSURL *attachmentTemplateURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ConversationAttachmentLink" withExtension:@"html"];
    NSString *attachmentTemplate = [NSString stringWithContentsOfURL:attachmentTemplateURL encoding:NSUTF8StringEncoding error:NULL];
    
    NSMutableString *renderedAttachments = [NSMutableString string];
    NSMutableArray *attachmentIshThings = [entry.attachments mutableCopy];
    if (entry.mediaComment) {
        [attachmentIshThings insertObject:entry.mediaComment atIndex:0];
    }
    for (CKConversationAttachment *attachment in attachmentIshThings) {
        NSString *attachmentStr = [self resolvedTemplate:attachmentTemplate forAttachment:attachment onMessage:entry];
        [renderedAttachments appendString:attachmentStr];
    }
    
    [entryTemplate in_replaceOccurrencesOfString:@"{$ATTACHMENTS$}" withString:renderedAttachments];
    
    
    NSArray *forwardedMessages = entry.forwardedMessages;
    NSMutableString *renderedForwards = [NSMutableString string];
    for (CKConversationMessage *forwardedMessage in forwardedMessages) {
        NSString *messageStr = [self resolvedTemplate:constEntryTemplate forEntry:forwardedMessage];
        [renderedForwards appendString:messageStr];
    }
    [entryTemplate in_replaceOccurrencesOfString:@"{$FORWARDS$}" withString:renderedForwards];
    
    
    return entryTemplate;
}


- (NSString *)htmlStringForObject:(CKConversation *)conversation {
    currentConversation = conversation;
    
    NSURL *templateURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"Conversation"
                                                 withExtension:@"html"];
    NSURL *baseURL = [templateURL URLByDeletingLastPathComponent];
    NSURL *entryURL = [baseURL URLByAppendingPathComponent:@"ConversationEntry.html"];
    NSURL *submissionURL = [baseURL URLByAppendingPathComponent:@"ConversationSubmissionEntry.html"];
    
    NSMutableString *baseTemplate = [NSMutableString stringWithContentsOfURL:templateURL encoding:NSUTF8StringEncoding error:NULL];
    NSString *entryTemplate = [NSString stringWithContentsOfURL:entryURL encoding:NSUTF8StringEncoding error:NULL];
    NSString *submissionTemplate = [NSString stringWithContentsOfURL:submissionURL encoding:NSUTF8StringEncoding error:NULL];
    
    NSMutableString *renderedEntries = [NSMutableString new];
    for (CKConversationMessage *item in conversation.messages) {
        @autoreleasepool {
            if (item.relatedSubmission != nil) {
                NSString *entryStr = [self resolvedTemplate:submissionTemplate forSubmission:item.relatedSubmission];
                [renderedEntries appendString:entryStr];
            }
            else {
                NSString *entryStr = [self resolvedTemplate:entryTemplate forEntry:item];
                [renderedEntries appendString:entryStr];
            }

        }
    }
    [baseTemplate in_replaceOccurrencesOfString:@"{$CONVERSATION_ENTRIES$}" withString:renderedEntries];
    return baseTemplate;
}


@end
