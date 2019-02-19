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

@interface CKContentLock : NSObject
@property (readonly) NSString *explanation; // html string explanation of the reason for the lock if lockedForUser
@property (readonly) NSArray *prerequisites; // empty if only locked until date
@property (readonly) NSDate *startDate;
@property (readonly) NSDate *unlockDate; // nil if only locked due to prerequisites
@property (readonly) NSDate *lockDate;
@property (readonly) NSString *moduleName;

// The info being passed into this object is the whole
// dictionary of the JSON response for the assignment, etc.
// If the object is not locked, returns nil.
+ (id)contentLockWithInfo:(NSDictionary *)info;
- (id)initWithInfo:(NSDictionary *)info;

- (NSArray *)prerequisiteNames;

@end
