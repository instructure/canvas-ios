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
    
    

#import "CKSafeDictionary.h"
#import "NSDictionary+CKAdditions.h"

@interface CKSafeDictionary ()
@property NSDictionary *dictionary;
@end

@implementation CKSafeDictionary

- (id)objectForKeyedSubscript:(id)key
{
    return [self.dictionary objectForKeyCheckingNull:key];
}

- (id)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [super init];
    if (self) {
        self.dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    }
    return self;
}

- (NSUInteger)count
{
    return self.dictionary.count;
}

- (id)objectForKey:(id)key
{
    return [self.dictionary objectForKey:key];
}

- (NSEnumerator *)keyEnumerator
{
    return [self.dictionary keyEnumerator];
}



@end
