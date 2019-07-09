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

#import "CKIActivityStreamItem.h"

/**
 Generic notification message for letting students know things
 like an assignment was graded.
 */
@interface CKIActivityStreamMessageItem : CKIActivityStreamItem

/**
 The category of notification. Can be any of the following:
 - "Assignment Created"
 - "Assignment Changed"
 - "Assignment Due Date Changed"
 - "Assignment Graded"
 - "Assignment Submitted Late"
 - "Grade Weight Changed"
 - "Group Assignment Submitted Late"
 - "Due Date"
 */
@property (nonatomic, copy) NSString *notificationCategory;

/**
 The ID of the message.
 */
@property (nonatomic, copy) NSString *messageID;

@end
