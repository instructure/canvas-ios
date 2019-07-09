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

#import "CKIClient.h"

@class RACSignal;
@class CKICourse;

@interface CKIClient (CKIActivityStreamItem)


/**
 Fetches the activity stream for the current user.
 
 @return A signal that will deliver pages of stream items.
 */
- (RACSignal *)fetchActivityStream;

/**
 Fetches the activity stream for the given context.
 
 @param context the context for the stream i.e. a course
 @return a signal of pages (NSArray *) of stream items.
 */
- (RACSignal *)fetchActivityStreamForContext:(id<CKIContext>)context;

@end
