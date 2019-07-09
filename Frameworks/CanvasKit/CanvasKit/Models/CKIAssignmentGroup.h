//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

#import "CKIModel.h"

@interface CKIAssignmentGroup : CKIModel

/**
 The name of the Assignment Group
 */
@property (nonatomic, strong) NSString *name;

/**
 The position of the Assignment Group
 */
@property (nonatomic) NSInteger position;

/**
 The weight of the Assignment Group
 */
@property (nonatomic) double weight;

/**
 The assignments in this Assignment Group
 @see CKIAssignment
 */
@property (nonatomic, strong) NSArray *assignments;

/**
 The grading rules that this Assignment Group has
 */
@property (nonatomic, strong) NSDictionary *rules;

@end
