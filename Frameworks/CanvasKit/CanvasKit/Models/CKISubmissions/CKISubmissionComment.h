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

@class CKIUser, CKIMediaComment;

@interface CKISubmissionComment : CKIModel

/**
 The comment text.
 */
@property (nonatomic, copy) NSString *comment;

/**
 The date the comment was made;
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 The Canvas user ID of the author of the comment.
 */
@property (nonatomic, copy) NSString *authorID;

/**
 The name of the comment's author.
 */
@property (nonatomic, copy) NSString *authorName;

/**
 The path for the submitters avatar.
 */
@property (nonatomic, copy) NSString *avatarPath;

/**
 media comment for this submission comment
 */
@property (nonatomic) CKIMediaComment *mediaComment;

@end
