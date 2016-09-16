//
//  PagedItemsViewController.h
//  iCanvas
//
//  Created by BJ Homer on 2/3/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <CanvasKit1/CanvasKit1.h>

#import "PagedTableViewController.h"

@interface PagedItemsViewController : PagedTableViewController


// Finding items
@property (readonly) NSDictionary *itemsBySection;
@property (readonly) NSArray *itemSectionIdentifiers;
- (NSIndexPath *)indexPathForItem:(id)item;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

// Support for the 'Default' section
@property (readonly) NSArray *items; // This is a flattened list of items from all sections.
- (BOOL)sectionContainsItems:(NSUInteger)sectionNumber;
- (NSString *)identifierForDefaultSection;
- (NSUInteger)defaultSectionForItems;

// Fetching from API
- (void)loadMoreItems;
- (void)discardItemsAndReload;
- (void)refreshRecentItemsWithCompletionHandler:(void (^)(void))block;

// Modifying manually
- (void)insertItem:(id)item atIndex:(NSUInteger)index; // Inserts into the default section
- (void)insertItem:(id)item inSectionWithIdentifier:(NSString *)identifier atIndex:(NSUInteger)index;
- (void)deleteItem:(id)item;
- (void)deleteItems:(NSArray *)items;
- (void)updateWithUpdatedItems:(NSArray *)items andMoveToTop:(BOOL)moveToTop;
- (void)sortItemsWithComparator:(NSComparator)comparator;


// Providing data (required overrides)
- (void)requestItemsWithPageURL:(NSURL *)pageURL resultsHandler:(CKPagedArrayBlock)handler;
- (UITableViewCell *)cellForItem:(id)item atIndexPath:(NSIndexPath *)indexPath; // This will be used if present
- (UITableViewCell *)cellForItem:(id)item;


// Optional overrides
- (void)didSelectItem:(id)item inCell:(UITableViewCell *)cell;
- (void)didLoadMoreItems;
- (BOOL)shouldAddItem:(id)item;

@end




// Support for filtering object into multiple sections.
// Note, this still only works with a single paged API endpoint. If you need to combine results from multiple
// endpoints, you'll still need to make your own PagedTableViewController subclass.

@interface PagedItemsViewController (MultipleSections)

- (NSString *)sectionIdentifierForItem:(id)item;
- (void)addItemSectionWithIdentifier:(NSString *)identifier;
- (void)insertItemSectionWithIdentifier:(NSString *)identifier beforeSectionWithIdentifier:(NSString *)otherIdentifier;

// These are redeclared from the superclass, but useful to have alongside the other stuff.
- (int)sectionForIdentifier:(NSString *)identifier;
- (NSString *)identifierForSection:(NSUInteger)section;


@end
