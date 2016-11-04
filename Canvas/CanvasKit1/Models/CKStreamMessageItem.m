
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
    
    

#import "CKStreamMessageItem.h"
#import "NSDictionary+CKAdditions.h"
#import "CKAssignment.h"
#import "CKCalendarItem.h"
#import "CKCourse.h"

@interface CKStreamMessageItem()

- (void)updateContextInfoWithURL:(NSURL *)someURL;

@end


@implementation CKStreamMessageItem

@synthesize url, assignmentId, submissionId, calendarEventId;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self) {
        NSString *urlString = [info objectForKeyCheckingNull:@"url"];
        if (urlString) {
            url = [NSURL URLWithString:urlString];
            [self updateContextInfoWithURL:url];
        }
    }
    
    return self;
}


- (void)updateContextInfoWithURL:(NSURL *)someURL
{
    NSArray *pathComponents = [someURL pathComponents];
    for (int i=0; i < [pathComponents count]; i++) {
        NSString *pathComponent = pathComponents[i];
        if ([@"/" isEqualToString:pathComponent]) {
            continue;
        }
        else if ([@"courses" isEqualToString:pathComponent]) {
            if (i+1 < [pathComponents count]) {
                self.courseId = [pathComponents[i+1] unsignedLongLongValue];
            }
        }
        else if ([@"assignments" isEqualToString:pathComponent]) {
            if (i+1 < [pathComponents count]) {
                self.assignmentId = [pathComponents[i+1] unsignedLongLongValue];
            }
        }
        else if ([@"submissions" isEqualToString:pathComponent]) {
            if (i+1 < [pathComponents count]) {
                self.submissionId = [pathComponents[i+1] unsignedLongLongValue];
            }
        }
        else if ([@"calendar_events" isEqualToString:pathComponent]) {
            if (i+1 < [pathComponents count]) {
                self.calendarEventId = [pathComponents[i+1] unsignedLongLongValue];
            }
        }
    }
    
}

- (void)populateActionPath
{
    if (self.actionPath) {
        return;
    }
    
    if (self.assignmentId > 0) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKAssignment class], @(self.assignmentId)];
    }
    
    if (self.calendarEventId > 0) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKCalendarItem class], @(self.calendarEventId)];
    }
}

@end
