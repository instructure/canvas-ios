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
    
    

#import "CBIMessagesListViewModel.h"
#import "CBIMessageViewModel.h"
#import "CBIMessageScopeSelectionView.h"

#import "EXTScope.h"
#import "CBIMessageDetailViewController.h"
#import "UIViewController+Transitions.h"
@import MyLittleViewController;
#import "MLVCCollectionController+CBIRefresh.h"
@import SoPretty;
@import CanvasKeymaster;
#import "UIImage+TechDebt.h"

@interface CBIMessagesListViewModel ()
@property (nonatomic) CKIConversationScope currentScope;
@property (nonatomic) RACTuple *currentRequestSignalAndDisposable;
@property (nonatomic) RACDisposable *messageListRefresh;
@end

@implementation CBIMessagesListViewModel
@synthesize viewControllerTitle;
@synthesize collectionController;
@synthesize tableviewRefreshCompleted;

- (id)init
{
    self = [super init];
    if (self) {
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:nil groupTitleBlock:nil sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        self.viewControllerTitle = NSLocalizedString(@"Messages", @"Title for the messages screen");
    }
    return self;
}

- (BOOL)allowsMultipleSelectionDuringEditing
{
    return YES;
}

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIMessageCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIMessageCell"];
    tableViewController.tableView.rowHeight = 70.f;
    tableViewController.tableView.separatorInset = UIEdgeInsetsMake(0, 24.f, 0.f, 0.f);
    tableViewController.tableView.backgroundColor = [UIColor prettyOffWhite];
    
    CBIMessageScopeSelectionView *selectionView = [CBIMessageScopeSelectionView new];
    RACSignal *scopeSelectionSignal = RACObserve(selectionView, selectedScope);
    
    @weakify(self, tableViewController);
    [scopeSelectionSignal subscribeNext:^(NSNumber *scope) {
        if (self.currentScope == scope.integerValue) {
            return;
        }
        @strongify(self, tableViewController);
        self.currentScope = [scope integerValue];
        [self refreshViewModelSignalForced:YES];
        tableViewController.navigationItem.leftBarButtonItem = self.currentScope != CKIConversationScopeArchived ? tableViewController.editButtonItem : nil;
    }];
    
    tableViewController.tableView.tableHeaderView = selectionView;
    
    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithImage:[UIImage techDebtImageNamed:@"icon_compose_sml"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    compose.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(tableViewController);
        NSIndexPath *selected = tableViewController.tableView.indexPathForSelectedRow;
        if (selected) {
            [tableViewController.tableView deselectRowAtIndexPath:selected animated:YES];
            [tableViewController tableView:tableViewController.tableView didDeselectRowAtIndexPath:selected];
        }
        
        CBIMessageDetailViewController *messageDetail = [CBIMessageDetailViewController new];
        messageDetail.viewModel = [CBIMessageViewModel new];
        [tableViewController cbi_transitionToViewController:messageDetail animated:YES];
        
        return [RACSignal empty];
    }];
    compose.accessibilityLabel = NSLocalizedString(@"Compose Message", @"button to compose a message");
    
    
    UIBarButtonItem *archiveAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Archive", @"Archive selected messages button") style:UIBarButtonItemStylePlain target:nil action:nil];
    archiveAll.rac_command = [[RACCommand alloc] initWithEnabled:[tableViewController.selectedCellViewModelSignal map:^id(id value) {
        @strongify(tableViewController);
        return @([tableViewController.tableView.indexPathsForSelectedRows count] > 0);
    }] signalBlock:^RACSignal *(id input) {
        @strongify(self, tableViewController);
        return [self archiveItemsSelectedInViewController:tableViewController];
    }];
    archiveAll.accessibilityLabel = NSLocalizedString(@"Archive Selected Messages", @"archive selected messages");
    
    UINavigationItem *nav = tableViewController.navigationItem;
    RACSignal *editingSignal = [tableViewController rac_signalForSelector:@selector(setEditing:animated:)];
    [editingSignal subscribeNext:^(RACTuple *editingAnimated) {
        nav.rightBarButtonItems = [editingAnimated.first boolValue] ? @[archiveAll] : @[compose];
    }];
    [tableViewController setEditing:NO animated:NO];
    
    
    [tableViewController.selectedCellViewModelSignal subscribeNext:^(CBIMessageViewModel *message) {
        @strongify(self);
        if (message.isUnread && self.unreadMessagesCount > 0) {
            self.unreadMessagesCount--;
        }
    }];
}

- (RACSignal *)archiveItemsSelectedInViewController:(MLVCTableViewController *)tvc
{
    @weakify(self, tvc);
    NSArray *indexPaths = [tvc.tableView indexPathsForSelectedRows];
    NSArray *archiveSignals = [[indexPaths.rac_sequence map:^(id value) {
        CBIMessageViewModel *message = [self.collectionController objectAtIndexPath:value];
        return [[CKIClient currentClient] markConversation:message.model asWorkflowState:CKIConversationWorkflowStateArchived];
    }] array];
    
    RACSignal *allArchived = [RACSignal merge:archiveSignals];

    [allArchived subscribeCompleted:^{
        @strongify(self, tvc);
        [tvc setEditing:NO animated:YES];
        [self.collectionController removeObjectsAtIndexPaths:indexPaths];
    }];
    
    return allArchived;
}

- (void)updateUnreadCountWithSignal:(RACSignal *)signal {
    if (self.currentScope == CKIConversationScopeArchived) {
        return;
    }
    
    RACSignal *unreadCountSignal = [signal aggregateWithStart:@(0) reduce:^id(NSNumber *count, NSArray *viewModels) {
        return @([count unsignedIntegerValue] + [[viewModels.rac_sequence filter:^BOOL(CKIConversation *model) {
            return model.workflowState == CKIConversationWorkflowStateUnread;
        }].array count]);
    }];
    
    if (unreadCountSignal != nil) {
        [self rac_liftSelector:@selector(setUnreadMessagesCount:) withSignals:unreadCountSignal, nil];
    }
}

- (RACSignal *)refreshViewModelSignalForced:(BOOL)forced
{
    if (!forced && (self.currentScope == CKIConversationScopeArchived || self.currentRequestSignalAndDisposable)) {
        return self.currentRequestSignalAndDisposable.first ?: [RACSignal empty];
    }
    
    if (forced) {
        [self.currentRequestSignalAndDisposable.second dispose];
        [self.collectionController removeAllObjectsAndGroups];
    }
    
    RACSignal *currentInboxItemModels = [[CKIClient currentClient] fetchConversationsInScope:self.currentScope];
    
    RACTuple *signalAndDisposable = [self.collectionController refreshCollectionWithModelSignal:currentInboxItemModels modelIDBlock:^NSString *(CKIConversation *conversation) {
        return conversation.id;
    } viewModelIDBlock:^NSString *(CBIMessageViewModel *viewModel) {
        return viewModel.model.id;
    } viewModelUpdateBlock:^(CBIMessageViewModel *existingViewModel, CKIConversation *convo) {
        existingViewModel.model = convo;
    } viewModelFactoryBlock:[CBIMessageViewModel modelMappingBlock]];
    
    self.currentRequestSignalAndDisposable = signalAndDisposable;

    RACSignal *refreshSignal = signalAndDisposable.first;
    [self updateUnreadCountWithSignal:refreshSignal];
    @weakify(self);
    [refreshSignal subscribeCompleted:^{
        @strongify(self);
        self.currentRequestSignalAndDisposable = nil;
    }];
    
    return refreshSignal;
}

- (void)badgeTabBarItem:(UITabBarItem *)tabBarItem
{
    RAC(tabBarItem, badgeValue) = [RACObserve(self, unreadMessagesCount) map:^id(NSNumber *unreadCount) {
        if ([unreadCount unsignedIntegerValue] == 0) {
            return nil;
        }
        return [unreadCount description];
    }];
    [[[RACObserve(self, unreadMessagesCount) takeUntil:TheKeymaster.signalForLogout] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *count) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = count.integerValue;
    }];
    
    [self refreshViewModelSignalForced:NO];
    @weakify(self);
    self.messageListRefresh = [[[RACSignal interval:2*60/* 2 minutes */ onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self refreshViewModelSignalForced:NO];
    }] asScopedDisposable];
}
@end
