//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
