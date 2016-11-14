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
    
    

#import <QuartzCore/QuartzCore.h>
#import <CanvasKit1/CanvasKit1.h>
#import "UIViewController+AnalyticsTracking.h"
#import <CanvasKit1/NSArray+CKAdditions.h>
#import <CanvasKit1/CKUploadProgressToolbar.h>
#import <CanvasKit1/CKAlertViewWithBlocks.h>

#import "ThreadedDiscussionViewController.h"
#import "ThreadedDiscussionViewControllerProtected.h"
#import "DiscussionEntryCell.h"
#import "ShortPressGestureRecognizer.h"
#import "WebBrowserViewController.h"
#import "ProfileViewController.h"
#import "ContentLockViewController.h"
#import "UITableView+in_updateInBlocks.h"
#import "Router.h"
#import "DiscussionEntryHeightCalculationQueue.h"

#import "CBIModuleProgressNotifications.h"
#import "RatingsController.h"
#import "CKIClient+CBIClient.h"
#import "CKRichTextInputView.h"
#import "Analytics.h"
#import "iCanvasErrorHandler.h"

@import CanvasKeymaster;
@import SoPretty;
#import "CBILog.h"
#import "UIImage+TechDebt.h"


#define PADDING_BOTTOM 10
typedef void (^FetchAll)(NSArray *allObjects);
typedef void (^FetchAllDiscussions)(NSArray *allObjects, unsigned long long assignmentID);
typedef void (^RouteToGroupDiscussionFailureBlock)();

static NSInteger const kUnsavedReplyAlertTag = 1;

enum {
    GoBackSection = 0,
    MainSection = 1,
    RepliesHiddenSection = 2,
    LoadingSection = 3,
    NumberOfSections
};

@interface CellHeights : NSObject
@property (strong) NSMutableDictionary *portraitCellHeights;
@property (strong) NSMutableDictionary *landscapeCellHeights;
@end

@implementation CellHeights
@synthesize portraitCellHeights = _portraitCellHeights;
@synthesize landscapeCellHeights = _landscapeCellHeights;
- (id)init {
    self = [super init];
    if (self) {
        _portraitCellHeights = [NSMutableDictionary new];
        _landscapeCellHeights = [NSMutableDictionary new];
    }
    return self;
}
@end

@interface ThreadedDiscussionViewController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, CKRichTextInputViewDelegate, DiscussionEntryCellDelegate, UIAlertViewDelegate> {
    
    NSMutableArray *cellHeightsStack;
    NSIndexPath *exclusiveVisibleRow;
    
    NSURL *nextTopicPageURL;
    
    CKRichTextInputView *inputView;
    UIView *overlayView;
    
    CKUploadProgressToolbar *progressToolbar;
    
    BOOL requiresPostBeforeLoading;
    
    UIInterfaceOrientation currentOrientation;
    
    NSIndexPath *tappedIndexPath;
    BOOL isEditingEntry;
    BOOL isShowingMenuToEditDeleteEntry;
    BOOL isInProcessOfHidingMenuToEditDeleteEntry;
    
    DiscussionEntryHeightCalculationQueue *queue;
}

@property CKCourse *course; // Used for enrollment info
@property (assign, nonatomic) BOOL showLoadingRow;
@property (assign, nonatomic) BOOL showGoBackRow;
@property (assign, nonatomic) BOOL showsInputView;
@property (assign, nonatomic) BOOL showsReplyRow;
@property (assign, nonatomic) BOOL showsRepliesHiddenRow;
@property (nonatomic) BOOL isFetchingTopic;
@property (nonatomic) BOOL isLoaded;
@property (nonatomic, strong) CKAssignment *assignment;
@property (nonatomic, strong) UIBarButtonItem *replyBarButtonItem;

@property (nonatomic) NSMutableDictionary *entryIDHasBeenMarkedRead;
@property (nonatomic, strong) NSMutableArray<CKDiscussionEntry *> *addedEntries;

@end

@implementation ThreadedDiscussionViewController
@synthesize showLoadingRow = _isShowingLoadingRow;
@synthesize showGoBackRow = _isShowingGoBackRow;
@synthesize showsReplyRow = _isShowingReplyRow;
@synthesize showsInputView = _isShowingInputView;
@synthesize showsRepliesHiddenRow = _isShowingRepliesHiddenRow;

- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"ThreadedDiscussion" bundle:[NSBundle bundleForClass:[self class]]] 
            instantiateInitialViewController];
    if (self) {
        queue = [DiscussionEntryHeightCalculationQueue new];
        _entryIDHasBeenMarkedRead = [NSMutableDictionary new];
        _isFetchingTopic = NO;
        _isLoaded = NO;
        _addedEntries = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *backgroundView = [UIView new];
    self.tableView.backgroundView = backgroundView;
    [backgroundView setBackgroundColor:[UIColor prettyOffWhite]];
    
    currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    cellHeightsStack = [NSMutableArray new];
    CellHeights *heights = [CellHeights new];
    [cellHeightsStack addObject:heights];

    if (self.topic == nil) {
        // Try announcements
        [self fetchTopic:YES];
    } else {
        // Not announcements
        [self fetchTopic:NO];
    }


    if (self.contextInfo.contextType == CKContextTypeCourse && self.course == nil) {
        [self.canvasAPI getCourseWithId:self.contextInfo.ident options:nil block:^(NSError *error, BOOL isFinalValue, id object) {
            // If there was an error, don't be verbose about it; this just gives us more informatoin when determining whether
            // or not to allow entry deletion]
            if (error) {
                NSLog(@"Failed to load course information: %@", error);
            }
            else {
                self.course = object;
            }
        }];
    }
    
    [self.notificationCenter addObserver:self selector:@selector(willHideEditMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(didHideEditMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    [self updateReplyButtonImage];
    
    RAC(self.replyBarButtonItem, enabled, @NO) = RACObserve(self, isLoaded);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        [RatingsController appLoadedOnViewController:self];
    }
}

- (void)updateReplyButtonImage {
    if (self.topic.contentLock) {
        self.replyBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage techDebtImageNamed:@"icon_locked_fill"] style:UIBarButtonItemStylePlain target:self action:@selector(replyButtonTouched:)];
    } else {
        self.replyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(replyButtonTouched:)];
    }
    
    [self.navigationItem setRightBarButtonItem:self.replyBarButtonItem];
}

- (void)replyButtonTouched:(UIBarButtonItem*)sender
{
    DDLogVerbose(@"replyButtonTouched");
    if (_topic.contentLock) {
        NSString *explanation = @"";
        
        if (_topic.contentLock.unlockDate && [_topic.contentLock.unlockDate compare:[NSDate date]] == NSOrderedDescending) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterLongStyle];
            
            NSString *dateExplanationFormat = NSLocalizedString(@"Will unlock %@.", @"unlock date for discussion/announcement");
            NSString *formattedDate = [dateFormatter stringFromDate:_topic.contentLock.unlockDate];
            explanation = [NSString stringWithFormat:dateExplanationFormat, formattedDate];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Comments are disabled", nil) message:explanation delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    } else {
        [self.tableView beginUpdates];
        self.showsReplyRow = NO;
        self.showsInputView = YES;
        
        NSUInteger itemCount = [self tableView:self.tableView numberOfRowsInSection:MainSection];
        NSIndexPath *lastEntry = [NSIndexPath indexPathForRow:(itemCount-1) inSection:MainSection];
        [self.tableView scrollToRowAtIndexPath:lastEntry atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self.tableView endUpdates];
    }
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [self.notificationCenter removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([self isMovingToParentViewController]) {
        [self.tableView reloadData];
    }
    UIEdgeInsets insets = self.tableView.contentInset;
    [self.tableView setContentInset:UIEdgeInsetsMake(insets.top, insets.left, insets.bottom + PADDING_BOTTOM, insets.right)];
    
    
    // mark the topic as read
    if (self.viewModel) {
        [[TheKeymaster.currentClient markTopicAsRead:self.viewModel.model] subscribeError:^(NSError *error) {
            NSLog(@"what went wrong?");
        } completed:^{
            // empty, cause.... who cares? have to subscribe or it won't be marked as 'read'
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
    [Analytics logScreenView:kGAIScreenDiscussion];
    
    DDLogVerbose(@"ThreadedDiscussionViewController posting module item progress update after viewDidAppear with self.topicIdent");
    CBIPostModuleItemProgressUpdate([@(self.topicIdent) description], CKIModuleItemCompletionRequirementMustView);
    if (self.topic.assignmentIdent) {
        DDLogVerbose(@"ThreadedDiscussionViewController posting module item progress update after viewDidAppear with self.topic.assignmentIdent");
        CBIPostModuleItemProgressUpdate([@(self.topic.assignmentIdent) description], CKIModuleItemCompletionRequirementMustView);
    }
}

- (NSMutableDictionary *)cellHeights {
    return [self cellHeightsForOrientation:currentOrientation];
}

- (NSMutableDictionary *)cellHeightsForOrientationOppositeOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return [self cellHeightsForOrientation:UIInterfaceOrientationLandscapeLeft];
    }
    else {
        return [self cellHeightsForOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)pushNewCellHeights {
    CellHeights *heights = [CellHeights new];
    [cellHeightsStack addObject:heights];
}

- (void)popCellHeights {
    [cellHeightsStack removeLastObject];
}

- (void)resetCellHeights {
    cellHeightsStack = [NSMutableArray new];
    CellHeights *heights = [CellHeights new];
    [cellHeightsStack addObject:heights];
}

- (NSMutableDictionary *)cellHeightsForOrientation:(UIInterfaceOrientation)orientation {
    CellHeights *currentHeights = [cellHeightsStack lastObject];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return currentHeights.portraitCellHeights;
    }
    else {
        return currentHeights.landscapeCellHeights;
    }
}

- (void)calculateCellHeights {
    if (_topic == nil || self.tableView == nil) {
        return;
    }
    UIInterfaceOrientation orientation = currentOrientation;
    
    __weak ThreadedDiscussionViewController *weakSelf = self;
    
    id root = [self rootEntry];
    NSArray *children = [self childEntries];
    NSArray *entries = [@[asEntry(root)] arrayByAddingObjectsFromArray:children];
    
    [entries enumerateObjectsUsingBlock:
     ^(CKDiscussionEntry *entry, NSUInteger i, BOOL *stop) {
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:MainSection];
         
         if ([self cellHeights][indexPath] != nil) {
             
             return;// from the enumeration block
         }
         
         NSInteger indentationLevel = [self tableView:self.tableView indentationLevelForRowAtIndexPath:indexPath];
         
         [queue calculateCellHeightForEntry:entry inTableView:self.tableView withIndentationLevel:(int)indentationLevel handler:^(CGFloat height) {
             [weakSelf recordHeight:height forRoot:root indexPath:indexPath orientation:orientation];
         }];
     }];
}

- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath
{
    [[self cellHeights] removeObjectForKey:indexPath];
    
    DiscussionEntryCell *cell = (DiscussionEntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    CKDiscussionEntry * entry = [self itemForIndexPath:indexPath];
    cell.entry = entry;

    [self calculateCellHeights];
}

- (void)fetchTopic:(BOOL)isAnnouncement {
    self.showLoadingRow = YES;
    if (!_isFetchingTopic){
        _isFetchingTopic = YES;
        [self.canvasAPI getDiscussionTopicForIdent:self.topicIdent inContext:self.contextInfo block:^(NSError *error, BOOL isFinalValue, CKDiscussionTopic *topic) {
            if (error) {
                _isFetchingTopic = NO;
                [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
                return;
            }
            
            //route to group discussion from current course
            if (isFinalValue && [topic.topicChildren count] && self.contextInfo.contextType == CKContextTypeCourse){
                RouteToGroupDiscussionFailureBlock loadOriginalTopic = ^() {
                    self.topic = topic;
                };
                
                [self routeToGroupDiscussion:(CKDiscussionTopic *)topic onFailure:loadOriginalTopic];
                
            } else if (isFinalValue){
                self.topic = topic;
            }
        }];
    }
}

- (void)routeToGroupDiscussion:(CKDiscussionTopic *)groupDiscussionTopic onFailure:(RouteToGroupDiscussionFailureBlock)failureBlock
{
    unsigned long long courseIdent = self.contextInfo.ident;
    unsigned long long groupCategoryID = groupDiscussionTopic.groupCategoryID;
    __block BOOL foundGroupTopic = NO;
    __block BOOL matchingGroup = NO;
    __block BOOL lastGroup = NO;
    
    FetchAllDiscussions discussionTopics = ^(NSArray *allDiscussionTopics, unsigned long long assignmentIdent) {
        if (allDiscussionTopics.count == 1) {
            self.contextInfo = ((CKDiscussionTopic *)allDiscussionTopics[0]).contextInfo;
            self.topicIdent = ((CKDiscussionTopic *)allDiscussionTopics[0]).ident;
            self.topic = allDiscussionTopics[0];
            foundGroupTopic = YES;
        } else {
            for (CKDiscussionTopic *topic in allDiscussionTopics) {
                if (topic.assignmentIdent && topic.assignmentIdent == assignmentIdent) {
                    self.contextInfo = topic.contextInfo;
                    self.topicIdent = topic.ident;
                    self.topic = topic;
                    foundGroupTopic = YES;
                }
            }
        }
        
        if (!foundGroupTopic && lastGroup){
            failureBlock();
        }
    };
    
    FetchAll groups = ^(NSArray *allGroups) {
        NSUInteger count = 0;
        lastGroup = count == [allGroups count] ?: NO;
        
        for (CKGroup *group in allGroups) {
            count++;
            lastGroup = count == [allGroups count] ?: NO;
            
            if (group.contextType == CKContextTypeCourse && group.contextIdent == courseIdent && group.groupCategoryIdent == groupCategoryID) {
                matchingGroup = YES;
                CKContextInfo *groupContext = [CKContextInfo contextInfoFromGroup:group];
                [self fetchAllDiscussionTopics:discussionTopics group:groupContext topic:groupDiscussionTopic];
            }
        }
        
        if (!foundGroupTopic && !matchingGroup && lastGroup) {
            failureBlock();
        }
    };
    
    [self fetchAllGroupsForCurrentUser:groups];
}

- (void)fetchAllGroupsForCurrentUser:(void (^)(NSArray *allGroups))allGroupsCallback
{
    NSMutableArray *allGroups = [NSMutableArray array];
    
    __block __weak CKPagedArrayBlock recursiveReference;
    CKPagedArrayBlock callback = ^(NSError *error, NSArray *theArray, CKPaginationInfo *pagination) {
        [allGroups addObjectsFromArray:theArray];
        if (pagination.nextPage != nil) {
            [self.canvasAPI getGroupsWithPageURL:pagination.nextPage isCourseAffiliated:YES block:recursiveReference];
        } else {
            if (allGroupsCallback) {
                allGroupsCallback(allGroups);
            }
        }
    };
    recursiveReference = callback;
    
    [self.canvasAPI getGroupsWithPageURL:nil isCourseAffiliated:YES block:callback];
}

- (void)fetchAllDiscussionTopics:(void (^)(NSArray *allDiscussionTopics, unsigned long long assignmentID))allDiscussionTopicsCallback group:(CKContextInfo *)groupContext topic:(CKDiscussionTopic *)topic
{
    NSMutableArray *allDiscussionTopics = [NSMutableArray array];
    
    __block __weak CKPagedArrayBlock recursiveReference;
    CKPagedArrayBlock callback = ^(NSError *error, NSArray *theArray, CKPaginationInfo *pagination) {
        [allDiscussionTopics addObjectsFromArray:theArray];
        if (pagination.nextPage != nil) {
            [self.canvasAPI getDiscussionTopicsForContext:groupContext pageURL:pagination.nextPage announcementsOnly:NO searchTerm:topic.title block:recursiveReference];
        } else {
            if (allDiscussionTopicsCallback) {
                allDiscussionTopicsCallback(allDiscussionTopics, topic.assignmentIdent);
            }
        }
    };
    recursiveReference = callback;
    
    [self.canvasAPI getDiscussionTopicsForContext:groupContext pageURL:nil announcementsOnly:NO searchTerm:topic.title block:recursiveReference];
}

- (void)fetchTopicData {
    if (!_topic) {
        [self.tableView reloadData];
        _isFetchingTopic = NO;
        return;
    }
    [self calculateCellHeights];
    CKDiscussionTopic *topicForFetch = _topic;
    __weak ThreadedDiscussionViewController *weakSelf = self;
    if (_topic.discussionEntries == nil) {
        [_canvasAPI getDiscussionTreeForTopic:topicForFetch block:^(NSError *error, BOOL isFinalValue, NSArray *entries) {
            ThreadedDiscussionViewController *localSelf = weakSelf;
            if (error) {
                if (topicForFetch.requiresInitialPost && error.code == 403) {
                    requiresPostBeforeLoading = YES;
                    self.showsRepliesHiddenRow = YES;
                    [localSelf updateDisplayIfNeeded];
                }
                else {
                    [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
                }
            }
            else {
                NSArray<CKDiscussionEntry *> *delayedAddedEntries = [self.addedEntries filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CKDiscussionEntry*  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return ![entries containsObject:evaluatedObject];
                }]];
                topicForFetch.discussionEntries = [entries arrayByAddingObjectsFromArray:delayedAddedEntries];

                if (localSelf && topicForFetch == localSelf->_topic) {
                    [localSelf calculateCellHeights];
                    [localSelf updateDisplayIfNeeded];
                }
            }
        }];
    }
    
    if (self.topic.assignment) {
        self.assignment = self.topic.assignment;
    } else if (self.topic.assignmentIdent != 0 && self.contextInfo.contextType == CKContextTypeCourse) {
        [self.canvasAPI getAssignmentForContext:self.contextInfo assignmentIdent:self.topic.assignmentIdent block:^(NSError *error, CKAssignment *assignment) {
            if (error) {
                NSLog(@"Error getting assignment for threaded discussion topic header: %@", [error localizedDescription] );
            }
            self.topic.assignment = self.assignment = assignment;
            DiscussionEntryCell *entryCell = (DiscussionEntryCell *)[self.tableView cellForRowAtIndexPath:rootEntryIndexPath()];
            [entryCell updateHeader];
        }];
    } else {
        self.assignment = nil;
    }
    _isFetchingTopic = NO;
}

- (void)recordHeight:(CGFloat)height forRoot:(id)root indexPath:(NSIndexPath *)indexPath orientation:(UIInterfaceOrientation)orientation {
    if (root != [self rootEntry]) {
        return;
    }
    
    CellHeights *currentHeights = [cellHeightsStack lastObject];
    NSMutableDictionary *cellHeights = UIInterfaceOrientationIsPortrait(orientation) ? currentHeights.portraitCellHeights : currentHeights.landscapeCellHeights;
    
    cellHeights[indexPath] = @(height);
    
    if (orientation != currentOrientation) {
        // We still want to record the height for future use, but don't need
        // want to schedule any insertions
        return;
    }
    
    [self updateDisplayIfNeeded];
}

- (void)updateDisplayIfNeeded {

    UITableView *tableView = self.tableView;
    
    if ([self hasHeightForRootEntry]) {
        [tableView beginUpdates];
        
        BOOL didInsertRoot = NO;
        if ([tableView numberOfRowsInSection:MainSection] == 0) {
            [tableView insertRowsAtIndexPaths:@[rootEntryIndexPath()]
                             withRowAnimation:UITableViewRowAnimationFade];
            didInsertRoot = YES;
        }
        
        if ([self hasHeightsForAllEntries]) {
            // We have enough info to insert everything
            
            NSUInteger numberOfCurrentRows = [tableView numberOfRowsInSection:MainSection];
            if (didInsertRoot) {
                numberOfCurrentRows += 1;
            }
            NSUInteger numberOfExpectedRows = self.childEntries.count + 1;
            if (numberOfCurrentRows < numberOfExpectedRows) {
                NSUInteger numberOfRowsToInsert = numberOfExpectedRows - numberOfCurrentRows;
                NSArray *rowsToInsert = indexPathsForRangeInSection(NSMakeRange(numberOfCurrentRows, numberOfRowsToInsert), MainSection);
                [tableView insertRowsAtIndexPaths:rowsToInsert
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
            
            if (!exclusiveVisibleRow && !self.topic.isLocked) {
                self.showsReplyRow = YES;
            }
            else {
                self.showsReplyRow = NO;
            }
            self.showLoadingRow = NO;
            
        }
        else {
            // We're still waiting for children
            if (requiresPostBeforeLoading) {
                self.showsReplyRow = YES;
                self.showLoadingRow = NO;
            }
            else {
                self.showLoadingRow = YES;
                self.showsReplyRow = NO;
            }
        }
        [tableView endUpdates];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    BOOL hasOldRoot = [self hasHeightForRootEntry];
    BOOL hasNewRoot = [self hasHeightForRootEntryInOrientation:toInterfaceOrientation];
    
    BOOL hasOldChildren = [self hasHeightsForAllEntries];
    BOOL hasNewChildren = [self hasHeightsForAllEntriesInOrientation:toInterfaceOrientation];
    
    currentOrientation = toInterfaceOrientation;
    
    UITableView *tableView = self.tableView;
    [tableView in_updateWithBlock:^{
        if (hasOldRoot && !hasNewRoot) {
            [tableView deleteRowsAtIndexPaths:@[rootEntryIndexPath()]
                             withRowAnimation:UITableViewRowAnimationFade];
        }
        
        NSArray *childIndexPaths = indexPathsForRangeInSection(NSMakeRange(1, self.childEntries.count), MainSection);
        if (hasOldChildren && !hasNewChildren) {
            [tableView deleteRowsAtIndexPaths:childIndexPaths
                             withRowAnimation:UITableViewRowAnimationFade];
        }
        
        // New rows that need inserting will be done here.
        [self updateDisplayIfNeeded];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self calculateCellHeights];
}

- (void)setTopic:(CKDiscussionTopic *)topic {
    NSAssert(_canvasAPI != nil, @"You must set canvasAPI before calling setTopic:");
    self.showGoBackRow = NO;
    self.showLoadingRow = NO;
    self.showsReplyRow = NO;
    self.showsInputView = NO;
    
    [queue cancelOutstandingHeightCalculationRequests];
    queue = [DiscussionEntryHeightCalculationQueue new];
    _topic = topic;
    _topicIdent = topic.ident;
    _contextInfo = topic.contextInfo;
    
    NSString *moduleName = self.topic.contentLock.moduleName;
    if (_topic.contentLock) {
        //Update right bar button item to locked & change message
        [self updateReplyButtonImage];
    }
    
    
    if ((moduleName && [moduleName class] != [NSNull class])|| _topic.contentLock.unlockDate) {
        //handle locked modules with the LockedContentViewController
        [self displayContentLock];
    }
    
    [self setEntry:nil];
    [self resetCellHeights];
    [self fetchTopicData];
    
    [self.tableView reloadData];
    self.title = topic.title;
}

- (void)displayContentLock {
    ContentLockViewController *contentLockVC = [[ContentLockViewController alloc] initWithContentLock:self.topic.contentLock
                                                                                             itemName:self.topic.title
                                                                                            inContext:self.contextInfo];
    
    [contentLockVC lockViewController:self];
}

- (NSNotificationCenter *)notificationCenter
{
    if (!_notificationCenter) {
        _notificationCenter = [NSNotificationCenter defaultCenter];
    }
    return _notificationCenter;
}

NSIndexPath *rootEntryIndexPath() {
    return [NSIndexPath indexPathForRow:0 inSection:MainSection];
}

- (BOOL)hasHeightForRootEntryInOrientation:(UIInterfaceOrientation)orientation {
    return [self cellHeightsForOrientation:orientation][rootEntryIndexPath()] != nil;
}

- (BOOL)hasHeightsForAllEntriesInOrientation:(UIInterfaceOrientation)orientation {
    if ([self childEntries] == nil) {
        return NO;
    }
    NSUInteger count = [self cellHeightsForOrientation:orientation].count;
    
    return (count == self.childEntries.count + 1);
}

- (BOOL)hasHeightForRootEntry {
    return [self hasHeightForRootEntryInOrientation:currentOrientation];
}

- (BOOL)hasHeightsForAllEntries {
    return [self hasHeightsForAllEntriesInOrientation:currentOrientation];
}

- (void)setShowLoadingRow:(BOOL)showLoadingRow {
    if (showLoadingRow == _isShowingLoadingRow) {
        return;
    }
    
    _isShowingLoadingRow = showLoadingRow;
    
    NSIndexPath *loadingRow = [NSIndexPath indexPathForRow:0 inSection:LoadingSection];
    if (showLoadingRow) {
        [self.tableView insertRowsAtIndexPaths:@[loadingRow] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[loadingRow] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)setShowGoBackRow:(BOOL)showGoBackRow {
    if (showGoBackRow == _isShowingGoBackRow) {
        return;
    }
    [self.tableView beginUpdates];
    _isShowingGoBackRow = showGoBackRow;
    NSIndexPath *goBackRow = [NSIndexPath indexPathForRow:0 inSection:GoBackSection];
    if (showGoBackRow) {
        [self.tableView insertRowsAtIndexPaths:@[goBackRow] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[goBackRow] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

- (void)setShowsRepliesHiddenRow:(BOOL)showsRepliesHiddenRow {
    if (showsRepliesHiddenRow == _isShowingRepliesHiddenRow) {
        return;
    }
    _isShowingRepliesHiddenRow = showsRepliesHiddenRow;
    
    NSIndexPath *repliesHiddenRow = [NSIndexPath indexPathForRow:0 inSection:RepliesHiddenSection];
    if (showsRepliesHiddenRow) {
        [self.tableView insertRowsAtIndexPaths:@[repliesHiddenRow] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[repliesHiddenRow] withRowAnimation:UITableViewRowAnimationFade];
    }
}



- (void)setShowsInputView:(BOOL)showsInputView {
    if (showsInputView == _isShowingInputView) {
        return;
    }
    
    _isShowingInputView = showsInputView;
    
    if (showsInputView) {
        overlayView = [[UIView alloc] initWithFrame:self.tableView.bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInputView)];
        [overlayView addGestureRecognizer:tapRecognizer];
        [self.tableView addSubview:overlayView];

        
        CGFloat inputViewHeight = 60;
        CGRect startingInputFrame = CGRectMake(0, CGRectGetMaxY(overlayView.bounds), overlayView.bounds.size.width, inputViewHeight);
        CGRect finalInputFrame = startingInputFrame;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            finalInputFrame.origin.y -= (inputViewHeight + self.tabBarController.tabBar.bounds.size.height);
        } else {
            finalInputFrame.origin.y -= inputViewHeight;
        }

        inputView = [[CKRichTextInputView alloc] initWithFrame:startingInputFrame];
        [inputView setShowsAttachmentButton:NO];
        inputView.minimumHeight = inputViewHeight;
        inputView.attachmentSheetTitle = NSLocalizedString(@"Add inline media", @"Title on the add-inline-media sheet");
        inputView.attachmentButtonImage = [UIImage techDebtImageNamed:@"icon_camera_fill"];
        inputView.delegate = self;
        [inputView becomeFirstResponder];
        
        [inputView setShowsAttachmentButton:NO];
        [overlayView addSubview:inputView];
        
        [self.canvasAPI getMediaServerConfigurationWithBlock:^(NSError *error, BOOL isFinalValue) {
            if (self.canvasAPI.mediaServer.enabled) {
                [inputView setShowsAttachmentButton:YES];
            }
        }];

        [UIView animateWithDuration:0.25 animations:^{
            overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
            inputView.frame = finalInputFrame;
        }];
        CGFloat progressHeight = [CKUploadProgressToolbar preferredHeight];
        CGRect progressFrame = CGRectMake(0, 0, inputView.frame.size.width, progressHeight);
        progressToolbar = [[CKUploadProgressToolbar alloc] initWithFrame:progressFrame];
        progressToolbar.uploadCompleteText = NSLocalizedString(@"Entry posted", @"Confirmation message after posting a discussion entry");
        progressToolbar.uploadInProgressText = NSLocalizedString(@"Posting…", @"Message shown while posting a discussion entry");
        [self repositionProgressViewAboveInputView];
        [overlayView addSubview:progressToolbar];
        
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.bottom = inputViewHeight + progressHeight;
        
        self.tableView.contentInset = insets;
        insets.bottom = inputViewHeight;
        self.tableView.scrollIndicatorInsets = insets;
        
        [self startObservingKeyboard];
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, inputView.webView);
    } else {
        [inputView dismissKeyboard];
        
        [progressToolbar hideMessageWithCompletionBlock:NULL];
        CGRect destInputFrame = inputView.frame;
        destInputFrame.origin.y += destInputFrame.size.height;
        [UIView animateWithDuration:0.25 animations:^{
            overlayView.alpha = 0.0;
            inputView.frame = destInputFrame;
            UIEdgeInsets insets = self.tableView.contentInset;
            insets.bottom = self.tabBarController.tabBar.bounds.size.height;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                insets.bottom = 0;
            }
            self.tableView.contentInset = self.tableView.scrollIndicatorInsets = insets;
        }
         completion:^(BOOL finished) {
             [self stopObservingKeyboard];
             [overlayView removeFromSuperview];
             overlayView = nil;
             [progressToolbar removeFromSuperview];
             progressToolbar = nil;
             [inputView removeFromSuperview];
             inputView = nil;
         }];
        
    }
}

- (BOOL)accessibilityPerformEscape {
    if (self.showsInputView) {
        [self dismissInputView];
        return YES;
    }
    return NO;
}

- (void)startObservingKeyboard {
    [self.notificationCenter addObserver:self selector:@selector(repositionInputViewWithKeyboardNote:) name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(repositionInputViewWithKeyboardNote:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)stopObservingKeyboard {
    [self.notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dismissInputView {
    if (!inputView.isEmpty) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unsaved Reply", nil) message:NSLocalizedString(@"You have an unsaved reply. Would you like to discard that reply?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"No", nil), nil];
        alert.tag = kUnsavedReplyAlertTag;
        [alert show];
    } else {
        [self actuallyDismissInputView];
    }
}

- (void)actuallyDismissInputView {
    self.showsInputView = NO;
    [self updateDisplayIfNeeded];
}

- (void)keyboardDidHide:(NSNotification *)note
{
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setScrollIndicatorInsets:self.tableView.contentInset];
}

- (void)repositionInputViewWithKeyboardNote:(NSNotification *)note {
    NSDictionary *info = [note userInfo];
    
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [info[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect endFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    endFrame = [overlayView convertRect:endFrame fromView:nil];
    
    CGFloat topOfKeyboard = CGRectGetMinY(endFrame);
    CGFloat bottomOfView = CGRectGetMaxY(self.view.bounds);
    CGFloat destBottomOfInputView = topOfKeyboard;
    if (topOfKeyboard > bottomOfView) {
        destBottomOfInputView = bottomOfView;
    }
    
    CGFloat destTopOfInputView = destBottomOfInputView - inputView.frame.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];

        CGRect newFrame = inputView.frame;
        newFrame.origin.y = destTopOfInputView;
        inputView.frame = newFrame;

        [self repositionProgressViewAboveInputView];
    }];

}

- (void)repositionProgressViewAboveInputView {
    if (inputView == nil) {
        return;
    }
    CGRect inputFrame = inputView.frame;
    CGFloat progressHeight = [CKUploadProgressToolbar preferredHeight];
    CGRect progressFrame = CGRectMake(inputFrame.origin.x, inputFrame.origin.y - progressHeight, inputFrame.size.width, progressHeight);
    progressToolbar.frame = progressFrame;
    
    CGFloat bottomOfView = CGRectGetMaxY(overlayView.bounds);
    CGFloat topOfProgressView = CGRectGetMinY(progressFrame);
    CGFloat insetAmount = bottomOfView - topOfProgressView;
    if (insetAmount < 0) {
        insetAmount = 0;
    }
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = insetAmount;
    
    self.tableView.contentInset = insets;
    insets.bottom = insets.bottom - progressHeight;
    self.tableView.scrollIndicatorInsets = insets;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kUnsavedReplyAlertTag && buttonIndex == 0) {
        [self actuallyDismissInputView];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger count = NumberOfSections;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == GoBackSection) {
        return _isShowingGoBackRow ? 1 : 0;
    }
    
    else if (section == MainSection) {
        if ([self hasHeightsForAllEntries]) {
            return [self.cellHeights count];
        }
        else if ([self hasHeightForRootEntry]) {
            return 1;
        }
        else {
            return 0;
        }
    }
    else if (section == RepliesHiddenSection) {
        return _isShowingRepliesHiddenRow ? 1 : 0;
    }
    else if (section == LoadingSection) {
        return _isShowingLoadingRow ? 1 : 0;
    }
    return 0;
}

- (id)rootEntry {
    return _entry ?: _topic;
}

- (NSArray *)childEntries {
    NSArray *entries = _entry ? _entry.replies : _topic.discussionEntries;
    return entries;
}

CKDiscussionEntry *asEntry(id entryOrTopic) {
    if ([entryOrTopic isKindOfClass:[CKDiscussionEntry class]]) {
        return entryOrTopic;
    }
    CKDiscussionTopic *topic = entryOrTopic;
    CKDiscussionEntry *dummyEntry = [CKDiscussionEntry new];
    dummyEntry.discussionTopic = topic;
    dummyEntry.entryMessage = topic.message;
    dummyEntry.createdAt = topic.postDate;
    dummyEntry.userName = topic.title;
    dummyEntry.replies = topic.discussionEntries;
    dummyEntry.ident = topic.ident;
    [dummyEntry.attachments addEntriesFromDictionary:topic.attachments];
    return dummyEntry;
}

- (NSIndexPath *)indexPathForItem:(id)item {
    id root = [self rootEntry];
    
    if (item == root) {
        return rootEntryIndexPath();
    }
    NSArray *entries = [self childEntries];
    NSUInteger row = [entries indexOfObjectIdenticalTo:item] + 1;
    return [NSIndexPath indexPathForRow:row inSection:MainSection];
    
}

- (id)itemForIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath.section == MainSection);
    id root = [self rootEntry];
    if (indexPath.row == 0) {
        return root;
    }
    
    NSUInteger childIndex = indexPath.row - 1;
    NSArray *entries = [self childEntries];
    CKDiscussionEntry *entry = entries[childIndex];
    return entry;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == GoBackSection) {
        if (_isShowingGoBackRow) {
            return 44;
        } else {
            return 0;
        }
    }
    if (indexPath.section == MainSection) {
        NSDictionary *cellHeights = self.cellHeights;
        NSNumber *num = cellHeights[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        if (num) {
            if(!self.topic.allowRating && (indexPath.row > 0 || self.showGoBackRow)) {
                num = @([num floatValue] - 40.0);
            }
            return [num floatValue];
        }
        else {
            return tableView.rowHeight;
        }
    }
    else {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == GoBackSection) {
        // This one should show up even when 'exclusiveVisibleRow' is set
        cell = [tableView dequeueReusableCellWithIdentifier:@"GoBackCell"];
    }
    else if (indexPath.section == LoadingSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
    }
    else if (exclusiveVisibleRow && [indexPath isEqual:exclusiveVisibleRow] == NO) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SpacerCell"];
    }
    else if (indexPath.section == MainSection) {        
        CKDiscussionEntry *entry = asEntry([self itemForIndexPath:indexPath]);
        NSString *identifier = [DiscussionEntryCell reuseIdentifierForItem:entry];
        DiscussionEntryCell *entryCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        
        // Configure the cell...
        entryCell.course = self.course;
        entryCell.topic = self.topic;
        entryCell.entry = entry;
        entryCell.delegate = self;
        
        ShortPressGestureRecognizer *shortRecognizer = [entryCell.gestureRecognizers in_firstObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isKindOfClass:[ShortPressGestureRecognizer class]];
        }];
        
        if (!shortRecognizer) {
            shortRecognizer = [[ShortPressGestureRecognizer alloc] initWithTarget:self action:@selector(shortPressUpdated:)];
            shortRecognizer.delegate = self;
            [entryCell addGestureRecognizer:shortRecognizer];
        }
        
        if (!entryCell.longPressRecognizer) {
            UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [longRecognizer requireGestureRecognizerToFail:shortRecognizer];
            [entryCell addGestureRecognizer:longRecognizer];
            longRecognizer.delegate = self;
            entryCell.longPressRecognizer = longRecognizer;
        }
        
        entryCell.showsHighlightOnTouch = [self shouldZoomIntoEntry:asEntry(entry)];
        entryCell.longPressRecognizer.enabled = !entry.isDeleted;
        entryCell.childCountIndicator.alpha = 1.0;
        
        if ([indexPath isEqual:rootEntryIndexPath()]) {
            entryCell.childCountIndicator.alpha = 0.0;
            if (_entry == nil) {
                // This is the topic
                entryCell.longPressRecognizer.enabled = NO;
            }
        }
        
        cell = entryCell;
    }
    else if (indexPath.section == RepliesHiddenSection) {
        DiscussionEntryCell *entryCell = [tableView dequeueReusableCellWithIdentifier:@"DiscussionReplyRequiredCell"];
        entryCell.showsHighlightOnTouch = NO;
        cell = entryCell;
    }
    
    return cell;
 }

#pragma mark - gesture handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[ShortPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:gestureRecognizer.view];
    UIView *view = [gestureRecognizer.view hitTest:point withEvent:nil];
    
    if ([[UIMenuController sharedMenuController] isMenuVisible]) {
        return NO;
    }
    
    if ([self.tableView isDecelerating]) {
        return NO;
    }
    
    if ([view isKindOfClass:[UIButton class]]) {
        // Allow for touching buttons to start movies, etc.
        return NO;
    }
    
    DiscussionEntryCell *cell = (DiscussionEntryCell *)gestureRecognizer.view;
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [view isDescendantOfView:cell.contentWebView]) {
        return YES;
    }
    return YES;
}

- (void)shortPressUpdated:(UIGestureRecognizer *)recognizer {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) {
        [menuController setMenuVisible:NO animated:YES];
        [self resignFirstResponder];
    }
    
    UITableViewCell *cell = (id)recognizer.view;
    tappedIndexPath = [self.tableView indexPathForCell:cell];
    
    if (tappedIndexPath.row == 0) {
        // Don't highlight the root cell; it's already selected.
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        cell.highlighted = YES;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:path];
    }
    else {
        cell.highlighted = NO;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if ([self userHasPermissionToEditAndDeleteRowAtIndexPath:tappedIndexPath]) {
        if ([recognizer state] == UIGestureRecognizerStateBegan) {
            isShowingMenuToEditDeleteEntry = YES;
            [self becomeFirstResponder];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:tappedIndexPath];
            
            UIMenuController *editMenu = [UIMenuController sharedMenuController];
            UIMenuItem *editItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Button to edit a discussion entry")
                                                              action:@selector(editEntry:)];
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"Delete Button title")
                                                                action:@selector(deleteEntry:)];
            editMenu.menuItems = @[ editItem, deleteItem ];
            [editMenu setTargetRect:cell.frame inView:self.tableView];
            [editMenu setArrowDirection:UIMenuControllerArrowDown];
            [editMenu setMenuVisible:YES animated:YES];
        }
    }
}

- (BOOL)userHasPermissionToEditAndDeleteRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.contextInfo.contextType == CKContextTypeCourse) {
        if ([self.course loggedInUserHasEnrollmentOfType:CKEnrollmentTypeTeacher] ||
            [self.course loggedInUserHasEnrollmentOfType:CKEnrollmentTypeTA]) {
            return YES;
        }
    }
    
    CKDiscussionEntry *entry = [self itemForIndexPath:indexPath];
    CKUser *user = _canvasAPI.user;
    if (entry.userIdent == user.ident) {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)willHideEditMenu:(id)sender
{
    isShowingMenuToEditDeleteEntry = NO;
    isInProcessOfHidingMenuToEditDeleteEntry = YES;
}

- (void)didHideEditMenu:(id)sender {
    isInProcessOfHidingMenuToEditDeleteEntry = NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (isShowingMenuToEditDeleteEntry) {
        if (action == @selector(editEntry:) || action == @selector(deleteEntry:)) {
            return YES;
        }
    }
    else {
        return NO;
    }
    return NO;
}

- (void)editEntry:(id)sender
{
    [self.tableView beginUpdates];
    self.showsReplyRow = NO;
    self.showsInputView = YES;
    
    isEditingEntry = YES;
    
    __weak CKUploadProgressToolbar *weakProgressToolbar = progressToolbar;
    __weak CKRichTextInputView *weakInputView = inputView;
    CKDiscussionEntry *entry = [self itemForIndexPath:tappedIndexPath];
    inputView.finishedLoadingWebViewBlock = ^{
        weakInputView.initialText = [weakInputView replaceImagesWithThumbnailsInHTML:entry.entryMessage];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.doesRelativeDateFormatting = YES;
        NSString *dateText = [formatter stringFromDate:entry.createdAt];
        
        NSString *baseString = NSLocalizedString(@"Editing reply by %@, %@", @"Header when editing a discussion entry with name and timestamp");
        [weakProgressToolbar showMessage:[NSString stringWithFormat:baseString, entry.userName, dateText]];
    };
    [self.tableView endUpdates];
}

- (void)deleteEntry:(id)sender
{
    CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:NSLocalizedString(@"Confirm deletion", @"Alert title") message:NSLocalizedString(@"Delete this reply?", @"Alert message")];
    [alert addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button title")];
    [alert addButtonWithTitle:NSLocalizedString(@"Delete", @"Delete Button title") handler:^{
        CKDiscussionEntry *entry = [self itemForIndexPath:tappedIndexPath];
        
        [_canvasAPI deleteDiscussionEntry:entry block:^(NSError *error, BOOL isFinalValue) {
            if (error) {
                NSLog(@"Unable to delete discussion entry. Error message: %@", error);
                
                CKAlertViewWithBlocks *errorAlert = [[CKAlertViewWithBlocks alloc] initWithTitle:NSLocalizedString(@"Error", @"Title for an error popup") message:NSLocalizedString(@"You do not have permission to delete this reply", @"Error message")];
                [errorAlert addCancelButtonWithTitle:NSLocalizedString(@"OK", nil)];
                [errorAlert show];
            }
            else {
                
                if ([[self rootEntry] isEqual:entry]) {
                    [self zoomOut];
                }
                entry.deleted = YES;
                id root = [self rootEntry];
                
                __weak ThreadedDiscussionViewController *weakSelf = self;
                NSIndexPath *reloadingIndexPath = [self indexPathForItem:entry];
                UIInterfaceOrientation orientation = currentOrientation;
                
                NSMutableDictionary *oppositeCellHeights = [self cellHeightsForOrientationOppositeOrientation:orientation];
                [oppositeCellHeights removeObjectForKey:reloadingIndexPath];
                
                [queue calculateCellHeightForEntry:entry inTableView:self.tableView withIndentationLevel:(int)[self tableView:self.tableView indentationLevelForRowAtIndexPath:reloadingIndexPath] handler:^(CGFloat height) {
                    [weakSelf recordHeight:height forRoot:root indexPath:reloadingIndexPath orientation:orientation];
                    if ([[weakSelf rootEntry] isEqual:root]) {
                     [weakSelf.tableView reloadRowsAtIndexPaths:@[ reloadingIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }];
            }
        }];
    }];
    [alert show];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == MainSection) {
        return 0;
    }
    return 1;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MainSection) {
        CKDiscussionEntry *entry = asEntry([self itemForIndexPath:indexPath]);
        DiscussionEntryCell *entryCell = (id)cell;
        
        if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
            self.isLoaded = YES;
        }
        
        if ([entryCell isKindOfClass:[DiscussionEntryCell class]] == NO) {
            return;
        }
        if (entry.unread) {
            
            [entryCell whenVisibleForDuration:3.0 doBlock:^{
                entry.unread = NO;
                
                [entryCell updateUnreadIndicatorsAnimated:YES];
                [[UIApplication sharedApplication] sendAction:@selector(discussionUnreadCountChanged) to:nil from:self forEvent:nil];
                
                [_canvasAPI markDiscussionEntryRead:entry block:^(NSError *error, BOOL isFinalValue) {
                    if (error) {
                        entry.unread = YES;
                        [entryCell updateUnreadIndicatorsAnimated:YES];
                        [[UIApplication sharedApplication] sendAction:@selector(discussionUnreadCountChanged) to:nil from:self forEvent:nil];
                    } else if(isFinalValue) {
                        if (![_entryIDHasBeenMarkedRead[@(entry.ident)] boolValue]) {
                            _entryIDHasBeenMarkedRead[@(entry.ident)] = @(YES);
                            self.viewModel.model.unreadCount--;
                        }
                    }
                }];
                
                if ([[tableView indexPathsForVisibleRows] containsObject:rootEntryIndexPath()]) {
                    DiscussionEntryCell *rootEntry = (id)[tableView cellForRowAtIndexPath:rootEntryIndexPath()];
                    [rootEntry updateUnreadIndicatorsAnimated:NO];
                }
            }];
        }
    }
}

- (BOOL)shouldZoomIntoEntry:(CKDiscussionEntry *)entry {
    BOOL allowed = YES;
    if (entry.allowsReplies == NO && entry.replies.count == 0) {
        allowed = NO;
    }
    return allowed;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIMenuController sharedMenuController] isMenuVisible] || isInProcessOfHidingMenuToEditDeleteEntry) {
        return nil;
    }
    return indexPath;
}

- (void)zoomOut
{
    UITableView *tableView = self.tableView;
    
    NSUInteger currentRowCount = [self tableView:tableView numberOfRowsInSection:MainSection];
    
    CKDiscussionEntry *currentEntry = _entry;
    DiscussionEntryCell *cell = (id)[tableView cellForRowAtIndexPath:rootEntryIndexPath()];
    _entry = currentEntry.parentEntry;
    [self popCellHeights];
    
    NSUInteger indexInParent = [[self childEntries] indexOfObject:currentEntry] + 1;
    NSUInteger newRowCount = [self tableView:tableView numberOfRowsInSection:MainSection];
    NSIndexPath *destinationRow = [NSIndexPath indexPathForRow:indexInParent inSection:MainSection];
    
    BOOL hasCellHeightInformationForParent = [self hasHeightsForAllEntries];
    
    NSMutableArray *rowsToRemove = [NSMutableArray new];
    for (int i=0; i<currentRowCount; ++i) {
        if (i == 0 && hasCellHeightInformationForParent) {
            continue;
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:MainSection];
        [rowsToRemove addObject:path];
    }
    
    NSMutableArray *rowsToAdd = [NSMutableArray new];
    if (hasCellHeightInformationForParent) {
        for (int i=0; i<newRowCount; ++i) {
            if (i == indexInParent) {
                continue;
            }
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:MainSection];
            [rowsToAdd addObject:path];
        }
        exclusiveVisibleRow = destinationRow;
    }
    
    
    [tableView beginUpdates];
    if (_entry == nil) {
        self.showGoBackRow = NO;
    }
    self.showsReplyRow = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        cell.indentationLevel = 1;
        cell.childCountIndicator.alpha = 1.0;
        [cell layoutSubviews];
    }];
    [tableView deleteRowsAtIndexPaths:rowsToRemove withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView insertRowsAtIndexPaths:rowsToAdd withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    
    [self calculateCellHeights];
    
    if (hasCellHeightInformationForParent) {
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            exclusiveVisibleRow = nil;
            
            // It's possible we rotated to something that doesn't have heights, so we need to check this again.
            if ([self hasHeightsForAllEntries]) {
                [tableView beginUpdates];
                [tableView reloadRowsAtIndexPaths:rowsToAdd withRowAnimation:UITableViewRowAnimationFade];
                [self updateDisplayIfNeeded];
                [tableView endUpdates];
            }
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
            [tableView scrollToRowAtIndexPath:destinationRow atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
    }
}

- (void)zoomIntoRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableView *tableView = self.tableView;
    
    CKDiscussionEntry *entry = [self childEntries][indexPath.row - 1];
    entry.unread = NO;
    
    DiscussionEntryCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    
    NSIndexPath *firstEntryRow = rootEntryIndexPath();
    
    
    NSMutableArray *allOtherRows = [NSMutableArray new];
    NSUInteger count = [self tableView:tableView numberOfRowsInSection:MainSection];
    for (int i=0; i<count; ++i) {
        if (i == indexPath.row) {
            continue;
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        [allOtherRows addObject:path];
    }
    
    _entry = entry;
    
    [tableView beginUpdates];
    self.showGoBackRow = YES;
    self.showsReplyRow = NO;
    [UIView animateWithDuration:0.2 animations:^{
        cell.indentationLevel = 0;
        cell.childCountIndicator.alpha = 0.0;
        // recalculate the height for zoomed in version
        cell.preferredHeightHandler = ^(CGFloat height) {
            [tableView beginUpdates];
            [self recordHeight:height forRoot:entry indexPath:firstEntryRow orientation:currentOrientation];
            [tableView endUpdates];
        };
        cell.entry = entry;
        [cell updateUnreadIndicatorsAnimated:NO];
        [cell layoutSubviews];
    }];
    [tableView deleteRowsAtIndexPaths:allOtherRows withRowAnimation:UITableViewRowAnimationFade];
    
    CGFloat rowHeight = [(self.cellHeights)[indexPath] floatValue];
    
    exclusiveVisibleRow = firstEntryRow;
    
    [self pushNewCellHeights];
    [self recordHeight:rowHeight forRoot:entry indexPath:firstEntryRow orientation:currentOrientation];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    [tableView endUpdates];
    
    [self calculateCellHeights];
    
    NSIndexPath *goBackRow = [NSIndexPath indexPathForRow:0 inSection:GoBackSection];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [tableView scrollToRowAtIndexPath:goBackRow atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        exclusiveVisibleRow = nil;
        NSUInteger numberOfRowsNow = [self tableView:tableView numberOfRowsInSection:MainSection];
        NSRange range = NSMakeRange(1, numberOfRowsNow-1);
        NSArray *pathsToReload = indexPathsForRangeInSection(range, MainSection);
        
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:pathsToReload withRowAnimation:UITableViewRowAnimationFade];
        [self updateDisplayIfNeeded];
        [tableView endUpdates];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath isEqual:rootEntryIndexPath()]) {
        return;
    }
    
    if (indexPath.section == GoBackSection) {
        DDLogVerbose(@"goBackSectionSelected");
        if (_isShowingGoBackRow == NO ) {
            return;
        }
        [self zoomOut];
    }
    
    if (indexPath.section == MainSection) {
        CKDiscussionEntry *entry = [self childEntries][indexPath.row - 1];
        DDLogVerbose(@"discussionEntrySelected : %llu", entry.ident);
        
        if ([self shouldZoomIntoEntry:entry] == NO) {
            // No point zooming in on an entry we can't reply to.
            return;
        }
        
        [self zoomIntoRowAtIndexPath:indexPath];
        
    }
}

NSArray *indexPathsForRangeInSection(NSRange range, NSInteger section) {
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i=0, row=range.location; i<range.length; ++i, ++row) {
        [array addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    return array;
}

             
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (overlayView) {
        overlayView.frame = scrollView.bounds;
    }
}

////////////////////////////////////////////////
#pragma mark - CKRichTextInputViewDelegate
////////////////////////////////////////////////

- (void)resizeRichTextInputViewToHeight:(CGFloat)height {
    CGRect inputRect = inputView.frame;
    CGFloat bottom = CGRectGetMaxY(inputRect);
    
    CGRect newRect = CGRectMake(0,
                                bottom - height,
                                inputRect.size.width,
                                height);
    inputView.frame = newRect;
    [self repositionProgressViewAboveInputView];
}

- (void)richTextView:(CKRichTextInputView *)inputView postComment:(NSString *)comment withAttachments:(NSArray *)attachments andCompletionBlock:(CKSimpleBlock)block {
    
    [progressToolbar updateProgressViewWithIndeterminateProgress];
    __weak ThreadedDiscussionViewController *weakSelf = self;
    __weak CKUploadProgressToolbar *weakProgressToolbar = progressToolbar;
    
    if (isEditingEntry) {
        CKDiscussionEntry *theEntry = [self itemForIndexPath:tappedIndexPath];
        [self.canvasAPI editDiscussionEntry:theEntry newText:comment withAttachments:attachments block:^(NSError *error, CKDiscussionEntry *entry) {
            if (error) {
                [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
                if (block) {
                    block(error, YES);
                }
            }
            else {
                [weakProgressToolbar transitionToUploadCompletedWithError:error
                                                               completion:^{
                                                                   weakSelf.showsInputView = NO;
                                                               }];
                ThreadedDiscussionViewController *strongSelf = weakSelf;
                if (strongSelf) {
                    theEntry.entryMessage = entry.entryMessage;
                    [strongSelf->inputView clearContents];
                    [strongSelf repositionProgressViewAboveInputView];
                    [self reloadCellAtIndexPath:tappedIndexPath];
                }
            }
            isEditingEntry = NO;
        }];
    }
    else if (_entry) {
        CKDiscussionEntry *theEntry = _entry;
        CKDiscussionTopic *topic = _topic;
        [self.canvasAPI postReply:comment withAttachments:attachments toDiscussionEntry:theEntry inTopic:_topic
                            block:^(NSError *error, CKDiscussionEntry *newEntry) {

                                [weakProgressToolbar transitionToUploadCompletedWithError:error
                                                                               completion:
                                 ^{
                                     if (error == nil) {
                                         weakSelf.showsInputView = NO;
                                     }
                                 }];
                                
                                if (error) {
                                    [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
                                    if (block) {
                                        block(error, YES);
                                    }
                                }
                                else {
                                    NSArray *currentReplies = theEntry.replies;
                                    newEntry.parentEntry = theEntry;
                                    theEntry.replies = [currentReplies arrayByAddingObject:newEntry];

                                    ThreadedDiscussionViewController *strongSelf = weakSelf;
                                    if (strongSelf) {
                                        [strongSelf->inputView clearContents];
                                        [strongSelf repositionProgressViewAboveInputView];
                                        [strongSelf calculateCellHeights];
                                    }
                                }
                                
                                DDLogVerbose(@"ThreadedDiscussionViewController posting module item progress update after postReply:withAttachments:toDiscussionEntry:inTopic:");
                                CBIPostModuleItemProgressUpdate([@(topic.ident) description], CKIModuleItemCompletionRequirementMustContribute);
                                if (topic.assignmentIdent) {
                                    CBIPostModuleItemProgressUpdate([@(topic.assignmentIdent) description], CKIModuleItemCompletionRequirementMustSubmit);
                                }
                            }];
    }
    else {
        CKDiscussionTopic *topic = _topic;
        [self.canvasAPI postEntry:comment withAttachments:attachments toDiscussionTopic:topic
                            block:^(NSError *error, CKDiscussionEntry *newEntry) {
                                [weakProgressToolbar transitionToUploadCompletedWithError:error 
                                                                               completion:
                                 ^{
                                     if (error == nil) {
                                         weakSelf.showsInputView = NO;
                                     }
                                 }];
                                
                                if (error) {
                                    [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
                                    if (block) {
                                        block(error, YES);
                                    }
                                }
                                else {
                                    newEntry.userAvatarURL = TheKeymaster.currentClient.currentUser.avatarURL;
                                    
                                    NSArray *currentEntries = topic.discussionEntries;
                                    topic.discussionEntries = [currentEntries arrayByAddingObject:newEntry];

                                    ThreadedDiscussionViewController *strongSelf = weakSelf;
                                    if (strongSelf) {
                                        if (strongSelf->requiresPostBeforeLoading) {
                                            strongSelf->requiresPostBeforeLoading = NO;
                                            strongSelf.showsRepliesHiddenRow = NO;
                                            [strongSelf.addedEntries addObject:newEntry];
                                            topic.discussionEntries = nil;
                                            [strongSelf fetchTopicData];
                                        }
                                        else {
                                            [strongSelf calculateCellHeights];
                                        }
                                        [strongSelf->inputView clearContents];
                                        [strongSelf repositionProgressViewAboveInputView];
                                    }
                                    
                                    CBIPostModuleItemProgressUpdate([@(topic.ident) description], CKIModuleItemCompletionRequirementMustContribute);
                                    if (topic.assignmentIdent) {
                                        CBIPostModuleItemProgressUpdate([@(topic.assignmentIdent) description], CKIModuleItemCompletionRequirementMustSubmit);
                                    }
                                }
                            }];
    }
}

////////////////////////////////////////
#pragma mark - DiscussionEntryCellDelegate
////////////////////////////////////////

- (void)entryCell:(DiscussionEntryCell *)cell requestsOpenURL:(NSURL *)url {
    [[Router sharedRouter] routeFromController:self toURL:url];
}

- (void)entryCell:(DiscussionEntryCell *)cell requestLikeEntry:(BOOL)like completion:(void(^)(NSError*))completion {
    [self.canvasAPI rateEntry:cell.entry like:like block:^(NSError *error, BOOL isFinalValue) {
        if (error) {
            completion(error);
        } else if (isFinalValue) {
            cell.entry.isLiked = like;
            cell.entry.likeCount += like ? 1 : -1;
            completion(nil);
        }
    }];
}

@end
