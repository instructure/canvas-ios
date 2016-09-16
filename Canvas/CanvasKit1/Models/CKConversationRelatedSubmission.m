//
//  CKConversationRelatedSubmission.m
//  CanvasKit
//
//  Created by BJ Homer on 10/24/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKConversationRelatedSubmission.h"
#import "ISO8601DateFormatter.h"
#import "CKSubmissionComment.h"
#import "NSDictionary+CKAdditions.h"
#import "CKAssignment.h"
#import "CKSubmissionAttempt.h"

@implementation CKConversationRelatedSubmission
@synthesize assignmentIdent;
@synthesize userIdent;
@synthesize assignment;
@synthesize submittedAt;
@synthesize grade;
@synthesize score;
@synthesize recentComments;

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        assignmentIdent = [info[@"assignment_id"] unsignedLongLongValue];
        assignment = [[CKAssignment alloc] initWithInfo:[info objectForKeyCheckingNull:@"assignment"]];
        
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        submittedAt = [[formatter dateFromString:[info objectForKeyCheckingNull:@"submitted_at"]] copy];
        
        grade = [[info objectForKeyCheckingNull:@"grade"] copy];
        score = [[info objectForKeyCheckingNull:@"score"] intValue];
        
        userIdent = [info[@"user_id"] unsignedLongLongValue];
        
        NSMutableArray *comments = [[NSMutableArray alloc] init];
        NSArray *commentDicts = [info objectForKeyCheckingNull:@"submission_comments"];
        for (NSDictionary *dict in commentDicts) {
            CKSubmissionComment *comment = [[CKSubmissionComment alloc] initWithConversationSummaryInfo:dict];
            [comments addObject:comment];
        }
        recentComments = comments;
    }
    return self;
}

- (NSUInteger)hash {
    return assignmentIdent ^ userIdent;
}

@end
