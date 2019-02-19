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
