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
