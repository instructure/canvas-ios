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

#import "CKILockableModel.h"

@class CKIUser;

@interface CKIPage : CKILockableModel

/**
 The title of the page.
 */
@property (nonatomic, copy) NSString *title;

/**
 The date the page was created.
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 The date the page was last updated.
 */
@property (nonatomic, strong) NSDate *updatedAt;

/**
 This page is hidden from students.
 
 @note Students will never see this true; pages hidden
 from them will be omitted from results
 */
@property (nonatomic) BOOL hideFromStudents;

/**
 The user that last edited this page.
 */
@property (nonatomic, readonly) CKIUser *lastEditedBy;

@property (nonatomic) BOOL published;

@property (nonatomic) BOOL frontPage;

@end
