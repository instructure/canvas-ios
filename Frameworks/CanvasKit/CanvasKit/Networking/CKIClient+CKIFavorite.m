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

#import "CKIClient+CKIFavorite.h"
#import "CKICourse.h"
#import "CKIFavorite.h"

@implementation CKIClient (CKIFavorite)

- (RACSignal *)fetchFavoriteCourses
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"users/self/favorites/courses"];
    NSDictionary *params = @{@"include": @[@"needs_grading_count", @"syllabus_body", @"total_scores", @"term"]};
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKICourse class] context:nil];
}

- (NSString *)currentUserFavoritesPathStringForCourse:(CKICourse *)course
{
    return [[CKIRootContext.path stringByAppendingPathComponent:@"users/self/favorites/courses/"] stringByAppendingPathComponent:course.id];
}

- (RACSignal *)addCourseToFavorites:(CKICourse *)course
{
    NSString *path = [self currentUserFavoritesPathStringForCourse:course];
    
    return [self createModelAtPath:path parameters:nil modelClass:[CKIFavorite class] context:nil];
}

- (RACSignal *)removeCourseFromFavorites:(CKICourse *)course
{
    NSString *path = [self currentUserFavoritesPathStringForCourse:course];
    
    return [self deleteObjectAtPath:path modelClass:[CKIFavorite class] parameters:nil context:nil];
}

@end
