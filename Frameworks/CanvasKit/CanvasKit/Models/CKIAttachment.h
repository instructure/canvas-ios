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

@interface CKIAttachment : CKIModel
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic) NSUInteger size;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, copy) NSDate *unlockAt;
@property (nonatomic) BOOL locked;
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL hiddenForUser;
@property (nonatomic) BOOL lockedForUser;
@property (nonatomic, copy) NSURL *thumbnailURL;
@end
