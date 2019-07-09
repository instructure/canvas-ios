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

#import <Foundation/Foundation.h>

@protocol CKIContext <NSObject>

/**
 The parent object of this object, if any.
 
 e.g. The parent object of a Submission is the Assignment object
 that was used to fetch it.
 */
@property (nonatomic) id<CKIContext> context;

/**
 The api path of the object.
 
 e.g. An assignment's path might be /api/v1/courses/823991/assignments/322
 */
@property (nonatomic, readonly) NSString *path;

@end

#import "CKIAPIV1.h"
#define CKIRootContext [CKIAPIV1 context]
