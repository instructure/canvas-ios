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

@class CKAssignment;

@interface CKRubric : CKModelObject

@property (nonatomic, weak) CKAssignment *assignment;
@property (strong, nonatomic, readonly) NSMutableArray *criteria;
@property (nonatomic, assign) BOOL freeFormComments;
@property (nonatomic, assign) BOOL hidePoints;

// You actually pass it the Assignment dictionary, and it will extract what it needs
- (id)initWithInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment;

- (void)updateWithInfo:(NSDictionary *)info;

@end
