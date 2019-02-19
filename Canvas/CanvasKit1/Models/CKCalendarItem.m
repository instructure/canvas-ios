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
    
    

#import "CKCalendarItem.h"
#import "CKAssignment.h"
#import "CKCourse.h"
#import "ISO8601DateFormatter.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKCalendarItem


- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        [self updateWithInfo:info];
    }
    
    return self;
}

- (void)updateWithInfo:(NSDictionary *)json
{
    NSNumber *typeIdNumber = [json objectForKeyCheckingNull:@"id"];
    _typeId = [typeIdNumber unsignedLongLongValue];
    
    _title = [json objectForKeyCheckingNull:@"title"];
    _itemDescription = [json objectForKeyCheckingNull:@"description"];
    
    _allDay = [[json objectForKeyCheckingNull:@"all_day"] boolValue];
    ISO8601DateFormatter *formatter = [ISO8601DateFormatter new];
    _startDate = [formatter dateFromString:[json objectForKeyCheckingNull:@"start_at"]];
    _endDate = [formatter dateFromString:[json objectForKeyCheckingNull:@"end_at"]];
    _updatedAt = [formatter dateFromString:[json objectForKeyCheckingNull:@"updated_at"]];
    
    _url = [NSURL URLWithString:[json objectForKeyCheckingNull:@"url"]];
    
    NSDictionary * assignmentDictionary = [json objectForKeyCheckingNull:@"assignment"];
    if (assignmentDictionary) {
        _assignment = [[CKAssignment alloc] initWithInfo:[json objectForKeyCheckingNull:@"assignment"]];
    }

    _contextCode = [json objectForKeyCheckingNull:@"context_code"];
    
    [self setCourseIdFromContextCode:_contextCode];
}

- (void)setCourseIdFromContextCode:(NSString *)contextCode {
    if ([_contextCode rangeOfString:@"course"].location != NSNotFound) {
        
        NSArray *listItems = [_contextCode componentsSeparatedByString:@"_"];
        NSString * courseId = listItems[1];
        
        _courseId = [courseId intValue];
    }
}


- (void)populateActionPath
{
    if (self.actionPath || !self.course) {
        return;
    }
    
    if (self.assignment.ident > 0) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKAssignment class], @(self.assignment.ident)];
    }
}

- (NSUInteger)hash
{
    return (NSUInteger)self.typeId;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<(CKCalendarItem %p) typeID: %llu, summary: %@, startDate: %@>", self, self.typeId, self.title, self.startDate];
}

@end
