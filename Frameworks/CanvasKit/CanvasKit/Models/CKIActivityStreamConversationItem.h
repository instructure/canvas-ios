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

@interface CKIActivityStreamConversationItem : CKIActivityStreamItem

/**
 This conversation item is private.
 */
@property (nonatomic) BOOL isPrivate;

/**
 The number of participants in the conversation.
 */
@property (nonatomic) NSUInteger participantCount;

/**
 The unique identifier for the conversation to which
 this stream item refers.
 */
@property (nonatomic, copy) NSString *conversationID;

@end
