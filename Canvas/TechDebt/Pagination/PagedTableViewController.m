
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
    
    

#import "PagedTableViewController.h"
#import "ProgressTableViewCell.h"
#import "PagedTableViewControllerInternal.h"
#import "LoadingDotsCell.h"


@interface PagedTableViewController ()

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSDictionary *sectionsDictionary;

@end


@implementation PagedTableViewController

@synthesize showsNoItemsRow = _isShowingNoItemsRow;
@synthesize showsLoadMoreRow = _isShowingLoadMoreRow;
@synthesize showsErrorRow = _isShowingErrorRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[LoadingDotsCell class] forCellReuseIdentifier:@"LoadMoreCell"];
    
    [self insertSection:0 withIdentifier:NO_ITEMS_SECTION];
    [self insertSection:1 withIdentifier:LOAD_MORE_SECTION];
    [self insertSection:2 withIdentifier:ERROR_SECTION];
}

- (NSMutableArray *)sections
{
    if (!_sections) {
        _sections = [NSMutableArray new];
    }
    return _sections;
}

- (void)reset
{    
    // Don't use the setters for these, because they cause animations,
    // which will try to verify the number of rows. Since we're doing
    // -reloadData anyway, there's no need to set up animations, and
    // avoiding them saves us from having to animate *everything* here
    // to avoid the UITableView animation assertions.
    _isShowingNoItemsRow = NO;
    _isShowingLoadMoreRow = NO;
    _isShowingErrorRow = NO;
    [self.tableView reloadData];
}

- (void)resetWithSectionIdentifiers:(NSArray *)identifiers
{
    [self.sections removeAllObjects];
    
    int sectionIndex = 0;
    for (NSString *identifier in identifiers) {
        [self.sections insertObject:identifier atIndex:sectionIndex++];
    }
    
    [self.sections insertObject:NO_ITEMS_SECTION atIndex:sectionIndex++];
    [self.sections insertObject:LOAD_MORE_SECTION atIndex:sectionIndex++];
    [self.sections insertObject:ERROR_SECTION atIndex:sectionIndex++];
    self.sectionsDictionary = [self sectionDictionaryFromSections:self.sections];
    
    [self reset];
}

- (int)sectionForIdentifier:(NSString *)identifier {
    return [self.sectionsDictionary[identifier] intValue];
}

- (NSString *)identifierForSection:(NSUInteger)section {
    if (section >= [self.sections count]) {
        return nil;
    }
    return self.sections[section];
}

- (void)insertSection:(int)section withIdentifier:(NSString *)identifier {
    //    assert(section <= [sections.count]);
    if ([self.sections containsObject:identifier]) {
        return;
    }
    
    [self.sections insertObject:identifier atIndex:section];
    self.sectionsDictionary = [self sectionDictionaryFromSections:self.sections];
    
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationTop];
}


- (NSDictionary *)sectionDictionaryFromSections:(NSArray *)sections
{
    NSMutableDictionary *sectionDictionary = [NSMutableDictionary new];
    for (int i = 0; i < self.sections.count; i++) {
        sectionDictionary[self.sections[i]] = @(i);
    }
    return sectionDictionary;
}

- (void)setShowsNoItemsRow:(BOOL)showsNoItemsRow {
    if (showsNoItemsRow == _isShowingNoItemsRow) {
        return;
    }
    [self.tableView beginUpdates];
    _isShowingNoItemsRow = showsNoItemsRow;
    
    NSIndexPath *noItemsRow = [NSIndexPath indexPathForRow:0 inSection:[self sectionForIdentifier:NO_ITEMS_SECTION]];
    if (showsNoItemsRow) {
        [self.tableView insertRowsAtIndexPaths:@[noItemsRow]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[noItemsRow]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

- (void)setShowsLoadMoreRow:(BOOL)showsLoadMoreRow {
    NSIndexPath *LoadMoreRow = [NSIndexPath indexPathForRow:0 inSection:[self sectionForIdentifier:LOAD_MORE_SECTION]];
    
    if (showsLoadMoreRow == _isShowingLoadMoreRow) {
        if (showsLoadMoreRow == YES) {
            // They set it to be shown; check if it's already on screen, and if so, trigger load more again
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.tableView cellForRowAtIndexPath:LoadMoreRow]) {
                    [self didSelectLoadMore];
                    
                }
            });
        }
        return;
    }
    [self.tableView beginUpdates];
    _isShowingLoadMoreRow = showsLoadMoreRow;
    

    if (showsLoadMoreRow) {
        [self.tableView insertRowsAtIndexPaths:@[LoadMoreRow]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[LoadMoreRow]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
    
}

- (void)setShowsErrorRow:(BOOL)showsErrorRow {
    if (showsErrorRow == _isShowingErrorRow) {
        return;
    }
    [self.tableView beginUpdates];
    _isShowingErrorRow = showsErrorRow;
    
    NSIndexPath *errorRow = [NSIndexPath indexPathForRow:0 inSection:[self sectionForIdentifier:ERROR_SECTION]];
    if (showsErrorRow) {
        [self.tableView insertRowsAtIndexPaths:@[errorRow]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[errorRow]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

#pragma mark - 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRowsInSectionWithIdentifier:self.sections[section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self sectionForIdentifier:LOAD_MORE_SECTION] ||
        indexPath.section == [self sectionForIdentifier:ERROR_SECTION]) {
        
        return 44;
    }
    else {
        return tableView.rowHeight;
    }
}

- (NSUInteger)numberOfRowsInSectionWithIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:NO_ITEMS_SECTION]) {
        return _isShowingNoItemsRow ? 1 : 0;
    }
    else if ([identifier isEqualToString:LOAD_MORE_SECTION]) {
        return _isShowingLoadMoreRow ? 1 : 0;
    }
    else if ([identifier isEqualToString:ERROR_SECTION]) {
        return _isShowingErrorRow ? 1 : 0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =  [self cellForRow:indexPath.row inSectionWithIdentifier:self.sections[indexPath.section]];
    return cell;
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inSectionWithIdentifier:(NSString *)identifier
{
    UITableViewCell *cell = nil;
    
    // "Load more... row"
    if ([identifier isEqualToString:LOAD_MORE_SECTION]) {
        cell = [self loadMoreCell];
        
    }
    // "No items" row
    else if ([identifier isEqualToString:NO_ITEMS_SECTION]) {
        cell = [self noItemsCell];
    }
    else if ([identifier isEqualToString:ERROR_SECTION]) {
        cell = [self errorCell];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self sectionForIdentifier:LOAD_MORE_SECTION]) {
        [self didSelectLoadMore];
        return nil;
    }
    else if (indexPath.section == [self sectionForIdentifier:ERROR_SECTION]) {
        [self didSelectErrorRow];
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Empty so that subclasses can call super
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *loadMoreRow = [NSIndexPath indexPathForRow:0 inSection:[self sectionForIdentifier:LOAD_MORE_SECTION]];
    if ([indexPath isEqual:loadMoreRow] == NO) {
        return;
    }
    
    [self didSelectLoadMore];
}

- (void)didSelectLoadMore
{
    @throw [NSException exceptionWithName:@"This should be overridden"
                                   reason:@"PagedTableViewController does not implement this method"
                                 userInfo:nil];
}

- (void)didSelectErrorRow
{
    @throw [NSException exceptionWithName:@"This should be overridden"
                                   reason:@"PagedTableViewController does not implement this method"
                                 userInfo:nil];
}

- (UITableViewCell *)loadingCell {
    ProgressTableViewCell *newCell = [self.tableView dequeueReusableCellWithIdentifier:[ProgressTableViewCell cellIdentifier]];
    
    if (newCell == nil) {
        newCell = [[ProgressTableViewCell alloc] init];
    }
    
    newCell.progressMessage.text = NSLocalizedString(@"Loading...", @"Generic loading title with ellipsis");
    [newCell.activityIndicator startAnimating];
    
    return newCell;
}

- (UITableViewCell *)loadMoreCell {
    static NSString *identifier = @"LoadMoreCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    // When voice over is turned on the dequeue fails in iOS 6. Looks like this is fixed in iOS 7
    // See: http://useyourloaf.com/blog/2012/09/07/prototype-table-view-cells-not-working-with-voiceover.html
    if (!cell) {
        cell = [[LoadingDotsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadMoreCell"];
    }
    
    return cell;
}

- (UITableViewCell *)noItemsCell {
    static NSString *identifier = @"NoItemsCell";
    CNVTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CNVTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.textLabel.text = NSLocalizedString(@"There are no items to display", nil);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    cell.userInteractionEnabled = NO;
    return cell;
}

- (UITableViewCell *)errorCell {
    static NSString *identifier = @"ErrorCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.textLabel.text = NSLocalizedString(@"Tap to try again", @"Displayed in a row when an error occurs loading more items");
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];

        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.2];
        cell.backgroundView = backgroundView;
    }
    return cell;
}

@end
