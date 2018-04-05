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
    
    

#import "MLVCTableViewController.h"
#import "MLVCCollectionController.h"
#import "MLVCTableViewCellViewModel.h"
@import ReactiveObjC;
#import <objc/runtime.h>
@import CanvasCore;

#define CURRENT_SYSTEM_VERSION_IS_IOS8_PLUS ([[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."][0] intValue] >= 8)

@interface MLVCTableViewController ()
@property (nonatomic) RACDisposable *beginUpdates, *endUpdates, *groupInserted, *groupDeleted, *objectInserted, *objectDeleted;
@property (nonatomic) PageViewEventLoggerLegacySupport *pageViewEventLog;
@end

CGFloat tableViewHeightForRowAtIndexPath(MLVCTableViewController *self, SEL _cmd, UITableView *tableView, NSIndexPath *indexPath) {
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:heightForRowAtIndexPath:)]) {
        return [cellViewModel tableViewController:self heightForRowAtIndexPath:indexPath];
    }
    return tableView.rowHeight;
}

@implementation MLVCTableViewController {
    RACSubject *_selectedCellViewModelSubject;
    RACSubject *_tableViewDidAppearSubject;
}

+ (void)initialize {
    
    [self supportIOS7];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    RAC(self, title) = RACObserve(self, viewModel.viewControllerTitle);
}

+ (void)supportIOS7 {
    if (!CURRENT_SYSTEM_VERSION_IS_IOS8_PLUS) {
        class_addMethod(self, @selector(tableView:heightForRowAtIndexPath:), (IMP)tableViewHeightForRowAtIndexPath, "f@:@@");
    }
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        RAC(self, title) = RACObserve(self, viewModel.viewControllerTitle);
        self.pageViewEventLog = [PageViewEventLoggerLegacySupport new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (CURRENT_SYSTEM_VERSION_IS_IOS8_PLUS) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.f;
    }

    
    if ([self.viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
        [self.viewModel viewControllerViewDidLoad:self];
    }
    
    if ([self.viewModel respondsToSelector:@selector(tableViewControllerViewDidLoad:)]) {
        [self.viewModel tableViewControllerViewDidLoad:self];
    }
    
    [_selectedCellViewModelSubject sendNext:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.userInteractionEnabled = YES;
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewDidAppear:)]) {
        [self.viewModel viewController:self viewDidAppear:animated];
    }
    
    [_tableViewDidAppearSubject sendNext:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.clearsSelectionOnViewWillAppear) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    }
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewWillAppear:)]) {
        [self.viewModel viewController:self viewWillAppear:animated];
    }
    
    if ([self.viewModel respondsToSelector:@selector(refreshViewModelSignalForced:)]) {
        RACSignal *refreshSignal = [self.viewModel refreshViewModelSignalForced:NO];
        [self.refreshControl beginRefreshing];
        [self.customRefreshControl beginRefreshing];
        [self.tableView scrollRectToVisible:self.refreshControl.frame animated:NO];
        [refreshSignal subscribeError:^(NSError *error) {
            [self.refreshControl endRefreshing];
            [self.customRefreshControl endRefreshing];
            if (self.viewModel.tableviewRefreshCompleted){
                self.viewModel.tableviewRefreshCompleted();
            }
            [self refreshFailed:error];
        } completed:^{
            
            [self.refreshControl endRefreshing];
            [self.customRefreshControl endRefreshing];
            if (self.viewModel.tableviewRefreshCompleted){
                self.viewModel.tableviewRefreshCompleted();
            }
        }];
    }
    [self.pageViewEventLog start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewWillDisappear:)]) {
        [self.viewModel viewController:self viewWillDisappear:animated];
    }
    [self.pageViewEventLog stopWithEventName:self.url];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if ([self.viewModel respondsToSelector:@selector(allowsMultipleSelectionDuringEditing)] && self.viewModel.allowsMultipleSelectionDuringEditing) {
        self.tableView.allowsMultipleSelectionDuringEditing = editing;
    }
    [super setEditing:editing animated:animated];
}

- (void)refreshFromRefreshControl:(id)refreshControl
{
    if ([self.viewModel respondsToSelector:@selector(refreshViewModelSignalForced:)]) {
        [[self.viewModel refreshViewModelSignalForced:YES] subscribeError:^(NSError *error) {
            [refreshControl endRefreshing];
            [self.customRefreshControl endRefreshing];
        } completed:^{
            [refreshControl endRefreshing];
            [self.customRefreshControl endRefreshing];
        }];
    }
}

- (void)endObservingCollectionChanges
{
    [self.beginUpdates dispose];
    [self.endUpdates dispose];
    
    [self.groupInserted dispose];
    self.groupInserted = nil;
    
    [self.groupDeleted dispose];
    self.groupDeleted = nil;
    
    [self.objectInserted dispose];
    self.objectInserted = nil;
    
    [self.objectDeleted dispose];
    self.objectDeleted = nil;
}

- (void)beginObservingCollectionChanges
{
    __weak MLVCTableViewController *weakSelf = self;
    
    self.beginUpdates = [self.viewModel.collectionController.beginUpdatesSignal subscribeNext:^(id x) {
        [weakSelf.tableView beginUpdates];
    }];
    
    self.endUpdates = [self.viewModel.collectionController.endUpdatesSignal subscribeNext:^(id x) {
        [weakSelf.tableView endUpdates];
    }];
    
    self.groupInserted = [self.viewModel.collectionController.groupsInsertedIndexSetSignal subscribeNext:^(id x) {
        [weakSelf.tableView insertSections:x withRowAnimation:UITableViewRowAnimationTop];
    }];
    
    self.groupDeleted = [self.viewModel.collectionController.groupsDeletedIndexSetSignal subscribeNext:^(id x) {
        [weakSelf.tableView deleteSections:x withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    self.objectInserted = [self.viewModel.collectionController.objectsInsertedIndexPathsSignal subscribeNext:^(id x) {
        [weakSelf.tableView insertRowsAtIndexPaths:x withRowAnimation:UITableViewRowAnimationTop];
    }];
    
    self.objectDeleted = [self.viewModel.collectionController.objectsDeletedIndexPathsSignal subscribeNext:^(id x) {
        [weakSelf.tableView deleteRowsAtIndexPaths:x withRowAnimation:UITableViewRowAnimationFade];
    }];
    
}

- (void)setViewModel:(id<MLVCTableViewModel>)viewModel
{
    if (_viewModel == viewModel) {
        return;
    }
    
    [self endObservingCollectionChanges];
    
    _viewModel = viewModel;
    if (self.isViewLoaded) {
        if ([_viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
            [_viewModel viewControllerViewDidLoad:self];
        }
        if ([_viewModel respondsToSelector:@selector(tableViewControllerViewDidLoad:)]) {
            [_viewModel tableViewControllerViewDidLoad:self];
        }
        [self.tableView reloadData];
    }
    
    [self beginObservingCollectionChanges];
    
    if ([_viewModel respondsToSelector:@selector(refreshViewModelSignalForced:)]) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshFromRefreshControl:) forControlEvents:UIControlEventValueChanged];
    } else {
        self.refreshControl = nil;
    }
}

#pragma mark - selection

- (RACSignal *)selectedCellViewModelSignal
{
    return _selectedCellViewModelSubject ?: (_selectedCellViewModelSubject = [RACSubject subject]);
}

- (RACSignal *)tableViewDidAppearSignal
{
    return _tableViewDidAppearSubject ?: (_tableViewDidAppearSubject = [RACSubject subject]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.viewModel.collectionController.groups count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MLVCCollectionControllerGroup *group = self.viewModel.collectionController[section];
    return group.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MLVCCollectionControllerGroup *group = self.viewModel.collectionController[section];
    return [group.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    return [cellViewModel tableViewController:self cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:didSelectRowAtIndexPath:)]) {
        [cellViewModel tableViewController:self didSelectRowAtIndexPath:indexPath];
    }
    [_selectedCellViewModelSubject sendNext:cellViewModel];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:shouldHighlightRowAtIndexPath:)]) {
        return [cellViewModel tableViewController:self shouldHighlightRowAtIndexPath:indexPath];
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:willSelectRowAtIndexPath:)]) {
        return [cellViewModel tableViewController:self willSelectRowAtIndexPath:indexPath];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedCellViewModelSubject sendNext:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:canEditRowAtIndexPath:)]) {
        return [cellViewModel tableViewController:self canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:commitEditingStyle:forRowAtIndexPath:)]) {
        [cellViewModel tableViewController:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:titleForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        return [cellViewModel tableViewController:self titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return NSLocalizedString(@"Delete", @"Default delete button MLVC");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.customRefreshControl scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	[self.customRefreshControl scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)dealloc
{
    [self endObservingCollectionChanges];
}

#pragma mark - Error Handling
- (void)refreshFailed:(NSError *)error {
    NSInteger unauthorizedCode = -1011;
    NSString *title = NSLocalizedString(@"Failed to load", @"Error title for refresh failing on an MLVC tableview controller");
    NSString *message = error.localizedDescription;
    
    if (error.code == unauthorizedCode) {
        title = NSLocalizedString(@"Unauthorized", @"Error message for refresh failing on an MLVC tableview controller");
        message = NSLocalizedString(@"This can happen if your course hasn't started yet or you don't have permission to access this page.", @"Error message for refresh failing with an unauthorized code");
    }
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle: title
                                                                        message: message
                                                                 preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Dismiss", @"uialertaction button name for dismissing the failed refresh error message")
                                                          style: UIAlertActionStyleDestructive
                                                        handler: ^(UIAlertAction *action) {
                                                            NSLog(@"failed refresh error has been dismissed.");
                                                        }];
    
    [controller addAction: alertAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

@end
