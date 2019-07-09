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

#import "CKIClient+CKIPage.h"
#import "CKIPage.h"
#import "CKICourse.h"

@implementation CKIClient (CKIPage)

- (RACSignal *)fetchPagesForContext:(id<CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"pages"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPage class] context:context];
}

- (RACSignal *)fetchPage:(NSString *)pageID forContext:(id<CKIContext>)context
{
    NSString * path = [context.path stringByAppendingPathComponent:@"pages"];
    path = [path stringByAppendingPathComponent:pageID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPage class] context:context];
}

- (RACSignal *)fetchFrontPageForContext:(id<CKIContext>)context
{
    NSString * path = [context.path stringByAppendingPathComponent:@"front_page"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPage class] context:context];
}

@end
