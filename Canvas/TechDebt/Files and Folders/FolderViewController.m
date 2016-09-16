//
//  FolderViewController.m
//  iCanvas
//
//  Created by BJ Homer on 7/13/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit1/CKActionSheetWithBlocks.h>
#import <CanvasKit1/CKAlertViewWithBlocks.h>
#import <CanvasKit1/CKActionSheetWithBlocks.h>
#import <CanvasKit1/CKUploadProgressToolbar.h>
#import <CanvasKit1/NSArray+CKAdditions.h>
#import <CanvasKit1/CKByteCountFormatter.h>
#import "UIViewController+AnalyticsTracking.h"

#import "FolderViewController.h"
#import "RatingsController.h"
#import "FileViewController.h"
#import "ProgressTableViewCell.h"
#import <Reachability/Reachability.h>
#import "ReceivedFilesViewController.h"
#import "UITableView+in_updateInBlocks.h"
#import "WebBrowserViewController.h"
#import "Analytics.h"
#import "iCanvasErrorHandler.h"
#import "CBILog.h"
#import "UIImage+TechDebt.h"

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface FolderSelectionTracker : NSObject
@property CKAttachment *selectedFile;
@end
@implementation FolderSelectionTracker
@synthesize selectedFile = _selectedFile;
@end

@interface BogusPaginationInfo : CKPaginationInfo
@end
@implementation BogusPaginationInfo
- (NSURL *)nextPage { return [NSURL URLWithString:@"nextPage://fake"]; }
@end


@interface FolderViewController ()

@property BOOL isCurrentlyDeleting;

@end

@implementation FolderViewController {
    
    NSURL *_nextFilesPage;
    NSURL *_nextFoldersPage;
    
    BOOL _hasAllFolders;
    BOOL _hasAllFiles;
    
    NSMutableArray *_pendingItems;
    
    FolderSelectionTracker *selectionTracker;
    CKUploadProgressToolbar *_progressToolbar;
    __weak CKActionSheetWithBlocks *_optionsActionSheet;
    UIBarButtonItem *_deleteItem;
}

- (id)initWithInterfaceStyle:(FolderInterfaceStyle)style {
    self = [[UIStoryboard storyboardWithName:@"CoursesTab" bundle:[NSBundle bundleForClass:[self class]]] instantiateViewControllerWithIdentifier:@"FolderViewController"];

    self.title = NSLocalizedString(@"Files", @"title for files view");
    
    NSAssert( self != nil, @"Controller creation failed. Did an identifier change?");
    _interfaceStyle = style;
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _pendingItems = [NSMutableArray new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_preservesSelection) {
        if (!selectionTracker) {
            selectionTracker = [FolderSelectionTracker new];
        }
    }
    
    _deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(tappedDeleteSelectedItems:)];
    _deleteItem.tintColor = [UIColor redColor];
    [self updateEditingSelectionCount];
    
    self.isCurrentlyDeleting = NO;
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Button to stop editing a list") style:UIBarButtonItemStyleDone target:self action:@selector(stopEditing:)];

    self.toolbarItems = @[ _deleteItem, flexSpace, doneItem ];
    
    CGFloat toolbarHeight = [CKUploadProgressToolbar preferredHeight];
    CGRect viewBounds = self.view.bounds;
    CGRect toolbarFrame = CGRectMake(0, CGRectGetMaxY(viewBounds) - toolbarHeight,
                                     viewBounds.size.width, toolbarHeight);
    _progressToolbar = [[CKUploadProgressToolbar alloc] initWithFrame:toolbarFrame];
    [self.view addSubview:_progressToolbar];
    
    UIImage *image = [UIImage techDebtImageNamed:@"icon_cog_fill"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showOptions:)];
        
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [self.tableView setScrollIndicatorInsets:self.tableView.contentInset];
}

- (void)viewWillAppear:(BOOL)animated {
    // Before the selection is lost, update the item count on the selected row.
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    [self.tableView reloadRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationNone];
    
    [super viewWillAppear:animated];
    [self updateSelectionOnTableView];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(64, 0, 0, 0)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
    [Analytics logScreenView:kGAIScreenFoldersList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.editing = NO;
    self.navigationController.toolbarHidden = YES;
    if (_optionsActionSheet) {
        NSUInteger cancelIndex = [_optionsActionSheet cancelButtonIndex];
        [_optionsActionSheet dismissWithClickedButtonIndex:cancelIndex animated:YES];
    }
}

- (void)updateSelectionOnTableView {
    if (selectionTracker.selectedFile != nil) {
        NSUInteger itemIndex = [self.items indexOfObject:selectionTracker.selectedFile];
        if (itemIndex != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:itemIndex inSection:[self defaultSectionForItems]];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)deselectCurrentSelection {
    selectionTracker.selectedFile = nil;
    [self updateSelectionOnTableView];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    if (editing == self.editing) {
        return;
    }
    
    // Only enabling this when editing==YES, so that swipe-to-delete still works when it's NO.
    // This must be set before calling `super`. Otherwise, it will think it's supposed to query
    // for editing styles, and we'll get delete boxes instead of checkmarks in editing mode.
    self.tableView.allowsMultipleSelectionDuringEditing = editing;
    
    [super setEditing:editing animated:animated];
    
    if (_interfaceStyle == FolderInterfaceStyleDark) {
        self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    }
    [self.navigationController setToolbarHidden:!editing animated:YES];
    
    if (editing == NO) {
        [self updateSelectionOnTableView];
    }
    else {
        [self updateEditingSelectionCount];
    }
}

static NSIndexSet *indexSetFromIndexPathRows(NSArray *paths) {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    for (NSIndexPath *path in paths) {
        [indexSet addIndex:path.row];
    }
    return indexSet;
}

- (void)tappedDeleteSelectedItems:(id)sender {

    // Don't allow delete button to be pressed more than once until
    // the first delete has processed
    if (self.isCurrentlyDeleting) {
        NSLog(@"still deleting, returning");
        return;
    }
    
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSIndexSet *selectedIndexes = indexSetFromIndexPathRows(selectedRows);
    NSArray *items = [self.items objectsAtIndexes:selectedIndexes];
    
    DDLogVerbose(@"tappedDeleteSelectedItems : %@", selectedRows);
    
    [self deleteItemsPromptingIfNecessary:items];
}

- (void)deleteItemsPromptingIfNecessary:(NSArray *)items {
    
    NSIndexSet *indexSet = [items indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[CKFolder class]] == NO) {
            return NO;
        }
        CKFolder *folder = obj;
        return (folder.filesCount + folder.foldersCount > 0);
    }];
    
    NSArray *nonEmptyFolders = [items objectsAtIndexes:indexSet];
    if (nonEmptyFolders.count > 0) {
        DDLogVerbose(@"nonEmptyFolders");
        NSString *title = NSLocalizedString(@"Warning", @"Title for a warning popup");
        
        NSString *message = NSLocalizedString(@"Some selected folders are not empty. Are you sure you want to delete them?", @"Message for a warning popup");
        
        CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:title message:message];
        NSString *confirmButton = NSLocalizedString(@"Delete", @"Button to confirm deleting folders");
        NSString *cancelButton = NSLocalizedString(@"Don't delete", @"Button to cancel deleting folders");
        [alert addButtonWithTitle:confirmButton handler:^{
            [self deleteFolderItems:items];
            [RatingsController appLoadedOnViewController:self];
        }];
        [alert addCancelButtonWithTitle:cancelButton];
        [alert show];
    }
    else {
        [self deleteFolderItems:items];
        [RatingsController appLoadedOnViewController:self];
    }
}

- (void)deleteFolderItems:(NSArray *)items {
    
    self.isCurrentlyDeleting = YES;
    
    NSMutableIndexSet *rowsToRemove = [NSMutableIndexSet new];
    for (id item in items) {
        [rowsToRemove addIndex:[self.items indexOfObjectIdenticalTo:item]];
    }
    
    [self.canvasAPI deleteFolderItems:items withBlock:^(NSDictionary *errors, BOOL isFinalValue) {
        if (errors.count > 0) {
            
            for (id item in errors.keyEnumerator) {
                NSUInteger index = [self.items indexOfObject:item];
                [rowsToRemove removeIndex:index];
            }
            NSLog(@"Error deleting items: %@", errors);
            
            NSString *title = NSLocalizedString(@"Error", @"Title for an error popup");
            NSString *message = NSLocalizedString(@"Some items could not be deleted", @"Message for an error popup");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
        else {
            [self setEditing:NO animated:YES];
        }
        
        NSArray *deletedItems = [self.items objectsAtIndexes:rowsToRemove];
        NSArray *deletedFolders = [deletedItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isKindOfClass:[CKFolder class]];
        }]];
        
        NSArray *deletedFiles = [deletedItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isKindOfClass:[CKAttachment class]];
        }]];
        
        self.folder.filesCount -= (int)deletedFiles.count;
        self.folder.foldersCount -= (int)deletedFolders.count;
        
        [self deleteItems:deletedItems];

        self.isCurrentlyDeleting = NO;
        
    }];
}

- (void)setFolder:(CKFolder *)folder
{
    _folder = folder;
    self.title = folder.name;
    [self discardItemsAndReload];
}

- (void)stopEditing:(id)sender {
    [self setEditing:NO animated:YES];
}

- (void)didLoadMoreItems {
    [self updateSelectionOnTableView];
    [self resortItems];
}


- (void)resortItems {
    [self sortItemsWithComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[CKFolder class]]) {
            if ([obj2 isKindOfClass:[CKFolder class]]) {
                return [[obj1 name] localizedStandardCompare:[obj2 name]];
            }
            else {
                // Sort folders before non-folders
                return NSOrderedAscending;
            }
        }
        else {
            // obj1 is a CKAttachment
            if ([obj2 isKindOfClass:[CKAttachment class]]) {
                return [[obj1 displayName] localizedStandardCompare:[obj2 displayName]];
            }
            else {
                return NSOrderedDescending;
            }
        }
    }];
}

- (void)requestItemsWithPageURL:(NSURL *)pageURL resultsHandler:(CKPagedArrayBlock)handler {
    if (!_hasAllFolders) {
        [self.canvasAPI listFoldersInFolder:self.folder pageURL:_nextFoldersPage block:
         ^(NSError *error, NSArray *theArray, CKPaginationInfo *pagination) {
             
             if (error) {
                 handler(error, nil, 0);
                 return;
             }
             
             _nextFoldersPage = pagination.nextPage;
             
             if (_nextFoldersPage == nil) {
                 _hasAllFolders = YES;
             }
             
             [_pendingItems addObjectsFromArray:theArray];
             
             [self processPendingItemsWithHandler:handler];
         }];
    }
    else if (!_hasAllFiles) {
        [self.canvasAPI listFilesInFolder:self.folder pageURL:_nextFilesPage block:
         ^(NSError *error, NSArray *theArray, CKPaginationInfo *pagination) {
             if (error) {
                 handler(error, nil, 0);
                 return;
             }
             
             _nextFilesPage = pagination.nextPage;
             
             if (_nextFilesPage == nil) {
                 _hasAllFiles = YES;
             }
             
             [_pendingItems addObjectsFromArray:theArray];
             [self processPendingItemsWithHandler:handler];
        }];
    }
    else {
        NSLog(@"Nothing to request; already got all files and folders");
    }
}

- (void)processPendingItemsWithHandler:(CKPagedArrayBlock)handler {
    CKPaginationInfo *pagination = [BogusPaginationInfo new];
    if (_hasAllFolders && _hasAllFiles) {
        pagination = nil;
    }
    
    // If we manually inserted an object, it may show up in
    // a later paginated request. Don't show it twice.
    [_pendingItems removeObjectsInArray:self.items];
    
    if ((_hasAllFolders && _hasAllFiles) || _pendingItems.count >= self.canvasAPI.itemsPerPage) {
        handler(nil, _pendingItems, pagination);
        [_pendingItems removeAllObjects];
    }
    else {
        // Yes, we're passing the same "pagesRequested" here, that was run previously.
        // But since we're actually combining two separate paged APIs, we're tracking
        // the page ourselves. So this parameter just serves to track what meta-page
        // the superclass will think we're on. We've decided we need more results for
        // the current meta-page, so we'll pass the same 'page' again.
        [self requestItemsWithPageURL:pagination.nextPage resultsHandler:handler];
    }
}

- (UITableViewCell *)cellForItem:(id)item {
    UITableViewCell *cell = nil;
    if ([item isKindOfClass:[CKFolder class]]) {
        CKFolder *folder = item;
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"FolderCell"];
        cell.textLabel.text = folder.name;
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        [imageView setImage:[imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        int itemCount = folder.filesCount + folder.foldersCount;
        
        NSString *itemCountTemplate = NSLocalizedString(@"%d items", @"Number of files/folders inside a folder. (Used for all cases except 1 item.)");
        if (itemCount == 1) {
            itemCountTemplate = NSLocalizedString(@"1 item", @"Number of files/folders inside a folder. (Only used when there is exactly 1 item.");
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:itemCountTemplate, folder.filesCount + folder.foldersCount];
        
        if (folder.lockedForUser) {
            cell.detailTextLabel.text = NSLocalizedString(@"This folder is locked", @"Text indicating that a folder cannot be opened");
            cell.textLabel.enabled = NO;
        }
        else {
            cell.textLabel.enabled = YES;
        }
        
    }
    else if ([item isKindOfClass:[CKAttachment class]]) {
        CKAttachment *file = item;
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"FileCell"];
        cell.textLabel.text = file.displayName;
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        [imageView setImage:[imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        CKByteCountFormatter *formatter = [CKByteCountFormatter new];
        NSString *fileSizeStr = [formatter stringFromByteCount:file.fileSize];
        cell.detailTextLabel.text = fileSizeStr;
        
        if (file.lockedForUser) {
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.text = NSLocalizedString(@"This file is locked", @"Text indicating that a file cannot be opened");
        }
        else {
            cell.textLabel.enabled = YES;
        }
        
    }
    else {
        NSAssert(NO, @"Unexpected item type");
    }
    
    [self applyStylingToCell:cell];
    
    return cell;
}

- (void)updateEditingSelectionCount {
    NSString *template = NSLocalizedString(@"Delete (%d)", @"Button for deleting files or folders. %d will be the number of selected items");
    NSUInteger selectionCount = [[self.tableView indexPathsForSelectedRows] count];
    _deleteItem.title = [NSString stringWithFormat:template, selectionCount];
    
    _deleteItem.enabled = (selectionCount > 0);
    
}

#pragma mark - Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionContainsItems:indexPath.section] == NO) {
        return NO;
    }
    id item = (self.items)[indexPath.row];
    return [item isLockedForUser] == NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionContainsItems:indexPath.section] == NO) {
        return;
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id item = (self.items)[indexPath.row];
        [self deleteItemsPromptingIfNecessary:@[item]];
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // This is here just to avoid getting -setEditing:animated: called on swipe-to-delete
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // This is here just to avoid getting -setEditing:animated: called on swipe-to-delete
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        [self updateEditingSelectionCount];
        return;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    indexPath = [super tableView:tableView willSelectRowAtIndexPath:indexPath];
    if ([self sectionContainsItems:indexPath.section]) {
        return indexPath;
    }
    
    id item = (self.items)[indexPath.row];
    if ([item isLockedForUser]) {
        return nil;
    }
    return indexPath;
}

- (void)didSelectItem:(id)item inCell:(UITableViewCell *)cell {
    if (self.editing) {
        [self updateEditingSelectionCount];
        return;
    }
    
    if ([item isLockedForUser]) {
        return;
    }
    if ([item isKindOfClass:[CKAttachment class]]) {
        CKAttachment *file = item;
        selectionTracker.selectedFile = file;
        
        DDLogVerbose(@"attachmentSelected : %llu : %d", file.ident, file.type);
        [self showFileIfAvailable:file];
    }
    else if ([item isKindOfClass:[CKFolder class]]) {
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        CKFolder *folder = (self.items)[path.row];
        FolderViewController *folderController = [[FolderViewController alloc] initWithInterfaceStyle:_interfaceStyle];
        folderController.folder = folder;
        folderController.canvasAPI = self.canvasAPI;
        folderController.fileSelectionBlock = self.fileSelectionBlock;
        folderController->selectionTracker = selectionTracker;
        folderController.title = folder.name;
        [folderController loadMoreItems];
        
        DDLogVerbose(@"folderSelected : %llu : %@", folder.ident, folder.name);
        [self.navigationController pushViewController:folderController animated:YES];
    }
}

- (void)showFileIfAvailable:(CKAttachment *)file {
    
    NSURL *localCacheURL = [file cacheURL];
    NSNumber *fileSize = nil;
    [localCacheURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
    
    if ([fileSize unsignedLongLongValue] == file.fileSize) {
        // It's already downloaded; just show it
        [self showFile:file];
        return;
    }
    if (_fileSelectionBlock) {
        _fileSelectionBlock(nil);
    }
    
    NSString *hostname = self.canvasAPI.hostname;
    
    NSRange range = [hostname rangeOfString:@":"];
    if (range.location != NSNotFound) {
        hostname = [hostname substringToIndex:range.location];
    }
    Reachability *reachability = [Reachability reachabilityWithHostname:hostname];
    if (reachability.currentReachabilityStatus != NotReachable) {
        [self evaluateReachability:reachability forShowingFile:file];
    }
    else {
        // Wait for the reachability to be evaluated.
        
        __block id observer = nil;
        
        void (^reachabilityHandler)(NSNotification *note) = ^(NSNotification *note) {
            [reachability stopNotifier];
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            [self evaluateReachability:reachability forShowingFile:file];
        };
        
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification
                                                                     object:reachability
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:reachabilityHandler];
        
        [reachability startNotifier];
        
        int64_t delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            // If it's still not reachable, just give up
            if (reachability.currentReachabilityStatus == NotReachable) {
                reachabilityHandler(nil);
            }
        });
        
    }
}

- (void)evaluateReachability:(Reachability *)reachability forShowingFile:(CKAttachment *)file {
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"File unavailable", @"Title for an alert popup")
                                                        message:NSLocalizedString(@"The server could not be reached", @"Explanation for while a file is unavailable")
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    else {
        uint64_t fileSizeAlertLimit = 0;
        if (status == ReachableViaWiFi) {
            fileSizeAlertLimit = 50 * 1000 * 1000; // 50 MB
        }
        else if (status == ReachableViaWWAN) {
            fileSizeAlertLimit = 15 * 1000 * 1000; // 15 MB
        }
        
        if (file.fileSize > fileSizeAlertLimit) {
            NSString *fileSize = [[CKByteCountFormatter new] stringFromByteCount:file.fileSize];
            NSString *message = [NSString stringWithFormat:@"This file is %@, and may take a while to download. Proceed?", fileSize];
            CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:NSLocalizedString(@"Large file", @"Title for an alert popup")
                                                                                message:message];
            [alert addButtonWithTitle:NSLocalizedString(@"Show file", @"Title for button confirming showing a file") handler:^{
                [self showFile:file];
            }];
            [alert addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Button title for canceling download of a file")];
            [alert show];
        }
        else {
            [self showFile:file];
        }
    }
}

- (void)showFile:(CKAttachment *)file {
    NSURL *localCacheURL = [file cacheURL];
    NSNumber *fileSize = nil;
    [localCacheURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
    BOOL hasFileLocally = [fileSize unsignedLongLongValue] == file.fileSize;
    
    if (_fileSelectionBlock) {
        _fileSelectionBlock(file);
    }
    else
    {
        UINavigationController *navController = (UINavigationController *)[[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
        WebBrowserViewController *browser = navController.viewControllers[0];
        [browser setUrl:hasFileLocally ? localCacheURL : file.directDownloadURL];
        [navController setModalPresentationStyle:UIModalPresentationFullScreen];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}



- (void)showOptions:(id)sender {
    DDLogVerbose(@"optionsSelected");
    if (_optionsActionSheet) {
        NSUInteger cancelIndex = [_optionsActionSheet cancelButtonIndex];
        [_optionsActionSheet dismissWithClickedButtonIndex:cancelIndex animated:YES];
        return;
    }
    
    CKActionSheetWithBlocks *actionSheet = [[CKActionSheetWithBlocks alloc] initWithTitle:nil];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Add folder", @"Button title for adding a folder to a folder") handler:^{
        [self tappedAddFolder];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Upload file", @"Button title for adding a file to a folder") handler:^{
        [self tappedUploadFile];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Edit items", @"Button title for deleting items in a folder") handler:^{
        DDLogVerbose(@"editItemsSelected");
        [self setEditing:YES animated:YES];
    }];
    [actionSheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    if (self.tabBarController) {
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    else {
        [actionSheet showFromBarButtonItem:sender animated:YES];
    }
    _optionsActionSheet = actionSheet;
}

- (void)tappedAddFolder {
    DDLogVerbose(@"tappedAddFolder");
    NSString *title = NSLocalizedString(@"New Folder", @"Title for an alert popup, where the user will be asked to provide a name for the new folder");
    NSString *message = NSLocalizedString(@"Choose a name for the new folder.", @"Content of an alert popup");
    
    CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:title message:message];
    __weak CKAlertViewWithBlocks *weakAlert = alert;
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert addCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    [alert addButtonWithTitle:NSLocalizedString(@"Save", nil) handler:^{
        UITextField *textField = [weakAlert textFieldAtIndex:0];
        NSString *folderName = textField.text;
        [self createFolderWithName:folderName];
    }];
    [alert show];
}

- (void)createFolderWithName:(NSString *)name {
    [self.canvasAPI createFolderInFolder:self.folder withName:name block:
     ^(NSError *error, BOOL isFinalValue, id object) {
         if (error) {
             [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
         }
         else if (isFinalValue) {
             self.folder.foldersCount += 1;
             [self insertFolder:object];
             [RatingsController appLoadedOnViewController:self];
         }
     }];
}

- (void)insertFolder:(CKFolder *)newFolder {
    NSUInteger lastFolderIndex = [self.items indexOfObjectWithOptions:NSEnumerationReverse passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:[CKFolder class]];
    }];
    if (lastFolderIndex == NSNotFound) {
        lastFolderIndex = -1;
    }
    NSMutableArray *folders = [[self.items subarrayWithRange:NSMakeRange(0, lastFolderIndex+1)] mutableCopy];
    [folders addObject:newFolder];
    [folders sortUsingComparator:^NSComparisonResult(CKFolder *obj1, CKFolder *obj2) {
        return [obj1.name localizedStandardCompare:obj2.name];
    }];
    
    NSUInteger insertionIndex = [folders indexOfObjectIdenticalTo:newFolder];
    
    [self insertItem:newFolder atIndex:insertionIndex];
}

- (void)tappedUploadFile {
    DDLogVerbose(@"tappedUploadFile");
    ReceivedFilesViewController *filesController = [ReceivedFilesViewController new];
    filesController.submitButtonTitle = NSLocalizedString(@"Upload", @"Button title for uploading a file");
    filesController.onSubmitBlock = ^(NSArray *urls) {
        [self uploadFiles:urls];
    };
    filesController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:filesController animated:YES completion:NULL];
}

- (void)uploadFiles:(NSArray *)urls {
    __weak FolderViewController *weakSelf = self;
    __weak CKUploadProgressToolbar *toolbar = _progressToolbar;
    CKFolder *folder = self.folder;
    
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTask = UIBackgroundTaskInvalid;
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
    }];
    
    [_progressToolbar updateProgressViewWithProgress:0];
    [self.canvasAPI uploadFiles:urls toFolder:folder
              progressBlock:^(float progress) {
                  [toolbar updateProgressViewWithProgress:progress];
              }
            completionBlock:^(NSError *error, BOOL isFinalValue, NSArray *attachments) {
                if (error) {
                    showErrorForFolder(error, folder);
                }
                else {
                    weakSelf.folder.filesCount += (int) attachments.count;
                    [toolbar transitionToUploadCompletedWithError:error completion:NULL];
                    [weakSelf insertFiles:attachments];
                    
                    deleteFiles(urls);
                }
                [application endBackgroundTask:backgroundTask];
                [RatingsController appLoadedOnViewController:self];
            }];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

static void deleteFiles(NSArray *fileURLs) {
    NSFileManager *fileManager = [NSFileManager new];
    for (NSURL *fileURL in fileURLs) {
        // If there's an error, we don't really care; it was probably
        // already gone. And this is just some tidy-up work; if somehow
        // we fail, the user can still delete it themselves.
        [fileManager removeItemAtURL:fileURL error:NULL];
    }
}


// This is a static function so that it can be called from a completion
// block even if the controller has been dealloc'd
static void showErrorForFolder(NSError *error, CKFolder *folder) {
    UIApplication *application = [UIApplication sharedApplication];
    
    NSString *template = NSLocalizedString(@"Upload to folder \"%@\" failed", @"Error message");
    NSString *message = [NSString stringWithFormat:template, folder.name];
    if (application.applicationState == UIApplicationStateBackground) {
        UILocalNotification *note = [UILocalNotification new];
        note.alertBody = message;
        [application presentLocalNotificationNow:note];
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:message
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (void)insertFiles:(NSArray *)attachments {
    for (CKAttachment *attachment in attachments) {
        [self insertItem:attachment atIndex:self.items.count];
    }
    [self resortItems];
}

#pragma mark - styling

- (UITableViewCell *)noItemsCell {
    ProgressTableViewCell *cell = (ProgressTableViewCell *)[super noItemsCell];
    
    [self applyStylingToCell:cell];
    
    return cell;
}

- (void)applyStylingToCell:(UITableViewCell *)cell {
    if (_interfaceStyle == FolderInterfaceStyleDark) {
        UIImage *image = [[UIImage techDebtImageNamed:@"course-detail-background"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 0, 1, 1)];
        UIImage *highlightImage = [[UIImage techDebtImageNamed:@"course-detail-background-highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 0, 1, 1)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.image = image;
        imageView.highlightedImage = highlightImage;
        cell.backgroundView = imageView;
        
        UIImageView *multipleSelectionBackground = [[UIImageView alloc] initWithFrame:cell.bounds];
        multipleSelectionBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        multipleSelectionBackground.image = image;

        cell.multipleSelectionBackgroundView = multipleSelectionBackground;
        
        if ([cell.reuseIdentifier isEqualToString:@"FolderCell"] && cell.accessoryView == nil) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([cell.reuseIdentifier isEqualToString:@"FileCell"]) {
            // Nothing right now
        }
        
        else if ([cell isKindOfClass:[ProgressTableViewCell class]]) {
            ProgressTableViewCell *progCell = (ProgressTableViewCell *)cell;
            progCell.progressMessage.textColor = [UIColor lightTextColor];
            progCell.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        }
        else {
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor lightTextColor];
        }
    }
}

#pragma mark - Fetching

- (void)loadRootFolderForContext:(CKContextInfo *)context {
    __block BOOL hasSetFolder = NO;
    [self.canvasAPI getRootFolderForContext:context block:^(NSError *error, BOOL isFinalValue, id object) {
        if (error) {
            NSString *title = NSLocalizedString(@"Unable to load", @"Error title");
            NSString *message = NSLocalizedString(@"Your files could not be found", @"Error content");
            NSString *ok = NSLocalizedString(@"OK", nil);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
            [alert show];
        }
        else if (!hasSetFolder) {
            // The user's root folder is very unlikely to change, so we're fine just taking
            // the cached value.
            hasSetFolder = YES;
            
            self.folder = object;
            [self loadMoreItems];
        }
    }];

}

@end

