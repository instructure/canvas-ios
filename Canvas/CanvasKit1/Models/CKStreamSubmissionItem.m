
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
    
    

#import "CKStreamSubmissionItem.h"
#import "NSDictionary+CKAdditions.h"
#import "CKAssignment.h"
#import "CKCourse.h"

@implementation CKStreamSubmissionItem

@synthesize grade, score, assignmentDict, submissionComments;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self) {
        grade = [info objectForKeyCheckingNull:@"grade"];
        score = [[info objectForKeyCheckingNull:@"score"] intValue];
        assignmentDict = [info objectForKeyCheckingNull:@"assignment"];
        submissionComments = [info objectForKeyCheckingNull:@"submission_comments"];
    }
    
    return self;
}


- (NSDictionary *)latestComment
{
    // TODO: unit test this to make sure it returns the correct one
    NSDictionary *comment = nil;
    
    if ([self.submissionComments count] > 0) {
        comment = [self.submissionComments lastObject];
    }
    
    return comment;
}

- (void)populateActionPath
{
    if (self.actionPath) {
        return;
    }
    
    if (self.assignmentDict) {
        int assignmentId = [(self.assignmentDict)[@"id"] unsignedLongLongValue];
        
        if (assignmentId > 0) {
            self.actionPath = @[[CKCourse class], @(self.courseId), [CKAssignment class], @(assignmentId)];
        }
    }
}

@end
