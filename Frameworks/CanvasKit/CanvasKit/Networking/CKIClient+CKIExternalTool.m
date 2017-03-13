//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
