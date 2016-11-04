
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

typedef enum {
    CNVScheduleItemTypeUnknown,
    CNVScheduleItemTypeAssignment,
    CNVScheduleItemTypeCalendar
} CNVScheduleItemType;

@interface ScheduleItem : NSObject

@property (nonatomic) CNVScheduleItemType type;
@property (nonatomic, strong) id itemObject;

@property (readonly) uint64_t ident;
@property (weak,readonly) NSDate *eventDate;
@property (weak,readonly) NSString *title;
@property (weak,readonly) NSString *itemDescription;
@property (weak,readonly) NSString *typeDescription;

- (id)initWithObject:(id)anObject;

- (BOOL)isEqual:(id)object;

@end
