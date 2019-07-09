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

@class CKILockInfo;

/**
 A base class adding functionality for models that require locking.
 */
@interface CKILockableModel : CKIModel

/**
 Model is in a locked state for this user.
 */
@property (nonatomic) BOOL lockedForUser;

/**
 An explanation of why this is locked for the user.
 Present when lockedForUser is true.
 */
@property (nonatomic, copy) NSString *lockExplanation;

/**
 Information for the user about the lock. Present when 
 lockedForUser is true.
 */
@property (nonatomic, strong) CKILockInfo *lockInfo;
@end
