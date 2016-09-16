//
//  PagedTableViewController.h
//  iCanvas
//
//  Created by Joshua Dutton on 8/20/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagedTableViewController : UITableViewController

@property (nonatomic, assign) BOOL showsNoItemsRow;
@property (nonatomic, assign) BOOL showsLoadMoreRow;
@property (nonatomic, assign) BOOL showsErrorRow;

- (void)reset;
- (void)resetWithSectionIdentifiers:(NSArray *)identifiers;

// Auxiliary section support
- (int)sectionForIdentifier:(NSString *)identifier;
- (NSString *)identifierForSection:(NSUInteger)section;
// Adds a new section to the data model and inserts it into the table view
- (void)insertSection:(int)section withIdentifier:(NSString *)identifier;

// Required overrides
- (UITableViewCell *)cellForRow:(NSUInteger)row inSectionWithIdentifier:(NSString *)identifier;
- (NSUInteger)numberOfRowsInSectionWithIdentifier:(NSString *)identifier;
- (void)didSelectLoadMore;
- (void)didSelectErrorRow;

// Optional overrides
- (UITableViewCell *)loadMoreCell;
- (UITableViewCell *)noItemsCell;
- (UITableViewCell *)errorCell;




@end
