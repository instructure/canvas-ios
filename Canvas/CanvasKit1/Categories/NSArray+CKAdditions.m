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
    
    

#import "NSArray+CKAdditions.h"
#import "CKCommonTypes.h"
#import "CKModelObject.h"

@implementation NSArray (CKAdditions)

- (id)in_firstObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test {
    NSUInteger index = [self indexOfObjectPassingTest:test];
    
    if (index != NSNotFound) {
        return self[index];
    }
    else {
        return nil;
    }
}

- (NSUInteger)indexOfObjectWithSameIdentityAsObject:(CKModelObject *)object {
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(CKModelObject *obj, NSUInteger idx, BOOL *stop) {
        return [object hasSameIdentityAs:obj];
    }];
    return index;
}


@end
