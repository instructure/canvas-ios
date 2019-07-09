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

#import "CKIClient+CKIExternalTool.h"
#import "CKIExternalTool.h"
#import "CKICourse.h"

@implementation CKIClient (CKIExternalTool)

- (RACSignal *)fetchExternalToolsForCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"external_tools"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIExternalTool class] context:course];
}

- (RACSignal *)fetchSessionlessLaunchURLWithURL:(NSString *)url course:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"external_tools/sessionless_launch"];
    
    NSDictionary *params = @{@"url":url};
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKIExternalTool class] context:course];
}

- (RACSignal *)fetchExternalToolForCourseWithExternalToolID:(NSString *)externalToolID course:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"external_tools"];
    path = [path stringByAppendingPathComponent:externalToolID];
    
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIExternalTool class] context:course];
}


@end
