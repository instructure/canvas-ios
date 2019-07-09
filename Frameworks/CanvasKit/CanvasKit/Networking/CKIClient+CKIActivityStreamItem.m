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

@import ReactiveObjC;

#import "CKIClient+CKIActivityStreamItem.h"
#import "CKIActivityStreamItem.h"
#import "CKICourse.h"

@implementation CKIClient (CKIActivityStreamItem)

- (RACSignal *)fetchActivityStreamForContext:(id<CKIContext>)context
{
    NSString *path = context.path;
    
    if ([path isEqualToString:@"/api/v1"] || path == (id)[NSNull null] || path.length == 0){
        path = @"/api/v1/users/self/activity_stream";
    }
    
    NSValueTransformer *transformer = [CKIActivityStreamItem activityStreamItemTransformer];
    return [self fetchResponseAtPath:path parameters:nil transformer:transformer context:nil];
}

- (RACSignal *)fetchActivityStream
{
    return [self fetchActivityStreamForContext:CKIRootContext];
}

@end
