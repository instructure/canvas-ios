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

#import "CKIClient+CKISection.h"
#import "CKISection.h"

@implementation CKIClient (CKISection)

- (RACSignal *)fetchSectionsForCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"sections"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKISection class] context:course];
}

- (RACSignal *)fetchSectionWithID:(NSString *)sectionID
{
    NSString *path = [[CKIRootContext.path stringByAppendingPathComponent:@"sections"] stringByAppendingPathComponent:sectionID];
    return [self fetchResponseAtPath:path parameters:0 modelClass:[CKISection class] context:nil];
}

@end
