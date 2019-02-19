//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "NSDictionary+CKAdditions.h"
#import "CKSafeDictionary.h"


@implementation NSDictionary (CKAdditions)

+ (id)safeDictionaryWithDictionary:(NSDictionary *)dictionary
{
    return [CKSafeDictionary dictionaryWithDictionary:dictionary];
}

- (id)safeCopy
{
    return [CKSafeDictionary dictionaryWithDictionary:self];
}

- (id)objectForKeyCheckingNull:(id)aKey
{
    id obj = self[aKey];
    if (obj == [NSNull null]) {
        return nil;
    }
    return obj;
}

@end
