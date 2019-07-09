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

#import "CKIGroupCategory.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation CKIGroupCategory

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"selfSignup": @"self_signup",
                               @"autoLeader": @"auto_leader",
                               @"contextType": @"context_type",
                               @"accountID": @"account_id",
                               @"groupLimit": @"group_limit",
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

- (NSString *)path
{
    NSString *path = self.context.path;
    path = [path stringByAppendingPathComponent:@"group_categories"];
    return [path stringByAppendingPathComponent:self.id];
}

@end
