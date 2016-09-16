//
//  CKFakeAttachment.m
//  CanvasKit
//
//  Created by BJ Homer on 9/28/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKFakeAttachment.h"
#import "CKSubmissionAttempt.h"
#import "CKSubmission.h"
#import "CKAssignment.h"
#import "CKCourse.h"

@interface CKFakeAttachment ()
@property int attachmentsIndex;
@end

@implementation CKFakeAttachment

- (id)initWithDisplayName:(NSString *)aFilename atIndex:(int)index andSubmissionAttempt:(CKSubmissionAttempt *)anAttempt
{
    self = [super initWithInfo:nil];
    if (self) {
        self.filename = [aFilename stringByAppendingPathExtension:@"html"];
        self.displayName = aFilename;
        self.attempt = anAttempt;
        self.attachmentsIndex = index;
        self.ident = 0;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CKFakeAttachment *other = [super copyWithZone:zone];
    other.attempt = self.attempt;
    other.attachmentsIndex = self.attachmentsIndex;
    return other;
    
}

- (NSURL *)directDownloadURL {
    return [self cacheURL];
}

- (NSString *)internalIdent {
    if (self.attempt) {
        NSString *internalIdent = [NSString stringWithFormat:@"asmt_%qu-user_%qu-atmp_%i-att_%i",
                                   self.attempt.assignmentIdent,
                                   self.attempt.submitterIdent,
                                   self.attempt.attempt,
                                   self.attachmentsIndex];
        return internalIdent;
    }
    else {
        return [super internalIdent];
    }
}

@end
