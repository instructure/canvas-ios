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
