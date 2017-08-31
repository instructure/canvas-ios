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

@class CKAssignment, CKCourse;

@interface CKCalendarItem : CKModelObject

@property (nonatomic, assign) BOOL allDay;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *itemDescription;
@property (nonatomic, assign) uint64_t typeId;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) CKAssignment *assignment;
@property (nonatomic, strong) NSString *contextCode;
@property (nonatomic, assign) uint64_t courseId;
@property (nonatomic, strong) CKCourse *course;
@property (nonatomic, strong) NSArray *actionPath;

- (id)initWithInfo:(NSDictionary *)info;
- (void)updateWithInfo:(NSDictionary *)info;

- (void)populateActionPath;

@end
