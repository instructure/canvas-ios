
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
