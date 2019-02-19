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
    
    

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@interface CKAssignmentOverride : CKModelObject

@property uint64_t ident;
@property uint64_t assignmentIdent;

// Only one of these three should come from the API; the others will be nil
@property NSArray *studentIdents;
@property uint64_t groupIdent;
@property uint64_t sectionIdent;

@property NSString *title;
@property NSDate *dueDate;
@property NSDate *allDayDate; // nil unless the due date should be treated as only a date, w/o a time.

@property NSDate *unlockAtDate;
@property NSDate *lockAtDate;

- (id)initWithInfo:(NSDictionary *)info;

@end
