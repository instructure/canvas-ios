//
//  CKConversationMessage.m
//  CanvasKit
//
//  Created by BJ Homer on 10/4/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKConversationMessage.h"
#import "ISO8601DateFormatter.h"
#import "NSDictionary+CKAdditions.h"
#import "CKConversationAttachment.h"
#import "CKConversationRelatedSubmission.h"

@implementation CKConversationMessage
@synthesize ident;
@synthesize creationTime;
@synthesize text;
@synthesize authorIdent;
@synthesize isSystemGenerated;
@synthesize mediaComment;
@synthesize forwardedMessages;
@synthesize attachments;
@synthesize relatedSubmission;

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        ident = [info[@"id"] unsignedLongLongValue];
        
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        NSString *dateStr = [info objectForKeyCheckingNull:@"created_at"];
        creationTime = [[formatter dateFromString:dateStr] copy];
        
        text = [[info objectForKeyCheckingNull:@"body"] copy];
        
        authorIdent = [info[@"author_id"] unsignedLongLongValue];
        
        isSystemGenerated = [info[@"generated"] boolValue];
        
        NSDictionary *commentDict = [info objectForKeyCheckingNull:@"media_comment"];
        if (commentDict != nil && [commentDict isKindOfClass:[NSDictionary class]]) {
            // We're seeing a couple crashes where the 'media_comment' value is a string. Weird...
            // If we hit that, just drop the media comment altogether.
            mediaComment = [[CKConversationAttachment alloc] initWithInfo:commentDict];
        }
        
        
        NSArray *forwardedDicts = info[@"forwarded_messages"];
        NSMutableArray *mutableForwards = [NSMutableArray array];
        for (NSDictionary *dict in forwardedDicts) {
            CKConversationMessage *message = [[CKConversationMessage alloc] initWithInfo:dict];
            [mutableForwards addObject:message];
        }
        forwardedMessages = [mutableForwards copy];
        
        NSArray *attachmentDicts = info[@"attachments"];
        NSMutableArray *mutableAttachments = [NSMutableArray array];
        for (NSDictionary *dict in attachmentDicts) {
            CKConversationAttachment *attachment = [[CKConversationAttachment alloc] initWithInfo:dict];
            [mutableAttachments addObject:attachment];
        }
        attachments = [mutableAttachments copy];
        
        NSDictionary *relatedSubmissionDict = [info objectForKeyCheckingNull:@"submission"];
        if (relatedSubmissionDict != nil) {
            relatedSubmission = [[CKConversationRelatedSubmission alloc] initWithInfo:relatedSubmissionDict];
        }
    }
    return self;
}

+ (NSArray *)propertiesToExcludeFromEqualityComparison {
    return @[@"relatedSubmission"];
}


- (BOOL)isEqual:(CKConversationMessage *)other {
    BOOL superIsEqual = [super isEqual:other];
    if (!superIsEqual) {
        return NO;
    }
    
    return (self.relatedSubmission.assignmentIdent == other.relatedSubmission.assignmentIdent &&
            self.relatedSubmission.userIdent == other.relatedSubmission.userIdent);
    
}

- (NSUInteger)hash {
    return ident;
}

@end
