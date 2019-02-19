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

@class CKCourse, CKAssignment;

@interface CKAssignmentGroup : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int position;
@property (nonatomic, strong) NSMutableArray *assignments;
@property (nonatomic, weak) CKCourse *course;

- (id)initWithInfo:(NSDictionary *)info andCourse:(CKCourse *)course;

- (void)updateWithInfo:(NSDictionary *)info;

- (BOOL)addToGroup:(CKAssignment *)assignment;

- (NSComparisonResult)comparePosition:(CKAssignmentGroup *)other;

@end
