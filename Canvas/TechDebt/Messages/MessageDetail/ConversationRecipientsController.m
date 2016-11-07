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
#import <objc/runtime.h>
#import <CanvasKit1/CanvasKit1.h>
#import "UIViewController+AnalyticsTracking.h"

#import "ConversationRecipientsController.h"

#import "SubtitleAndRightDetailCell.h"
#import "UIView+FloatingView.h"
#import <JSTokenField/JSTokenField.h>
#import "Analytics.h"
@import CanvasKeymaster;
#import "CBILog.h"


#pragma mark - SelectedRecipientsInfo

// A shared object to provide shared context between all instances of ConversationRecipientsController
@interface SelectedRecipientsInfo : NSObject
@property NSMutableArray *selectedRecipients;
@property NSMutableArray *contextsProvidingNames;
@property NSMutableDictionary *contextedNamesForRecipients;
@end

@implementation SelectedRecipientsInfo

- (id)init {
    self = [super init];
    if (self) {
        _selectedRecipients = [NSMutableArray new];
        _contextsProvidingNames = [NSMutableArray new];
        _contextedNamesForRecipients = [NSMutableDictionary new];
    }
    return self;
}
@end


#pragma mark - ConversationRecipientsController

@interface ConversationRecipientsController () <UINavigationControllerDelegate, JSTokenFieldDelegate> {
    BOOL allItemsSelected;
}
@property (strong) JSTokenField *receivedHeaderView;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) SelectedRecipientsInfo *recipientInfo;
@property (strong, nonatomic) NSMutableArray *currentSearchSignalDisposables;
@end

@implementation ConversationRecipientsController

#pragma mark - Table view data source

- (id)init {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ConversationRecipients" bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:@"RecipientsController"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.allowsSelection = YES;
    self.showsCheckmarksForSelectedItems = YES;
    self.showsTokenField = YES;
    
    self.currentSearchSignalDisposables = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetPopoverSize];
    
    if (!self.recipientInfo) {
        self.recipientInfo = [SelectedRecipientsInfo new];
    }
    
    for (CKIConversationRecipient *recipient in self.selectedRecipients) {
        [self.tokenField addTokenWithTitle:recipient.name representedObject:recipient];
    }

    self.tokenField.clipsToBounds = YES;
    self.tokenField.delegate = self;
    self.tokenField.layer.borderWidth = 1.0;
    self.tokenField.layer.borderColor = [[UIColor grayColor] CGColor];
    self.tokenField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tokenField.textField.accessibilityTraits |= UIAccessibilityTraitSearchField;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenFieldFrameDidChange:)
                                                 name:JSTokenFieldFrameDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JSTokenFieldFrameDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self updateContextInfo];
    
    if (self.showsTokenField == NO) {
        self.tableView.tableHeaderView = nil;
    }
    
    if (self.popoverMode == NO) {
        if (self.navigationItem.rightBarButtonItem == nil) {
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePicking)];
            self.navigationItem.rightBarButtonItem = doneButton;
        }
        if (self.navigationItem.leftBarButtonItem == nil && self.navigationController.viewControllers[0] == self) {
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPicking)];
            self.navigationItem.leftBarButtonItem = cancelButton;
        }
    }
    
    if (self.allowsSelection == YES) {
        self.navigationItem.title = NSLocalizedString(@"Add recipients", @"Title when showing a list of users you might add to a message. 15 characters is about all we have room for here.");
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"Recipients", @"Title for the list of users who will receive a message. 15 characters is about all we have room for here.");
    }
    
    allItemsSelected = self.allMembersAreImplicitlySelected;
    if (self.allMembersAreImplicitlySelected == NO && self.searchContext) {
        allItemsSelected = [self isRecipientSelected:self.searchContext];
    }
    
    if ([self isMovingToParentViewController]) {
        // When pushing on a new controller
        [self resetPopoverSize];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
    [Analytics logScreenView:kGAIScreenAddRecipients];
    
    if (self.navigationController.delegate == nil) {
        self.navigationController.delegate = self;
    }
    
    if (self.searchResults == nil) {
        if (self.searchString || self.searchContext) {
            [self startSearch];
        }
    }
    
    if ([self isMovingToParentViewController] == NO) {
        // When popping back to a previous controller
        [self resetPopoverSize];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        if ([[self.recipientInfo.contextsProvidingNames lastObject] isEqual:self.searchContext]) {
            [self.recipientInfo.contextsProvidingNames removeLastObject];
        }
        
        NSArray *controllers = self.navigationController.viewControllers;
        
        ConversationRecipientsController *previousController = nil;
        if (controllers.count >= 1) {
            previousController = controllers[controllers.count - 1];
        }
        if ([self.delegate respondsToSelector:@selector(recipientsController:willPopToRecipientsController:)]) {
            [self.delegate recipientsController:self willPopToRecipientsController:previousController];
        }
    }
}

- (SelectedRecipientsInfo *)recipientInfo {
    if (!_recipientInfo) {
        _recipientInfo = [SelectedRecipientsInfo new];
    }
    return _recipientInfo;
}

- (void)setSelectedRecipients:(NSArray *)selectedRecipients {
    if (selectedRecipients == nil) {
        selectedRecipients = [NSMutableArray new];
    }
    self.recipientInfo.selectedRecipients = [selectedRecipients mutableCopy];
}

- (NSArray *)selectedRecipients {
    return self.recipientInfo.selectedRecipients;
}

- (void)updateContextInfo {
    if (self.searchContext == nil) {
        self.tokenField.textField.placeholder = NSLocalizedString(@"Search for recipients", @"Placeholder text in a search bar used to find conversation recipients");
    }
    else {
        self.tokenField.textField.placeholder = self.searchContext.name;
    }
    self.tokenField.textField.text = self.searchString;
}

- (IBAction)donePicking {
    DDLogVerbose(@"donePickingPressed");
    if ([self.delegate respondsToSelector:@selector(recipientsController:saveRecipients:)]) {
        [self.delegate recipientsController:self saveRecipients:self.recipientInfo.selectedRecipients];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancelPicking {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)startSearch {
    if (self.isViewLoaded == NO) {
        return;
    }
    
    self.searchResults = nil;
    [self.tableView reloadData];
    for (RACDisposable *disposable in self.currentSearchSignalDisposables) {
        [disposable dispose];
    }
    
    if (self.searchString.length > 0 || self.searchContext != nil) {
        RACSignal *newSearchSignal = [[CKIClient currentClient] fetchConversationRecipientsWithSearchString:self.searchString inContext:self.searchContext.id];
        RACDisposable *disposable = [newSearchSignal subscribeNext:^(NSArray *recipients) {
            if (!self.searchResults) {
                self.searchResults = @[];
            }
            self.searchResults = [self.searchResults arrayByAddingObjectsFromArray:recipients];
            [self.tableView reloadData];
        } error:^(NSError *error) {
            NSLog(@"Got back error from new search: %@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't find recipients", @"title for alert displayed when iCanvas can't fetch recipients") message:NSLocalizedString(@"Canvas failed to find recipients for your current search. Please try again later.", @"detail text for recipient fetch error message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") otherButtonTitles:nil];
            [alert show];
        }];
        [self.currentSearchSignalDisposables addObject:disposable];
    }
}

- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    [self performSelector:@selector(startSearch) withObject:nil afterDelay:0.6];
}

- (void)setSearchContext:(CKIConversationRecipient *)searchContext {
    _searchContext = searchContext;
    [self startSearch];
}

- (void)resetPopoverSize {
    self.preferredContentSize = CGSizeMake(320, 480);
}

- (void)setSearchResults:(NSArray *)someRecipients {
    _searchResults = someRecipients;
    [self resetPopoverSize];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (BOOL)hasSearchMaterial {
    return (self.searchString.length > 0 || self.searchContext != nil);
}

- (BOOL)hasSearchResults {
    return self.hasSearchMaterial && self.searchResults != nil;
}

- (BOOL)isSearching {
    BOOL hasSearchResults = (self.searchResults != nil);
    return (self.hasSearchMaterial && !hasSearchResults);
}

- (BOOL)shouldShowStaticResults {
    return self.staticResults.count > 0 && self.hasSearchMaterial == NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger resultsCount = 0;
    
    if (self.shouldShowStaticResults) {
        resultsCount = self.staticResults.count;
    }
    else if (self.isSearching) {
        resultsCount = 1;
    }
    else if (self.hasSearchResults) {
        if (self.searchResults.count == 0) {
            resultsCount = 1; // For the "no results" cell
        }
        else {
            resultsCount = self.searchResults.count;
            if ([self shouldShowAllMembersRow]) {
                resultsCount += 1; // For the "All members" cell
            }
        }
    }

    return resultsCount;
}

- (BOOL)shouldShowAllMembersRow {
    return self.searchContext != nil && self.searchContext.userCount != 0 && self.searchString.length == 0;
}

- (BOOL)rowIsAllMembersRow:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && [self shouldShowAllMembersRow]) {
        return YES;
    }
    return NO;
}

- (CKIConversationRecipient *)resultForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger idx = indexPath.row;

    if ([self shouldShowStaticResults]) {
        return (self.staticResults)[idx];
    }
    
    if ([self shouldShowAllMembersRow]) {
        if (indexPath.row == 0) {
            return self.searchContext;
        }
        // there's an "all results" row we need to discount
        idx -= 1;
    }
    NSAssert(0 <= idx && idx < self.searchResults.count, @"Invalid search result index");
    return (self.searchResults)[idx];
}

- (NSIndexPath *)indexPathForRecipient:(CKIConversationRecipient *)recipient {
    NSUInteger row = NSNotFound;
    if ([self shouldShowStaticResults]) {
        row = [self.staticResults indexOfObject:recipient];
    }
    else if ([recipient isEqual:self.searchContext] && [self shouldShowAllMembersRow]) {
        row = 0;
    }
    else if (self.searchResults) {
        row = [self.searchResults indexOfObject:recipient];
        if ([self shouldShowAllMembersRow]) {
            row += 1;
        }
    }
    
    if (row == NSNotFound) {
        return nil;
    }
    else {
        return [NSIndexPath indexPathForRow:row inSection:0];
    }
}

- (BOOL)recipientRepresentsAllMembersRow:(CKIConversationRecipient *)recipient {
    if ([self shouldShowAllMembersRow] == NO) {
        return NO;
    }
    
    NSIndexPath *path = [self indexPathForRecipient:recipient];
    if (path != nil && path.row == 0) {
        return YES;
    }
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.isSearching) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        cell.textLabel.text = NSLocalizedString(@"Loading...", @"Generic loading title with ellipsis");
        if (cell.accessoryView == nil) {
            cell.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        [(UIActivityIndicatorView *)cell.accessoryView startAnimating];
    }
    else if (self.hasSearchResults && self.searchResults.count == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"];
        cell.textLabel.text = NSLocalizedString(@"No results found", @"Indicates a search found no results");
    }
    else if ([self rowIsAllMembersRow:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AllMembersCell"];
        cell.textLabel.text = NSLocalizedString(@"All members", @"Button to select all members of a group");
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.searchContext.userCount];
        
        BOOL selected = (allItemsSelected || [self.selectedRecipients containsObject:self.searchContext]);
        
        // The 'All Members' row always shows checkmarks, even if showsCheckmarksForSelection is NO.
        // Otherwise, it would be meaningless. It's really more of a button than an information item.
        cell.accessoryType = (selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        
        cell.textLabel.enabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        if (self.allowsSelection == NO) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // If checkmarks aren't shown for selected items, then we don't need to gray out.
            cell.textLabel.enabled = !self.showsCheckmarksForSelectedItems;
        }
    }
    else {
        CKIConversationRecipient *result = [self resultForIndexPath:indexPath];
        

        if ([result.type isEqualToString:CKIRecipientTypeUser]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
            
            BOOL isDirectlySelected = [self.selectedRecipients containsObject:result];
            BOOL selected = (allItemsSelected || isDirectlySelected);
            if (self.showsCheckmarksForSelectedItems) {
                cell.accessoryType = (selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.enabled = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            if (self.allowsSelection == NO) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                // If checkmarks aren't shown for selected items, then we don't need to gray out.
                cell.textLabel.enabled = !self.showsCheckmarksForSelectedItems;
            }
            else if (allItemsSelected || [self.delegate isRecipientSelectable:result] == NO)
            {
                cell.textLabel.enabled = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else if ([result.type isEqualToString:CKIRecipientTypeContext]) {
            if (result.containingContextName != nil) {
                SubtitleAndRightDetailCell *subtitleCell = [tableView dequeueReusableCellWithIdentifier:@"GroupContextCell"];
                subtitleCell.subtitleLabel.text = result.containingContextName;
                cell = subtitleCell;
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"ContextCell"];
            }
            
            if (result.userCount > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)result.userCount];
            }
            else {
                cell.detailTextLabel.text = nil;
            }
        }
        
        if (self.shouldShowStaticResults) {
            cell.textLabel.enabled = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = result.name;
    }
    
    return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (selectedCell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    NSArray *selectableIdentifiers = @[@"UserCell", @"AllMembersCell"];
    if ([selectableIdentifiers containsObject:selectedCell.reuseIdentifier] == NO) {
        return;
    }
    
    CKIConversationRecipient *suggestedRecipient = [self resultForIndexPath:indexPath];
    
    if ([self.recipientInfo.selectedRecipients containsObject:suggestedRecipient]) {
        DDLogVerbose(@"suggestedRecipientDeselected : %@ : %@", suggestedRecipient.id, suggestedRecipient.name);
        [self deselectRecipient:suggestedRecipient];
    }
    else {
        DDLogVerbose(@"suggestedRecipientSelected : %@ : %@", suggestedRecipient.id, suggestedRecipient.name);
        [self selectRecipient:suggestedRecipient];
    }
    
    if ([self.delegate respondsToSelector:@selector(recipientsControllerDidChangeSelections:)]) {
        [self.delegate recipientsControllerDidChangeSelections:self];
    }
    
    self.tokenField.textField.text = nil;
}

- (void)deselectRecipient:(CKIConversationRecipient *)suggestedRecipient {
    NSIndexPath *path = [self indexPathForRecipient:suggestedRecipient];
    [self.recipientInfo.selectedRecipients removeObject:suggestedRecipient];
    [self.tokenField removeTokenWithRepresentedObject:suggestedRecipient];
    if (path) {
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if ([self recipientRepresentsAllMembersRow:suggestedRecipient]) {
        allItemsSelected = [self.selectedRecipients containsObject:self.searchContext];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)selectRecipient:(CKIConversationRecipient *)suggestedRecipient {
    NSString *newContextPrefix = [suggestedRecipient.id stringByAppendingString:@"_"];

    NSMutableArray *recipients = self.recipientInfo.selectedRecipients;
    NSArray *existingRecipients = [self.recipientInfo.selectedRecipients copy];
    
    NSString *tokenName = suggestedRecipient.name;
    
    {
        // Remove sub-entities of this one (e.g. "course_12345_teachers" if we're adding "course_12345")
        for (CKIConversationRecipient *recipient in existingRecipients) {
            if ([recipient.id hasPrefix:newContextPrefix]) {
                [self deselectRecipient:recipient];
            }
        }
        
        // Deselect all other search results if we select an "All Members" row
        if ([self recipientRepresentsAllMembersRow:suggestedRecipient]) {
            for (CKIConversationRecipient *recipient in self.searchResults) {
                [self deselectRecipient:recipient];
            }
        }
    }
    
    if ([suggestedRecipient.type isEqualToString:CKIRecipientTypeContext]) {
        tokenName = [tokenName stringByAppendingFormat:@" (%ld)", (long)suggestedRecipient.userCount];
        
        CKIConversationRecipient *relevantContext = [self.recipientInfo.contextsProvidingNames lastObject];
        if (relevantContext && [relevantContext isEqual:suggestedRecipient] == NO) {
            tokenName = [NSString stringWithFormat:@"%@: %@", relevantContext.name, tokenName];
        }
    }
    
    
    NSIndexPath *path = [self indexPathForRecipient:suggestedRecipient];
    [recipients addObject:suggestedRecipient];
    [self.tokenField addTokenWithTitle:tokenName representedObject:suggestedRecipient];
    self.recipientInfo.contextedNamesForRecipients[suggestedRecipient.id] = tokenName;
    suggestedRecipient.contextedName = tokenName;
    
    if (path) {
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    }

    if ([self recipientRepresentsAllMembersRow:suggestedRecipient]) {
        allItemsSelected = [self.selectedRecipients containsObject:self.searchContext];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationNone];
    }
}


- (BOOL)isRecipientSelected:(CKIConversationRecipient *)recipient {
    return [self.recipientInfo.selectedRecipients containsObject:recipient] || [self.delegate isRecipientSelected:recipient];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    CKIConversationRecipient *selection = [self resultForIndexPath:indexPath];
    
    ConversationRecipientsController *dest = segue.destinationViewController;
    dest.searchString = @"";
    dest.searchContext = selection;
    dest.delegate = self.delegate;
    dest.recipientInfo = self.recipientInfo;

    dest.popoverMode = self.popoverMode;
    dest.allowsSelection = self.allowsSelection;
    dest.showsTokenField = self.showsTokenField;
    dest.showsCheckmarksForSelectedItems = self.showsCheckmarksForSelectedItems;
    
    if (allItemsSelected) {
        dest.allMembersAreImplicitlySelected = YES;
        dest.allowsSelection = NO;
    }
    
    dest.tokenField = self.tokenField;
    dest.tokenField.textField.text = nil;
    
    // If we're pushing a non-synthetic context, add it to the stack of name providers
    if ([selection.type isEqualToString:CKIRecipientTypeContext] && [selection.id rangeOfString:@"\\d$" options:NSRegularExpressionSearch].location != NSNotFound) {
        [self.recipientInfo.contextsProvidingNames addObject:selection];
    }
    if ([self.delegate respondsToSelector:@selector(recipientsController:didPushNewRecipientsController:)]) {
        [self.delegate recipientsController:self didPushNewRecipientsController:dest];
    }
    
    [dest updateContextInfo];
}


#pragma mark - JSTokenFieldDelegate

- (void)tokenFieldTextDidChange:(JSTokenField *)tokenField {
    NSString *text = [tokenField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.searchString = text;
}

- (void)tokenFieldFrameDidChange:(NSNotification *)notification {
    if (notification.object != self.tokenField || self.tokenField.superview != self.tableView) {
        return;
    }

    // This triggers the tableView to reload the height of the tableHeaderView
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField {
    // Just an empty method to make sure it doesn't add tokens implicitly
}


- (void)tokenField:(JSTokenField *)tokenField didRemoveToken:(NSString *)title representedObject:(id)obj {
    [self deselectRecipient:obj];
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(ConversationRecipientsController *)viewController animated:(BOOL)animated {
    
    if (self.showsTokenField == NO) {
        return;
    }
    if (self == viewController) {
        return;
    }
    
    JSTokenField *header = (JSTokenField *)self.tableView.tableHeaderView;
    
    UIView *tempHeader = [[UIView alloc] initWithFrame:(CGRect){.origin=CGPointZero, .size = header.frame.size}];

    if (self.tableView.contentOffset.y == 0 && viewController.isViewLoaded && viewController.tableView.contentOffset.y == 0) {
        // Both are at the same height; float it across
        viewController.receivedHeaderView = header;
        [header floatIntoWindow];
        
        viewController.tableView.tableHeaderView = tempHeader;
        
        [self.view.window addSubview:header];
    }
    else {
        viewController.tableView.tableHeaderView = header;
        viewController.receivedHeaderView = nil;
    }
    
    self.tableView.tableHeaderView.hidden = YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(ConversationRecipientsController *)viewController animated:(BOOL)animated {
    
    if (self.showsTokenField == NO) {
        return;
    }
    if (self == viewController) {
        return;
    }
    
    JSTokenField *header = viewController.receivedHeaderView;
    [header unfloatIntoView:self.tableView];

    UIView *tempHeader = [[UIView alloc] initWithFrame:(CGRect){.origin=CGPointZero, .size = header.frame.size}];
    self.tableView.tableHeaderView = tempHeader;
    
    if (header) {
        viewController.tableView.tableHeaderView = header;
        viewController.receivedHeaderView = nil;
        viewController.tokenField = header;
    }
    else {
        UIView *header = viewController.tableView.tableHeaderView;
        viewController.tableView.tableHeaderView = nil;
        viewController.tableView.tableHeaderView = header;
        viewController.tokenField = nil;
    }
    
    viewController.tokenField.delegate = viewController;
    navigationController.delegate = viewController;
    
    [viewController updateContextInfo];
    viewController.tableView.tableHeaderView.hidden = NO;
}

@end




@implementation CKIConversationRecipient (ContextedNames)

static void *ConversationRecipientContextedNameKey = &ConversationRecipientContextedNameKey;
- (void)setContextedName:(NSString *)contextedName {
    objc_setAssociatedObject(self, ConversationRecipientContextedNameKey, contextedName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)contextedName {
    NSString *result = objc_getAssociatedObject(self, ConversationRecipientContextedNameKey);
    if (!result) {
        result = self.name;
    }
    return result;
}

@end
