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

#import "CKIClient+CKIGroupCategory.h"

#import "CKIGroupCategory.h"
#import "CKIUser.h"
#import "CKICourse.h"

@implementation CKIClient (CKIGroupCategory)

- (RACSignal *)fetchGroupCategoriesForCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"group_categories"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIGroupCategory class] context:nil];
}

- (RACSignal *)fetchUsersInGroupCategory:(CKIGroupCategory *)category
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"group_categories"];
    path = [path stringByAppendingPathComponent:category.id];
    path = [path stringByAppendingPathComponent:@"users"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIUser class] context:nil];
}

@end
