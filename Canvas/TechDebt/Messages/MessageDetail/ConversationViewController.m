
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
#import <CanvasKit1/CKActionSheetWithBlocks.h>
#import "UIViewController+AnalyticsTracking.h"

#import "ConversationViewController.h"
#import "MultiLineTextField.h"
#import "ConversationTemplateRenderer.h"
#import "NSArray_in_additions.h"
#import <JSTokenField/JSTokenField.h>
#import "ConversationRecipientsController.h"
#import "ConversationUpdater.h"
#import "WebBrowserViewController.h"
#import "AttachmentsTableViewController.h"
#import "ProfileViewController.h"
#import "UIImage+Color.h"

#import "UIWebView+SafeAPIURL.h"
#import "CBIURLParser.h"
#import "CBIMessageDetailViewController.h"
#import "UIViewController+Transitions.h"
#import "CBISplitViewController.h"
#import "CBIMessageParticipantsViewModel.h"
#import "CBIConversationStarter.h"
#import "Analytics.h"
#import "CKAttachmentManager.h"
#import "CKCanvasAPI+CurrentAPI.h"
#import "iCanvasErrorHandler.h"
#import "CBILog.h"
#import "UIImage+TechDebt.h"

@import SoPretty;

@interface ConversationViewController () <UITextViewDelegate, UIWebViewDelegate, ConversationRecipientsControllerDelegate, CKAttachmentManagerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate> {
    
    UIActivityIndicatorView *_sendingSpinner;
    
    ConversationTemplateRenderer *templateRenderer;
    
    __weak UISearchBar *searchBar;
    __weak UIActivityIndicatorView *searchSpinner;
    
    void (^onHideTokenField)(void);
    
    BOOL hasLoadedWebView;
    
    CKCanvasAPI *canvasAPI;
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageInputTextViewVerticalConstraint;

@property (weak, nonatomic) IBOutlet UILabel *recipientsInContextLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientsContextNameLabel;
@property (strong, nonatomic) IBOutlet UIView *contextHeader;

@property NSDictionary *audienceContextNames; // NSDictionary { @"course_123" : @"Beginning iOS Development }
@property (weak, nonatomic) IBOutlet UITextView *messageInputTextView;
@property (weak, nonatomic) IBOutlet UIButton *attachmentButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;

@property (strong, nonatomic) CKAttachmentManager *attachmentManager;
@property (nonatomic, assign) NSInteger lastContentOffset;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) CKConversationRecipient *tempRecipientForNewMessageAction;
@end

@implementation ConversationViewController
@synthesize attachmentManager;
@synthesize conversation;
@synthesize delegate;

- (void)dealloc {
    self.conversationWebView.delegate = nil;
}

- (void)setConversation:(CKConversation *)aConversation {
    if (aConversation && aConversation.isPrivate) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else if (aConversation) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage techDebtImageNamed:@"icon_group_fill"] style:UIBarButtonItemStylePlain target:self action:@selector(showRecipientsTable)];
        self.navigationItem.rightBarButtonItem.accessibilityLabel = NSLocalizedString(@"Show recipients", @"VoiceOver text for a button that lets you show recipients");
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showRecipientsTable)];
    }
    conversation = aConversation;

    self.recipients = [[conversation audience] mutableCopy];
    
    if (self.conversationWebView) {
        [self loadConversationList];
    }
}

- (CKConversation *)conversation {
    return conversation;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    float topInset = self.messageInputTextView.frame.size.height;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        topInset = 0;
    }
    
    [self.conversationWebView.scrollView setContentInset:UIEdgeInsetsMake(topInset + 2, 0, 0, 0)];
    [self.conversationWebView.scrollView setScrollIndicatorInsets:self.conversationWebView.scrollView.contentInset];

    // gets rid of the black bar on new conversations
    [self.conversationWebView loadHTMLString:@"" baseURL:nil];
    self.conversationWebView.opaque = NO;

    self.conversationWebView.delegate = self;
    
    for (UIView *subview in [self.conversationWebView.scrollView subviews]) {
        
        BOOL isScroller = (subview.frame.origin.x != 0 &&
                           subview.frame.size.height == self.conversationWebView.bounds.size.height &&
                           subview.frame.size.width < 10);
        
        if ([subview isKindOfClass:[UIImageView class]] && !isScroller) {
            subview.hidden = YES;
        }
    }

    canvasAPI = CKCanvasAPI.currentAPI;
    
    // Hide the attachment button until we know that they can attach items (Kaltura)
    self.attachmentButton.hidden = YES;
    [canvasAPI getMediaServerConfigurationWithBlock:^(NSError *error, BOOL isFinalValue) {
        if (canvasAPI.mediaServer.enabled) {
            self.attachmentButton.hidden = NO;
        }
        else {
            self.attachmentButton.hidden = YES;
        }
    }];

    
    templateRenderer = [[ConversationTemplateRenderer alloc] init];
    templateRenderer.currentUserID = [[canvasAPI user] ident];
    
    self.messageInputTextView.delegate = self;
    self.messageInputTextView.showsVerticalScrollIndicator = NO;

    [self fetchContextNames];
    [self fixNavigationItemTitle];
    [self validateSendButton];
    
    [self markConversationAsReadIfNecessary];
    
    self.attachmentManager = [[CKAttachmentManager alloc] init];
    self.attachmentManager.presentFromViewController = self;
    self.attachmentManager.delegate = self;
    self.attachmentManager.allowedAttachmentTypes = (CKAllowPhotoAttachments | CKAllowVideoAttachments | CKAllowAudioAttachments);
    self.attachmentManager.viewAttachmentsOptionEnabled = YES;
    
    if (!self.recipients) {
        self.recipients = [NSMutableArray new];
    }
    
    [self.messageInputTextView.rac_textSignal subscribeNext:^(NSString *message) {
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
        CGRect rect = [message boundingRectWithSize:CGSizeMake(self.messageInputTextView.frame.size.width - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        CGSize size = rect.size;
        if (size.height > 133) {
            size.height = 133;
        } else if ( size.height < 32) {
            size.height = 32;
        } else {
            size.height = size.height + 16;
        }
        
        [self validateSendButton];
        
        [UIView animateWithDuration:0.1 animations:^{
            [self.messageInputTextViewVerticalConstraint setConstant:size.height];
            [self.view layoutIfNeeded];
        }];
        
    }];
    
    [self.attachmentButton setImage:[self.attachmentButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.messageInputTextView.layer setCornerRadius:3.0f];
    [self setupNotifications];
    [self.conversationWebView.scrollView setDelegate:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.conversationWebView.scrollView) {
        [self.messageInputTextView resignFirstResponder];
    }
}

- (void)addBottomBorderToView:(UIView *)view
{
    UIView *bottomBorder = [[UIView alloc] init];
    [bottomBorder setBackgroundColor:[UIColor prettyGray]];
    [view addSubview:bottomBorder];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [bottomBorder setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomBorder]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(bottomBorder)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBorder(0.5)]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(bottomBorder)]];
}

- (void)loadConversationList
{
    NSString *html = [templateRenderer htmlStringForObject:self.conversation];
    NSURL *baseURL = [[NSBundle bundleForClass:[self class]] resourceURL];
    [self.conversationWebView loadHTMLString:html baseURL:baseURL];
    hasLoadedWebView = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (hasLoadedWebView || self.conversation == nil) {
        return;
    }
    [self.activityIndicator startAnimating];
    [canvasAPI getDetailedConversationForConversation:self.conversation withBlock:^(NSError *error, BOOL isFinalValue, CKConversation *aConversation) {
        [self.conversation updateWithConversation:aConversation];
        if (isFinalValue) {
            [self.activityIndicator stopAnimating];
            [self loadConversationList];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
    [Analytics logScreenView:kGAIScreenConversation];

    if (self.conversation == nil && [self.recipients count] == 0 &&
        ([self isMovingToParentViewController] ||
         [self isBeingPresented])) {
            
        [self showRecipientsTable];
    }
}

- (void)markConversationAsReadIfNecessary
{
    if (conversation.state == CKConversationStateUnread) {
        
        [canvasAPI markConversation:conversation asRead:YES withBlock:^(NSError *error, BOOL isFinalValue) {
            if (!isFinalValue) { return; }
            if (error) {
                [[iCanvasErrorHandler sharedErrorHandler] logError:error];
                return;
            }
            else {
                conversation.state = CKConversationStateRead;
                
                [[ConversationUpdater sharedConversationUpdater] updateUnreadConversationCount];
            }
            
        }];
    }
}

- (IBAction)sendMessage:(id)sender {
    DDLogVerbose(@"sendMessage : %@", self.messageInputTextView.text);
    NSString *text = self.messageInputTextView.text;
    
    _sendingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGPoint spinnerCenter = (CGPoint) {
        .x = CGRectGetMaxX(self.messageInputTextView.bounds) - _sendingSpinner.bounds.size.width/2 - 8,
        .y = CGRectGetMidY(self.messageInputTextView.bounds)
    };
    _sendingSpinner.center = spinnerCenter;
    [self.messageInputTextView addSubview:_sendingSpinner];
    [self.sendMessageButton setEnabled:NO];
    
    
    if (self.conversation) {
        [_sendingSpinner startAnimating];
        [canvasAPI postMessage:text withAttachments:self.attachmentManager.attachments toConversation:conversation withBlock:^(NSError *error, BOOL isFinalValue, CKConversation *postedConversation) {
            [_sendingSpinner stopAnimating];
            [_sendingSpinner removeFromSuperview];
            [self.sendMessageButton setEnabled:YES];
            _sendingSpinner = nil;
            
            if (error) {
                DDLogVerbose(@"ERROR postingMessage : %@", error);
                [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
            }
            else {
                DDLogVerbose(@"postingMessage success");
                [conversation updateWithNewMessagesFromConversation:postedConversation];
                
                self.messageInputTextView.text = nil;
                [self.messageInputTextView resignFirstResponder];
                
                NSString *html = [templateRenderer htmlStringForObject:conversation];
                NSURL *baseURL = [[NSBundle bundleForClass:[self class]] resourceURL];
                [self.conversationWebView loadHTMLString:html baseURL:baseURL];
                
                [delegate didPostToConversations:@[self.conversation]];
                
                [self.attachmentManager clearAttachments];
            }
        }];
    }
    else {
        NSArray *suggestedRecipients = self.recipients;
        
        int recipientCount = [[suggestedRecipients valueForKeyPath:@"@sum.userCount"] intValue];
        if (recipientCount > 1) {
            DDLogVerbose(@"multipleRecipients");
            NSString *title = NSLocalizedString(@"Message everyone separately, or add everyone to a group conversation?", nil);
            
            CKActionSheetWithBlocks *actionSheet = [[CKActionSheetWithBlocks alloc] initWithTitle:title];
            
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Individual messages", @"Button title for sending a direct message; a private conversation")
                                    handler:^{
                                        [self _startNewConversationGrouped:NO text:text];
                                    }];
            
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Group conversation", @"Button title for starting a group conversation")
                                    handler:^{
                                        [self _startNewConversationGrouped:YES text:text];
                                    }];
            
            [actionSheet showFromRect:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300) inView:self.view animated:YES];
        }
        else {
            DDLogVerbose(@"singleRecipients");
            [self _startNewConversationGrouped:NO text:text];
        }
    }
    
}

- (void)_startNewConversationGrouped:(BOOL)grouped text:(NSString *)text {
    
    UIActivityIndicatorView *spinner = _sendingSpinner;
    [spinner startAnimating];
    
    [canvasAPI startNewConversationWithRecipients:self.recipients
                                          message:self.messageInputTextView.text
                                      attachments:self.attachmentManager.attachments
                                groupConversation:grouped
                                            block:
     ^(NSError *error, BOOL isFinalValue, NSArray *conversationsUsed) {
         [spinner stopAnimating];
         [self.sendMessageButton setEnabled:YES];
         [spinner removeFromSuperview];
         _sendingSpinner = nil;
         
         if (error) {
             NSLog(@"error starting new conversation: %@", error);
             [[iCanvasErrorHandler sharedErrorHandler] presentError:error];
         }
         else if (grouped == NO) {
             [delegate didPostToConversations:conversationsUsed];
             [self.navigationController popViewControllerAnimated:YES];
             [self.attachmentManager clearAttachments];
         }
         else {
             self.conversation = conversationsUsed[0];
             
             self.messageInputTextView.text = nil;
             [self.messageInputTextView resignFirstResponder];
             
             [self.attachmentManager clearAttachments];
             
             canvasAPI.refreshCacheOnNextRequest = YES;
             [canvasAPI getDetailedConversationForConversation:self.conversation withBlock:^(NSError *error, BOOL isFinalValue, CKConversation *aConversation) {
                 
                 if (!hasLoadedWebView || [aConversation isEqual:self.conversation] == NO) {
                     NSString *html = [templateRenderer htmlStringForObject:aConversation];
                     NSURL *baseURL = [[NSBundle bundleForClass:[self class]] resourceURL];
                     [self.conversationWebView loadHTMLString:html baseURL:baseURL];
                     hasLoadedWebView = YES;
                 }
                 [self.conversation updateWithConversation:aConversation];
                 self.recipients = [self.conversation.audience mutableCopy];
                 
                 [delegate didPostToConversations:conversationsUsed];
             }];
         }
     }];

}


- (void)fetchContextNames {
    NSArray *courseIDs = self.conversation.audienceContexts[@"courses"];
    NSArray *groupIDs = self.conversation.audienceContexts[@"groups"];
    
    NSMutableDictionary *contextNames = [NSMutableDictionary new];
    
    dispatch_group_t group = dispatch_group_create();
    for (NSNumber *courseID in courseIDs) {
        dispatch_group_enter(group);
        __block BOOL hasLeftGroup = NO;
        [canvasAPI getCourseWithId:courseID.unsignedLongLongValue options:0 block:^(NSError *error, BOOL isFinalValue, CKCourse * object) {
            if (!error) {
                NSString *key = [NSString stringWithFormat:@"course_%@", courseID];
                if (!hasLeftGroup) {
                    contextNames[key] = object.name;
                    dispatch_group_leave(group);
                    hasLeftGroup = YES;
                }
            }
        }];
    }
    for (NSNumber *groupID in groupIDs) {
        dispatch_group_enter(group);
        __block BOOL hasLeftGroup = NO;
        [canvasAPI getGroupWithId:groupID.unsignedLongLongValue block:^(NSError *error, BOOL isFinalValue, CKGroup *object) {
            if (!error) {
                NSString *key = [NSString stringWithFormat:@"group_%@", groupID];
                if (!hasLeftGroup) {
                    contextNames[key] = object.name;
                    dispatch_group_leave(group);
                    hasLeftGroup = YES;
                }
            }
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self.audienceContextNames = contextNames;
        [self fixNavigationItemTitle];
    });
}

- (void)fixNavigationItemTitle {
    NSArray *recipientNames = [self.recipients in_arrayByApplyingBlock:^id(CKConversationRecipient *obj) {
        return obj.name;
    }];
    
    
    if (recipientNames.count > 0) {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        NSDictionary *textAttributes = navigationBar.titleTextAttributes;
        UIFont *navItemFont = textAttributes[NSFontAttributeName];
        
        if (navItemFont == nil) {
            // Empirically, this seems to be the default
            navItemFont = [UIFont boldSystemFontOfSize:20.0];
        }
        
        self.navigationItem.title = [recipientNames in_componentsJoinedByString:@", "
                                                        componentCollectiveNoun:@"people"
                                                                   maximumWidth:self.contextHeader.bounds.size.width
                                                                         inFont:navItemFont];
        
        self.recipientsInContextLabel.text = [recipientNames in_componentsJoinedByString:@", "
                                                                 componentCollectiveNoun:@"people"
                                                                            maximumWidth:self.contextHeader.bounds.size.width
                                                                                  inFont:self.recipientsInContextLabel.font];
        self.recipientsContextNameLabel.text = [[self.audienceContextNames allValues] componentsJoinedByString:@", "];
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"No recipients", nil);
        self.recipientsInContextLabel.text = self.navigationItem.title;
        self.recipientsContextNameLabel.text = nil;
    }
    
    NSUInteger courseContextsCount = [self.conversation.audienceContexts[@"courses"] count];
    NSUInteger groupContextsCount  = [self.conversation.audienceContexts[@"groups"] count];
    if (courseContextsCount + groupContextsCount == 0) {
        self.navigationItem.titleView = nil;
    }
    
}

- (IBAction)showRecipientsTable {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ConversationRecipients" bundle:[NSBundle bundleForClass:[self class]]];
    UINavigationController *navController = [storyboard instantiateInitialViewController];
    ConversationRecipientsController *recipientsController = (navController.viewControllers)[0];
    recipientsController.staticResults = self.recipients;
    recipientsController.delegate = self;
    if (self.conversation.audience.count == 1) {
        recipientsController.allowsSelection = NO;
        recipientsController.showsTokenField = NO;
        recipientsController.showsCheckmarksForSelectedItems = NO;
    }
    [self presentViewController:navController animated:YES completion:NULL];
    
    [recipientsController.tokenField becomeFirstResponder];
}

- (void)validateSendButton {
    BOOL isEmpty = [self.messageInputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0;
    if ((conversation == nil && self.recipients.count == 0) || isEmpty)
    {
        self.sendMessageButton.enabled = NO;
    }
    else {
        self.sendMessageButton.enabled = YES;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self validateSendButton];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.scheme isEqualToString:@"show-attachment"]) {
        
        NSURL *attachmentURL = [NSURL URLWithString:request.URL.query];
        
        UINavigationController *controller = (UINavigationController *)[[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
        WebBrowserViewController *browser = controller.viewControllers[0];
        [browser setUrl:attachmentURL];
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
        
        return YES;
        
    }
    else if ([request.URL.scheme isEqualToString:@"show-user-profile"]) {
        
        CBIURLParser *parser = [[CBIURLParser alloc] initWithURLString:request.URL.description];
        NSString *userID = [parser valueForVariable:@"user_id"];
        NSString *userName = [parser valueForVariable:@"user_name"];
        
        self.tempRecipientForNewMessageAction = [[CKConversationRecipient alloc] initWithInfo:@{@"id": userID, @"name": [userName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]}];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Would you like to create a new message?", @"Title for action sheet giving the user an option to create a new message for a user.") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", "Cancel button title") destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Send %@ a message", @"Action sheet button title for sending a new message to a user. %@ will be replaced with the user's name"), [userName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]], nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];

    }
    else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
            
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    return YES;
}

- (void)postNewRecipients:(NSArray *)newRecipients {
    
    CKConversation *localConversation = self.conversation;
    __weak typeof(self) weakSelf = self;
    
    [canvasAPI addRecipients:newRecipients toConversation:self.conversation block:^(NSError *error, BOOL isFinalValue, CKConversation *updatedConversation) {
        if (error) {
            NSString *title = NSLocalizedString(@"Error adding recipients", @"Title of an alert popup");
            NSString *message = NSLocalizedString(@"The recipients could not be added. Please try again. (%@)", @"Text explaining the error");
            message = [NSString stringWithFormat:message, [error localizedDescription]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            return;
        }
        [localConversation updateWithNewMessagesFromConversation:updatedConversation];
        
        typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.recipients = [localConversation.audience mutableCopy];
            NSString *html = [strongSelf->templateRenderer htmlStringForObject:localConversation];
            NSURL *baseURL = [[NSBundle bundleForClass:[self class]] resourceURL];
            [strongSelf.conversationWebView loadHTMLString:html baseURL:baseURL];
            
            [strongSelf->delegate didPostToConversations:@[localConversation]];
        }
    }];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView replaceHREFsWithAPISafeURLs];
}

#pragma mark - CKConversationRecipientsControllerDelegate

- (BOOL)isRecipientSelected:(CKConversationRecipient *)recipient {
    return [self.recipients containsObject:recipient];
}

- (BOOL)isRecipientSelectable:(CKConversationRecipient *)recipient {
    if (recipient.ident == canvasAPI.user.ident) {
        return NO;
    }
    return [conversation.participants containsObject:recipient] == NO;
}

- (void)recipientsControllerDidChangeSelections:(ConversationRecipientsController *)controller {
    [self fixNavigationItemTitle];
}

- (void)recipientsController:(ConversationRecipientsController *)controller saveRecipients:(NSArray *)savedRecipients {
    [self.recipients addObjectsFromArray:savedRecipients];
    [self fixNavigationItemTitle];
    
    if (self.conversation) {
        NSArray *oldRecipients = self.conversation.audience;
        NSMutableArray *newRecipients = [self.recipients mutableCopy];
        
        [newRecipients removeObjectsInArray:oldRecipients];
        
        if (newRecipients.count > 0) {
            [self postNewRecipients:newRecipients];
        }
    }
    
    [self validateSendButton];
}

#pragma mark - Message Attachments

- (IBAction)addAttachment:(id)sender {
    DDLogVerbose(@"addAttachmentPressed");
    [self.attachmentManager showAttachmentPickerFromViewController:self withSheetTitle:NSLocalizedString(@"Add attachment", nil)];
}

#pragma mark - AttachmentManagerDelegate

- (void)attachmentManager:(CKAttachmentManager *)manager didAddAttachmentAtIndex:(NSUInteger)index
{
    [self.attachmentButton setImage:nil forState:UIControlStateNormal];
    [self.attachmentButton setTitle:[NSString stringWithFormat:@"%tu", manager.count] forState:UIControlStateNormal];
    if (manager.count == 1) {
        self.attachmentButton.accessibilityValue = NSLocalizedString(@"1 Attachment", nil);
    } else {
        self.attachmentButton.accessibilityValue = [NSString stringWithFormat:NSLocalizedString(@"%u Attachments", nil), manager.count];
    }
}

- (void)attachmentManagerDidRemoveAllAttachments:(CKAttachmentManager *)manager
{
    [self.attachmentButton setImage:[[UIImage techDebtImageNamed:@"icon_attachment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.attachmentButton setTitle:@"" forState:UIControlStateNormal];
    self.attachmentButton.accessibilityValue = nil;
}

- (void)attachmentManager:(CKAttachmentManager *)manager didRemoveAttachmentAtIndex:(NSUInteger)index
{
    if (manager.attachments.count == 0) {
        [self attachmentManagerDidRemoveAllAttachments:manager];
    } else {
        // The implementation of -attachmentManager:didAddAttachmentAtIndex: here doesn't rely on the index
        [self attachmentManager:manager didAddAttachmentAtIndex:index];
    }
}

- (void)showAttachmentsForAttachmentManager:(CKAttachmentManager *)manager
{
    AttachmentsTableViewController *attachmentsTableVC = [AttachmentsTableViewController new];
    attachmentsTableVC.attachmentManager = self.attachmentManager;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:attachmentsTableVC];
    navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}
- (IBAction)cancelNewMessageTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)recipientsButtonTouched:(id)sender
{
    DDLogVerbose(@"recipientsButtonTouched");
    [self showRecipientsTable];
}

- (void)setupNotifications
{
    __block ConversationViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *info = [note userInfo];
        NSValue *endFrameValue = info[UIKeyboardFrameEndUserInfoKey];
        CGRect endFrame = [weakSelf.view convertRect:endFrameValue.CGRectValue fromView:nil];
        [self.conversationWebView.scrollView setContentInset:UIEdgeInsetsMake(self.conversationWebView.scrollView.contentInset.top, 0, endFrame.size.height, 0)];
        [self.conversationWebView.scrollView setScrollIndicatorInsets:self.conversationWebView.scrollView.contentInset];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.conversationWebView.scrollView setContentInset:UIEdgeInsetsMake(self.conversationWebView.scrollView.contentInset.top, 0, 0, 0)];
        [self.conversationWebView.scrollView setScrollIndicatorInsets:self.conversationWebView.scrollView.contentInset];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [[CBIConversationStarter sharedConversationStarter] startAConversationWithRecipients:@[self.tempRecipientForNewMessageAction]];
    }
}

@end
