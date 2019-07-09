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
