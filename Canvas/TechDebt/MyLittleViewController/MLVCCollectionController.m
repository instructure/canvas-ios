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
    
    

#import "MLVCCollectionController.h"
#import <UIKit/UIKit.h>
@import ReactiveObjC;
#import "NSObject+RACCollectionChanges.h"
#import "EXTScope.h"

@interface MLVCCollectionControllerGroup ()
- (id)initWithID:(id)groupID title:(NSString *)title;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSMutableArray *groupedObjects;
@end

@interface MLVCCollectionController ()
@property (nonatomic, copy, readwrite) id (^groupByBlock)(id object);
@property (nonatomic, copy, readwrite) NSString *(^groupTitleBlock)(id object);
@property (nonatomic, copy, readwrite) NSArray *sortDescriptors;
@end

@implementation MLVCCollectionController {
    NSMutableArray *_groups;
    NSMutableDictionary *_groupsByGroupID;
    RACSignal *_groupsInsertedIndexSetSignal, *_groupsDeletedIndexSetSignal;
    RACSubject *_beginUpdatesSignal, *_endUpdatesSignal;
}

- (id)init
{
    self = [super init];
    if (self) {
        _groups = [NSMutableArray array];
        _groupsByGroupID = [NSMutableDictionary dictionary];
        _beginUpdatesSignal = [RACSubject subject];
        _endUpdatesSignal = [RACSubject subject];
    }
    return self;
}

+ (instancetype)collectionControllerGroupingByBlock:(id (^)(id object))groupByBlock groupTitleBlock:(NSString *(^)(id object))groupTitleBlock sortDescriptors:(NSArray *)sortDescriptors
{
    MLVCCollectionController *me = [[self alloc] init];
    
    me.groupByBlock = groupByBlock ?: ^(id object) {
        return (id)@(0);
    };
    me.groupTitleBlock = groupTitleBlock ?: ^(id object) {
        return (NSString *)nil;
    };
    
    NSParameterAssert([sortDescriptors count] > 0);
    me.sortDescriptors = [sortDescriptors copy];
    
    return me;
}

#pragma mark - Reacting

- (RACSignal *)groupsInsertedIndexSetSignal
{
    if (_groupsInsertedIndexSetSignal) {
        return _groupsInsertedIndexSetSignal;
    }

    return _groupsInsertedIndexSetSignal = [self rac_filteredIndexSetsForChangeType:NSKeyValueChangeInsertion forCollectionForKeyPath:@"groups"];
}

- (RACSignal *)groupsDeletedIndexSetSignal
{
    if (_groupsDeletedIndexSetSignal) {
        return _groupsDeletedIndexSetSignal;
    }
    
    return _groupsDeletedIndexSetSignal = [self rac_filteredIndexSetsForChangeType:NSKeyValueChangeRemoval forCollectionForKeyPath:@"groups"];
}

- (RACSignal *)signalForIndexPathsOfObjectChangesOfType:(NSKeyValueChange)changeType {
    RACSignal *newGroups = [[self groupsInsertedIndexSetSignal] map:^id(NSIndexSet *insertedGroups) {
        NSArray *groups = [self.groups objectsAtIndexes:insertedGroups];
        return groups;
    }];
    
    return [[[RACSignal return:self.groups] concat:newGroups] flattenMap:^__kindof RACStream *(NSArray *groups) {
        NSArray *insertionSignalsForGroups = [[groups.rac_sequence map:^id(MLVCCollectionControllerGroup *group) {
            @weakify(group);
            return [[group rac_filteredIndexSetsForChangeType:changeType forCollectionForKeyPath:@"groupedObjects"] map:^id(NSIndexSet *indexes) {
                @strongify(group);
                NSUInteger groupIndex = group.index;
                return [[indexes.rac_sequence map:^id(NSNumber *index) {
                    return [NSIndexPath indexPathForRow:[index integerValue] inSection:groupIndex];
                }] array];
            }];
        }] array];
        
        return [RACSignal merge:insertionSignalsForGroups];
    }];
}

- (RACSignal *)objectsInsertedIndexPathsSignal {
    return [self signalForIndexPathsOfObjectChangesOfType:NSKeyValueChangeInsertion];
}

- (RACSignal *)objectsDeletedIndexPathsSignal {
    return [self signalForIndexPathsOfObjectChangesOfType:NSKeyValueChangeRemoval];
}

#pragma mark - Querying

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return self[indexPath.section][indexPath.row];
}

- (id)objectAtIndexedSubscript:(NSUInteger)groupIndex
{
    return self.groups[groupIndex];
}

#pragma mark - inserting and removing

- (MLVCCollectionControllerGroup *)insertGroupForObject:(id)object
{
    return (MLVCCollectionControllerGroup *)[self insertGroupWithGroupID:self.groupByBlock(object) title:self.groupTitleBlock(object)];
}

- (MLVCCollectionControllerGroup *)insertGroupWithGroupID:(id)groupID title:(NSString *)title
{
    MLVCCollectionControllerGroup *group = [[MLVCCollectionControllerGroup alloc] initWithID:groupID title:title];
    _groupsByGroupID[group.id] = group;
    
    NSMutableArray *mutable = [self mutableArrayValueForKey:@"groups"];
    
    NSUInteger index = [mutable indexOfObject:group inSortedRange:NSMakeRange(0, [_groups count]) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 id] compare:[obj2 id]];
    }];
    group.index = index;
    [mutable insertObject:group atIndex:index];
    for (NSInteger higherIndex = index + 1; higherIndex < [mutable count]; ++higherIndex) {
        MLVCCollectionControllerGroup *laterGroup = mutable[higherIndex];
        laterGroup.index = higherIndex;
    }
    return group;
}

- (void)insertObject:(id)object
{
    MLVCCollectionControllerGroup *group = _groupsByGroupID[_groupByBlock(object)];
    if (group == nil) {
        group = [self insertGroupForObject:object];
    }
    NSMutableArray *mutable = [group mutableArrayValueForKey:@"groupedObjects"];
    NSRange range = NSMakeRange(0, group.objects.count);
    NSInteger insertionIndex;
    insertionIndex = [mutable indexOfObject:object inSortedRange:range options:NSBinarySearchingLastEqual usingComparator:self.comparator];
    if (insertionIndex != NSNotFound) {
        ++insertionIndex;
    } else {
        insertionIndex = [mutable indexOfObject:object inSortedRange:range options:NSBinarySearchingInsertionIndex usingComparator:self.comparator];
    }
    [mutable insertObject:object atIndex:insertionIndex];
}

- (void)insertObjects:(NSArray *)objects
{
    // pre-sorting insures that we don't insert two items at the same index path.
    if (self.sortDescriptors) {
        objects = [objects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            id groupID1 = self.groupByBlock(obj1);
            id groupID2 = self.groupByBlock(obj2);
            NSComparisonResult groupResult = [groupID1 compare:groupID2];
            if (groupResult != NSOrderedSame) {
                return groupResult;
            }
            
            NSComparisonResult (^comparator)(id, id) = [self comparator];
            return comparator(obj1, obj2);
        }];
    }
    
    [_beginUpdatesSignal sendNext:[RACUnit defaultUnit]];
    for (id object in objects) {
        [self insertObject:object];
    }
    [_endUpdatesSignal sendNext:[RACUnit defaultUnit]];
}


- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *mutable = [self[indexPath.section] mutableArrayValueForKey:@"groupedObjects"];
    if (mutable.count > indexPath.row) {
        [mutable removeObjectAtIndex:indexPath.row];
    }
}

- (void)removeObjectsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableIndexSet *indexesToRemoveFromCurrentGroup = nil;
    NSInteger currentGroupIndex = NSNotFound;
    
    NSArray *orderedPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    [_beginUpdatesSignal sendNext:[RACUnit defaultUnit]];
    for (NSIndexPath *indexPath in orderedPaths) {
        if (currentGroupIndex != indexPath.section) {
            if ([indexesToRemoveFromCurrentGroup count]) {
                [[self[currentGroupIndex] mutableArrayValueForKey:@"groupedObjects"] removeObjectsAtIndexes:indexesToRemoveFromCurrentGroup];
            }
            
            indexesToRemoveFromCurrentGroup = [NSMutableIndexSet indexSet];
            currentGroupIndex = indexPath.section;
        }
        
        [indexesToRemoveFromCurrentGroup addIndex:indexPath.row];
    }
    if ([indexesToRemoveFromCurrentGroup count]) {
        [[self[currentGroupIndex] mutableArrayValueForKey:@"groupedObjects"] removeObjectsAtIndexes:indexesToRemoveFromCurrentGroup];
    }
    [_endUpdatesSignal sendNext:[RACUnit defaultUnit]];
}

- (void)removeAllObjectsAndGroups
{
    [_groupsByGroupID removeAllObjects];
    NSMutableArray *mutable = [self mutableArrayValueForKey:@"groups"];
    [_beginUpdatesSignal sendNext:[RACUnit defaultUnit]];
    [mutable removeAllObjects];
    [_endUpdatesSignal sendNext:[RACUnit defaultUnit]];
}

- (void)removeGroupWithGroupID:(id)groupID
{
    NSUInteger index = [[self.groups valueForKey:@"id"] indexOfObject:groupID inSortedRange:NSMakeRange(0, self.groups.count) options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    [_beginUpdatesSignal sendNext:[RACUnit defaultUnit]];
    if (index != NSNotFound) {
        [_groupsByGroupID removeObjectForKey:groupID];
        [[self mutableArrayValueForKey:@"groups"] removeObjectAtIndex:index];
    }
    [_endUpdatesSignal sendNext:[RACUnit defaultUnit]];
}

- (NSComparator)comparator
{
    if (!self.sortDescriptors) {
        return nil;
    }
    
    return ^(id left, id right) {
        NSComparisonResult result = NSOrderedSame;
        
        for (NSSortDescriptor *sortDescriptor in self.sortDescriptors) {
            result = [sortDescriptor compareObject:left toObject:right];
            if (result != NSOrderedSame) {
                break;
            }
        }
        
        if (result == NSOrderedSame) {
            return (NSComparisonResult)MAX(-1, MIN(1, (NSInteger)right - (NSInteger)left));
        }
        
        return result;
    };
}

@end


@implementation MLVCCollectionControllerGroup

- (id)initWithID:(id)groupID title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.groupedObjects = [NSMutableArray array];
        _id = groupID;
        _title = title;
    }
    return self;
}

- (NSArray *)objects {
    return self.groupedObjects;
}

/**
 Subscript access
 */
- (id)objectAtIndexedSubscript:(NSUInteger)itemIndex {
    return  self.groupedObjects[itemIndex];
}

- (NSString *)description {
    return  [NSString stringWithFormat:@"<MLVCollectionControllerGroup id=%@, title=%@, contents=\n%@\n>", self.id, self.title, self.objects];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ \"%@\" [[\n%@\n]]", self.id, self.title, self.groupedObjects];
}
@end
