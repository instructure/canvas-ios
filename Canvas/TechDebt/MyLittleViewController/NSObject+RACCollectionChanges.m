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
    
    

#import "NSObject+RACCollectionChanges.h"
@import ReactiveObjC;

@implementation NSObject (RACCollectionChanges)
- (RACSignal *)rac_filteredIndexSetsForChangeType:(NSKeyValueChange)type forCollectionForKeyPath:(NSString *)collectionKeyPath {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    return [[[[self rac_valuesAndChangesForKeyPath:collectionKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld observer:nil] map:^id(RACTuple *value) {
        NSAssert([value.second isKindOfClass:[NSDictionary class]], @"Expecting a dictionary of changes");
        return value.second;
    }] filter:^BOOL(NSDictionary *value) {
        return [value[NSKeyValueChangeKindKey] unsignedIntegerValue] == type;
    }] map:^id(id value) {
        return value[NSKeyValueChangeIndexesKey];
    }];
#pragma clang diagnostic pop
}
@end
