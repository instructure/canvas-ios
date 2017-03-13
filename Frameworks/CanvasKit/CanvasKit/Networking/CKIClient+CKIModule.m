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

#import "CKIClient+CKIModule.h"
#import "CKICourse.h"
#import "CKIModule.h"

@implementation CKIClient (CKIModule)

- (RACSignal *)fetchModulesForCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"modules"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIModule class] context:course];
}

- (RACSignal *)fetchModuleWithID:(NSString *)moduleID forCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"modules"];
    path = [path stringByAppendingPathComponent:moduleID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIModule class] context:course];
}

@end
