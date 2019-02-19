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
    
    

#import "CKAssignmentOverride.h"
#import "NSDictionary+CKAdditions.h"
#import "ISO8601DateFormatter.h"
#import "CKCommonTypes.h"


/*
 {
 // the ID of the assignment override
 id: 4,
 
 // the ID of the assignment the override applies to
 assignment_id: 123,
 
 // the IDs of the override's target students (present iff the override
 // targets and adhoc set of students)
 student_ids: [1, 2, 3],
 
 // the ID of the override's target group (present iff the override
 // targets a group)
 group_id: 2,
 
 // the ID of the overrides’s target section (present iff the override
 // targets a section)
 course_section_id: 1
 
 // the title of the override
 title: "an assignment override",
 
 // the overridden due at (present iff due_at is overridden)
 due_at: "2012-07-01T23:59:00-06:00",
 
 // the overridden all day flag (present iff due_at is overridden)
 all_day: true,
 
 // the overridden all day date (present iff due_at is overridden)
 all_day_date: "2012-07-01",
 
 // the overridden unlock at (present iff unlock_at is overridden)
 unlock_at: "2012-07-01T23:59:00-06:00",
 
 // the overridden lock at, if any (present iff lock_at is overridden)
 lock_at: "2012-07-01T23:59:00-06:00"
 }
 */


@implementation CKAssignmentOverride

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _ident = [[info objectForKeyCheckingNull:@"id"] unsignedLongLongValue];
        _assignmentIdent = [[info objectForKeyCheckingNull:@"assignment_id"] unsignedLongLongValue];
        _studentIdents = [info objectForKeyCheckingNull:@"student_ids"];
        _groupIdent = [[info objectForKeyCheckingNull:@"group_id"] unsignedLongLongValue];
        _sectionIdent = [[info objectForKeyCheckingNull:@"course_section_id"] unsignedLongLongValue];
        _title = [info objectForKeyCheckingNull:@"title"];
        
        ISO8601DateFormatter *dateFormatter = [ISO8601DateFormatter new];
        
        NSString *dueAtString = [info objectForKeyCheckingNull:@"due_at"];
        if (dueAtString) {
            _dueDate = [dateFormatter dateFromString:dueAtString];
            if ([[info objectForKeyCheckingNull:@"all_day"] boolValue]) {
                NSDateFormatter *dateOnlyDateFormatter = [NSDateFormatter new];
                dateOnlyDateFormatter.dateFormat = @"yyyy-MM-dd";
                dateOnlyDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                _allDayDate = [dateOnlyDateFormatter dateFromString:[info objectForKeyCheckingNull:@"all_day_date"]];
            }
        }
        
        NSString *unlockStr = [info objectForKeyCheckingNull:@"unlock_at"];
        if (unlockStr) {
            _unlockAtDate = [dateFormatter dateFromString:unlockStr];
        }
        
        NSString *lockStr = [info objectForKeyCheckingNull:@"lock_at"];
        if (lockStr) {
            _lockAtDate = [dateFormatter dateFromString:lockStr];
        }
    }
    return self;
}


- (NSUInteger)hash {
    return (NSUInteger)_ident;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p  (%@)>", [self class], self, self.title];
}

@end
