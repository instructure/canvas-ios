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
    
    

#import <CanvasKit1/CanvasKit1.h>

#import "PagedItemsViewController.h"
#import "UITableView+in_updateInBlocks.h"
#import "PagedTableViewControllerInternal.h"
#import "CanvasKit1/CKPaginationInfo.h"
#import "CanvasKit1/CKCommonTypes.h"
#import <CanvasKit1/NSArray+CKAdditions.h>
#import "iCanvasErrorHandler.h"

@implementation PagedItemsViewController
{
    NSURL *nextPageURL;
    BOOL foundLastPage;
    
    NSMutableDictionary *itemsBySection;
    NSMutableArray *knownItemSectionIdentifiers;
    
    BOOL isLoading;
}

@synthesize itemsBySection = itemsBySection;




#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    knownItemSectionIdentifiers = [NSMutableArray new];
    itemsBySection = [NSMutableDictionary new];

    [self addItemSectionWithIdentifier:MAIN_SECTION];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.items == nil || isLoading == NO) {
        [self loadMoreItems];
    }
}


#pragma mark - Finding items

- (NSIndexPath *)indexPathForItem:(id)item
{
    for (NSString *identifier in knownItemSectionIdentifiers) {
        NSUInteger index = [itemsBySection[identifier] indexOfObjectWithSameIdentityAsObject:item];
        if (index != NSNotFound) {
            NSUInteger sectionIndex = [self sectionForIdentifier:identifier];
            return [NSIndexPath indexPathForRow:index inSection:sectionIndex];
        }
    }
    return nil;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionContainsItems:indexPath.section] == NO) {
        return nil;
    }
    
    NSString *sectionIdentifier = [self identifierForSection:indexPath.section];
    id item = self.itemsBySection[sectionIdentifier][indexPath.row];
    return item;
}



#pragma mark - Support for the default section

- (NSArray *)items {
    NSMutableArray *allItems = [NSMutableArray new];
    for (NSString *identifier in knownItemSectionIdentifiers) {
        [allItems addObjectsFromArray:itemsBySection[identifier]];
    }
    if (allItems.count == 0) {
        allItems = nil;
    }
    return allItems;
}

- (BOOL)sectionContainsItems:(NSUInteger)sectionNumber {
    NSString *identifier = [self identifierForSection:sectionNumber];
    
    if ([knownItemSectionIdentifiers containsObject:identifier] && [self.itemsBySection[identifier] count] > 0) {
        return YES;
    }
    
    return NO;
}

- (NSString *)identifierForDefaultSection {
    return MAIN_SECTION;
}

- (NSUInteger)defaultSectionForItems {
    return [self sectionForIdentifier:[self identifierForDefaultSection]];
}



#pragma mark - Fetching from API
- (void)discardItemsAndReload {
    for (NSString *identifier in knownItemSectionIdentifiers) {
        [itemsBySection[identifier] removeAllObjects];
    }
    foundLastPage = NO;
    nextPageURL = nil;
    
    [self reset];
    
    [self performSelector:@selector(loadMoreItems) withObject:nil afterDelay:0.0];
}

- (void)refreshRecentItemsWithCompletionHandler:(void (^)(void))block {
    isLoading = YES;
    self.showsErrorRow = NO;
    [self requestItemsWithPageURL:nil resultsHandler:^(NSError *error, NSArray *theArray, CKPaginationInfo *pagination) {
        isLoading = NO;
        if (error) {
            [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
            self.showsErrorRow = YES;
            self.showsLoadMoreRow = NO;
        }
        else {
            __block NSMutableArray *filteredArray = [NSMutableArray new];
            [theArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self shouldAddItem:obj]) {
                    [filteredArray addObject:obj];
                }
            }];
            
            [self updateWithUpdatedItems:filteredArray andMoveToTop:YES];
            
            NSMutableDictionary *indexOfLastItemToKeepBySection = [NSMutableDictionary new];
            for (id item in filteredArray) {
                NSString *identifier = [self sectionIdentifierForItem:item];
                NSUInteger itemIndexInSection = [self.itemsBySection[identifier] indexOfObject:item];
                
                NSUInteger currentMaxIndexInSection = [indexOfLastItemToKeepBySection[identifier] unsignedIntegerValue];
                if (currentMaxIndexInSection < itemIndexInSection) {
                    indexOfLastItemToKeepBySection[identifier] = @(itemIndexInSection);
                }
            }
            
            for (NSString *identifier in knownItemSectionIdentifiers) {
                
                NSInteger lastItemToKeep = [indexOfLastItemToKeepBySection[identifier] unsignedIntegerValue];
                NSInteger countOfItemsToRemove = [itemsBySection[identifier] count] - lastItemToKeep - 1;
                NSInteger lastItemToRemove = lastItemToKeep + countOfItemsToRemove - 1;
                
                NSUInteger sectionIndex = [self sectionForIdentifier:identifier];
                
                if (countOfItemsToRemove > 0) {
                    NSMutableArray *indexPathsToDelete = [NSMutableArray new];
                    for (NSUInteger i=lastItemToKeep; i <= lastItemToRemove; ++i) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
                        [indexPathsToDelete addObject:indexPath];
                    }
                    NSRange itemRange = NSMakeRange(lastItemToKeep, countOfItemsToRemove);
                    [itemsBySection[identifier] removeObjectsInRange:itemRange];
                    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            
            
            nextPageURL = pagination.nextPage;
            foundLastPage = (nextPageURL == nil);
            
            self.showsLoadMoreRow = !foundLastPage;
            self.showsErrorRow = NO;
            
            if (block) {
                block();
            }
        }
    }];
}

- (void)loadMoreItems {
    if (foundLastPage || isLoading) {
        if (foundLastPage) {
            [self setShowsLoadMoreRow:NO];            
            [self.tableView reloadData];
        }
        return;
    }
    
    isLoading = YES;
    
    UITableView *tableView = self.tableView;
    
    // Animate in the "Loading" dots
    self.showsLoadMoreRow = YES;
    
    [self requestItemsWithPageURL:nextPageURL resultsHandler:
     ^(NSError *error, NSArray *theArray, CKPaginationInfo *pagination) {
         isLoading = NO;
         if (error) {
             [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
             self.showsErrorRow = YES;
             self.showsLoadMoreRow = NO;
             return;
         }
         
         nextPageURL = pagination.nextPage;
         
         [tableView in_updateWithBlock:^{
             // Find out which section each item should go into
             NSMutableDictionary *itemsToAddBySection = [NSMutableDictionary new];
             [theArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 if ([self shouldAddItem:obj]) {
                     NSString *identifier = [self sectionIdentifierForItem:obj];
                     if ([knownItemSectionIdentifiers containsObject:identifier] == NO) {
                         [self addItemSectionWithIdentifier:identifier];
                     }
                     NSMutableArray *sectionItemsToAdd = itemsToAddBySection[identifier];
                     if (sectionItemsToAdd == nil) {
                         sectionItemsToAdd = itemsToAddBySection[identifier] = [NSMutableArray new];
                     }
                     [sectionItemsToAdd addObject:obj];
                 }
             }];
             
             // Insert new rows into each relevant section
             for (NSString *sectionIdentifier in itemsToAddBySection) {
                 
                 NSMutableArray *sectionItems = itemsBySection[sectionIdentifier];
                 NSMutableArray *sectionItemsToAdd = itemsToAddBySection[sectionIdentifier];
                 
                 NSRange insertedRange = NSMakeRange(sectionItems.count, sectionItemsToAdd.count);
                 [sectionItems addObjectsFromArray:sectionItemsToAdd];
                 
                 NSMutableArray *insertedRowIndexPaths = [NSMutableArray array];
                 NSUInteger sectionIndex = [self sectionForIdentifier:sectionIdentifier];
                 for (NSInteger i=insertedRange.location, end=(i+insertedRange.length); i<end; ++i) {
                     NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
                     [insertedRowIndexPaths addObject:newIndexPath];
                 }
                 
                 [self.tableView insertRowsAtIndexPaths:insertedRowIndexPaths
                                       withRowAnimation:UITableViewRowAnimationFade];
             }
             
             
             self.showsErrorRow = NO;
             if (pagination.nextPage) {
                 self.showsLoadMoreRow = YES;
             }
             else {
                 self.showsLoadMoreRow = NO;
                 foundLastPage = YES;
                 if ([self hasNoItems]) {
                     self.showsNoItemsRow = YES;
                 }
             }
             
         }];
         [self didLoadMoreItems];
     }];
}

#pragma mark - Modifying contents manually

- (void)insertItem:(id)item atIndex:(NSUInteger)index {
    [self insertItem:item inSectionWithIdentifier:[self identifierForDefaultSection] atIndex:index];
}

- (void)insertItem:(id)item inSectionWithIdentifier:(NSString *)identifier atIndex:(NSUInteger)index {
    [self.tableView beginUpdates];
    [itemsBySection[identifier] insertObject:item atIndex:index];
    
    self.showsNoItemsRow = NO;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[self sectionForIdentifier:identifier]];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)moveItem:(id)item toSectionWithIdentifier:(NSString *)newSectionIdentifier atIndex:(NSUInteger)index {
    NSIndexPath *oldPath = [self indexPathForItem:item];
    if (oldPath == nil) {
        NSLog(@"Trying to move item to %@[%zd], but it is not currently in the table. Inserting instead, but this is slower.", newSectionIdentifier, index);
        [self insertItem:item inSectionWithIdentifier:newSectionIdentifier atIndex:index];
        return;
    }
    
    NSUInteger newSectionIndex = [self sectionForIdentifier:newSectionIdentifier];
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:index inSection:newSectionIndex];
    
    [self moveItemFromIndexPath:oldPath toIndexPath:newPath];
    
}

- (void)deleteItem:(id)item {
    [self.tableView beginUpdates];
    NSString *identifier = [self sectionIdentifierForItem:item];
    NSUInteger index = [itemsBySection[identifier] indexOfObject:item];
    
    if (index == NSNotFound) {
        return;
    }
    
    [itemsBySection[identifier] removeObjectAtIndex:index];
    
    if ([self hasNoItems]) {
        self.showsNoItemsRow = YES;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[self sectionForIdentifier:identifier]];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

- (void)deleteItems:(NSArray *)items {
    [self.tableView beginUpdates];
    for (id item in items.reverseObjectEnumerator) {
        [self deleteItem:item];
    }
    [self.tableView endUpdates];
}

- (void)updateWithUpdatedItems:(NSArray *)updatedItems andMoveToTop:(BOOL)moveToTop {
    
    // Fix to prevent crashing if no favorites exist, ref #MBL-741
    if (!updatedItems || [updatedItems count] <= 0) {
        return;
    }
    
    NSDictionary *previousItems = [[NSMutableDictionary alloc] initWithDictionary:itemsBySection copyItems:YES];
    
    [self.tableView beginUpdates];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    id selectedItem = nil;
    if (selectedIndexPath) {
        selectedItem = [self itemAtIndexPath:selectedIndexPath];
    }
    
    NSMutableDictionary *insertionIndicesBySection = [NSMutableDictionary new]; // These will start at '0', because nil is like 0.
    

    NSMutableSet *setOfItemsToUpdate = [NSMutableSet setWithCapacity:[updatedItems count]];
    for (id item in updatedItems) {
        id identEqualityCheck = ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            BOOL matches = ([item hasSameIdentityAs:obj]);
            if (matches) { *stop = YES; }
            return matches;
        };
        
        NSString *newSectionIdentifier = [self sectionIdentifierForItem:item];
        NSString *previousSectionIdentifier = nil;
        
        // Find the previous identifier
        if ([previousItems[newSectionIdentifier] indexOfObjectPassingTest:identEqualityCheck] != NSNotFound) {
            // Assume that most of the time, objects will stay in their same section when updated.
            previousSectionIdentifier = newSectionIdentifier;
        }
        else {
            for (NSString *identifier in previousItems) {
                if ([previousItems[identifier] indexOfObjectPassingTest:identEqualityCheck] != NSNotFound) {
                    previousSectionIdentifier = identifier;
                    break;
                }
            }
        }
        
        
        if (previousSectionIdentifier == nil) {
            // It's a new item. We can do nothing but insert it at the top.
            NSUInteger insertionRow = [insertionIndicesBySection[newSectionIdentifier] unsignedIntegerValue];
            [self insertItem:item inSectionWithIdentifier:newSectionIdentifier atIndex:insertionRow];
            insertionIndicesBySection[newSectionIdentifier] = @(insertionRow + 1);
        }
        else {
            // It already existed; update and move it to the new place
            NSUInteger previousItemRow = [previousItems[previousSectionIdentifier] indexOfObjectPassingTest:identEqualityCheck];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:previousItemRow inSection:[self sectionForIdentifier:previousSectionIdentifier]];
            
            NSUInteger interimItemRow = [itemsBySection[previousSectionIdentifier] indexOfObjectPassingTest:identEqualityCheck];;
            
            NSUInteger destinationItemRow;
            BOOL needsMove = NO;
            if (moveToTop || [previousSectionIdentifier isEqualToString:newSectionIdentifier] == NO) {
                destinationItemRow = [insertionIndicesBySection[newSectionIdentifier] unsignedIntegerValue];
                insertionIndicesBySection[newSectionIdentifier] = @(destinationItemRow + 1);
                needsMove = YES;
            }
            else {
                // It's staying in the same place
                destinationItemRow = previousItemRow;
            }
            NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:destinationItemRow inSection:[self sectionForIdentifier:newSectionIdentifier]];
            
            if (needsMove) {
                [self moveItemFromIndexPath:previousIndexPath currentModelRow:interimItemRow toIndexPath:destinationIndexPath];
            }
            
            [setOfItemsToUpdate addObject:[self indexPathForItem:item]];
        }
    }
    [self.tableView endUpdates];
    
    NSSet *visibleCells = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    [setOfItemsToUpdate intersectSet:visibleCells];
    
    [self.tableView reloadRowsAtIndexPaths:[setOfItemsToUpdate allObjects] withRowAnimation:UITableViewRowAnimationFade];
    if (selectedItem) {
        [self.tableView selectRowAtIndexPath:[self indexPathForItem:selectedItem] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}


- (void)sortItemsWithComparator:(NSComparator)comparator {
    [self.tableView beginUpdates];
    for (NSString *identifier in knownItemSectionIdentifiers) {
        NSMutableArray *items = itemsBySection[identifier];
        NSArray *oldItems = [items copy];
        [items sortUsingComparator:comparator];
        
        NSMutableDictionary *indexMapping = [NSMutableDictionary new];
        [oldItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            // First check if it's at the same index; if so, bail quickly.
            if (items[idx] == obj) {
                return;
            }
            NSUInteger newLocation = [items indexOfObjectIdenticalTo:obj];
            indexMapping[@(idx)] = @(newLocation);
        }];
        
        if (indexMapping.count > 0) {
            UITableView *tableView = self.tableView;
            NSUInteger itemSection = [self sectionForIdentifier:identifier];
            
            [tableView in_updateWithBlock:^{
                [indexMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    
                    NSUInteger old = [key unsignedIntegerValue];
                    NSUInteger new = [obj unsignedIntegerValue];
                    NSIndexPath *oldPath = [NSIndexPath indexPathForRow:old inSection:itemSection];
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:new inSection:itemSection];
                    
                    [tableView moveRowAtIndexPath:oldPath toIndexPath:newPath];
                }];
            }];
        }
    }
    [self.tableView endUpdates];
}

#pragma mark - Providing data (Required overrides)

- (void)requestItemsWithPageURL:(NSURL *)pageURL resultsHandler:(CKPagedArrayBlock)handler {
    @throw [NSException exceptionWithName:@"This should be overridden"
                                   reason:@"PagedItemsViewController does not implement this method"
                                 userInfo:nil];
}

- (void)updateItem:(id)item withHandler:(void (^)(id))handler {
    @throw [NSException exceptionWithName:@"This should be overridden"
                                   reason:@"PagedItemsViewController does not implement this method"
                                 userInfo:nil];
}

- (UITableViewCell *)cellForItem:(id)item atIndexPath:(NSIndexPath *)indexPath {
    return [self cellForItem:item];
}

- (UITableViewCell *)cellForItem:(id)item {
    @throw [NSException exceptionWithName:@"This should be overridden"
                                   reason:@"PagedItemsViewController does not implement this method"
                                 userInfo:nil];
}

#pragma mark - Optional overrides for subclasses

- (void)didSelectItem:(id)item inCell:(UITableViewCell *)cell {
    // Does nothing by default, but can be overridden by subclasses.
}

- (void)didLoadMoreItems {
    // Does nothing by default, but can be overridden by subclasses.
}

- (BOOL)shouldAddItem:(id)item
{
    return YES;
}


#pragma mark - PagedTableViewController & UITableViewController overrides

- (NSUInteger)numberOfRowsInSectionWithIdentifier:(NSString *)identifier
{
    if ([knownItemSectionIdentifiers containsObject:identifier]) {
        return [itemsBySection[identifier] count];
    }
    return [super numberOfRowsInSectionWithIdentifier:identifier];
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inSectionWithIdentifier:(NSString *)identifier
{    
    // Item row
    if ([knownItemSectionIdentifiers containsObject:identifier]) {
        id item = itemsBySection[identifier][row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:[self sectionForIdentifier:identifier]];
        return [self cellForItem:item atIndexPath:indexPath];
    }
    return [super cellForRow:row inSectionWithIdentifier:identifier];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionContainsItems:indexPath.section]) {
        NSString *identifier = [self identifierForSection:indexPath.section];
        id item = self.itemsBySection[identifier][indexPath.row];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self didSelectItem:item inCell:cell];
        return;
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    if ([indexPath isEqual:[tableView indexPathForSelectedRow]]) {
        cell.selected = YES;
    }
}

- (void)didSelectLoadMore
{
    [self loadMoreItems];
}

- (void)didSelectErrorRow {
    [self loadMoreItems];
    [self.tableView in_updateWithBlock:^{
        self.showsErrorRow = NO;
        self.showsLoadMoreRow = YES;
    }];
}

#pragma mark - Multiple section support
- (NSString *)sectionIdentifierForItem:(id)item {
    // May be overridden;
    return [self identifierForDefaultSection];
}


- (void)addItemSectionWithIdentifier:(NSString *)identifier {
    NSAssert([knownItemSectionIdentifiers containsObject:identifier] == NO, @"You can't insert a section that already exists");
    NSUInteger sectionIndex = 1 + knownItemSectionIdentifiers.count;
    
    [knownItemSectionIdentifiers addObject:identifier];
    itemsBySection[identifier] = [NSMutableArray new];
    [self insertSection:(int)sectionIndex withIdentifier:identifier];
}

- (void)insertItemSectionWithIdentifier:(NSString *)identifier beforeSectionWithIdentifier:(NSString *)otherIdentifier {
    NSAssert([knownItemSectionIdentifiers containsObject:identifier] == NO, @"You can't insert a section that already exists");
    NSUInteger sectionIndex = 1 + [knownItemSectionIdentifiers indexOfObject:otherIdentifier];
    
    [knownItemSectionIdentifiers addObject:identifier];
    itemsBySection[identifier] = [NSMutableArray new];
    [self insertSection:(int)sectionIndex withIdentifier:identifier];
}

#pragma mark - Internal stuff

- (BOOL)hasNoItems {
    __block NSUInteger itemCount = 0;
    [itemsBySection enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, NSArray *items, BOOL *stop) {
        itemCount += items.count;
    }];
    return itemCount == 0;
}


- (void)moveItemFromIndexPath:(NSIndexPath *)oldPath toIndexPath:(NSIndexPath *)newPath {
    [self moveItemFromIndexPath:oldPath currentModelRow:oldPath.row toIndexPath:newPath];
}


// Use this one if you're in the middle of a batch update and the item's tableView row doesn't match the current model row
- (void)moveItemFromIndexPath:(NSIndexPath *)oldPath currentModelRow:(NSUInteger)currentRowInOldSection toIndexPath:(NSIndexPath *)newPath {
    
    if ([oldPath isEqual:newPath]) {
        return;
    }
    
    [self.tableView in_updateWithBlock:^{
        
        NSString *oldSectionIdentifier = [self identifierForSection:oldPath.section];
        NSMutableArray *oldSectionItems = itemsBySection[oldSectionIdentifier];
        
        id item = oldSectionItems[currentRowInOldSection];
        [oldSectionItems removeObjectAtIndex:currentRowInOldSection];
        
        NSString *newSectionIdentifier = [self identifierForSection:newPath.section];
        NSMutableArray *newSectionItems = itemsBySection[newSectionIdentifier];
        [newSectionItems insertObject:item atIndex:newPath.row];
        
        [self.tableView moveRowAtIndexPath:oldPath toIndexPath:newPath];
    }];
}



@end
