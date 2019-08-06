//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
