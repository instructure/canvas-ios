//
//  CKCommentAttachment.m
//  CanvasKit
//
//  Created by Zach Wily on 6/4/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "CKCommentAttachment.h"
#import "CKCanvasAPI.h"
#import "NSString+CKAdditions.h"
#import "CKSubmission.h"
#import "CKAssignment.h"
#import "CKSubmissionComment.h"
#import "CKCourse.h"

@implementation CKCommentAttachment

@synthesize comment;

- (NSString *)internalIdent
{
    NSString *internalIdent;
    if (self.ident > 0) {
        internalIdent = [NSString stringWithFormat:@"%qu", self.ident];
    }
    else {
        internalIdent = [NSString stringWithFormat:@"%qu-%qu-%qu-%f-%qu-%@",
                          self.comment.submission.assignment.course.ident,
                          self.comment.submission.assignment.ident,
                          self.comment.submission.ident,
                          [self.comment.createdAt timeIntervalSinceReferenceDate],
                          self.comment.authorIdent,
                          [[self.directDownloadURL absoluteString] md5Hash]];
    }
    return internalIdent;
}

- (NSURL *)cacheURL
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = cachePaths[0];
    NSString *path = [NSString stringWithFormat:@"%@/attachments/%i/course-%qu/assignment-%qu/%@",
                      cachePath,
                      [self cacheVersion],
                      self.comment.submission.assignment.course.ident, 
                      self.comment.submission.assignment.ident,
                      self.internalIdent];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, self.filename];
    return [NSURL fileURLWithPath:fullPath];
}


@end
