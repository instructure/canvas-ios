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

#import "NSArray+CKIAdditions.h"

@implementation NSArray (CKIAdditions)

- (NSArray *)arrayByMappingValues:(NSDictionary *)valueMapping
{
    NSMutableArray *array = [self mutableCopy];
    for (NSUInteger i = 0; i < array.count; ++i) {
        id item = array[i];
        id newValue = [valueMapping objectForKey:item];
        if (newValue != nil) {
            array[i] = newValue;
        }
    }
    return [array copy];
}

@end
