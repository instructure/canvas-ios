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
#import "UIViewController+AnalyticsTracking.h"
#import <CanvasKit1/CKAlertViewWithBlocks.h>

#import "CreateDiscussionViewController.h"

#import "DiscussionCreationStrategy.h"
#import "Analytics.h"

@import SoPretty;

#import "CBILog.h"
#import "UIImage+TechDebt.h"

@interface CreateDiscussionViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *descriptionContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UIView *iPadHeader;
@property (weak, nonatomic) IBOutlet UIButton *addInlineMediaButton;

@property (nonatomic) CGFloat descriptionInputViewHeight;

@property (strong, nonatomic) CKRichTextInputView *descriptionInputView;

@end


@implementation CreateDiscussionViewController

@synthesize canvasAPI;
@synthesize titleField;
@synthesize descriptionContainer;
@synthesize descriptionInputView;
@synthesize threadedDiscussionSwitch;
@synthesize activityIndicator;
@synthesize postButton;
@synthesize iPadHeader;

- (id)initWithStrategy:(id <DiscussionCreationStrategy>)createDiscussionStrategy
{
    self = [[UIStoryboard storyboardWithName:@"CreateDiscussion" bundle:[NSBundle bundleForClass:[self class]]]
            instantiateViewControllerWithIdentifier:@"CreateDiscussion"];
    if (self) {
        _createDiscussionStrategy = createDiscussionStrategy;
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.tintColor = Brand.current.tintColor;
    
    self.title = [self.createDiscussionStrategy createDiscussionViewTitle];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                                target:self
                                                                                                                action:@selector(cancelCreateDiscussion)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post", @"Button to post new discussion topic")
                                                                                                    style:UIBarButtonItemStyleDone
                                                                                                   target:self
                                                                                                   action:@selector(createDiscussion)];


    CGRect frame = CGRectMake(0,0,descriptionContainer.frame.size.width,descriptionContainer.frame.size.height);
    descriptionInputView = [[CKRichTextInputView alloc] initWithFrame:frame];
    descriptionInputView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                             UIViewAutoresizingFlexibleHeight);
    [descriptionContainer addSubview:descriptionInputView];
    descriptionInputView.showPostButton = NO;
    descriptionInputView.showsAttachmentButton = NO;
    descriptionInputView.backgroundImageView.image = nil;
    descriptionInputView.placeholderText = NSLocalizedString(@"Details", @"Placeholder text for discussion details field");
    descriptionInputView.attachmentSheetTitle = NSLocalizedString(@"Add inline media", @"Title on the add-inline-media sheet");
    descriptionInputView.attachmentButtonImage = [UIImage techDebtImageNamed:@"icon_camera_fill"];
    descriptionInputView.delegate = self;
    
    descriptionInputView.maximumHeight = CGFLOAT_MAX;
    descriptionInputView.minimumHeight = descriptionContainer.frame.size.height;
    descriptionInputView.attachmentManager.presentFromViewController = self;

    activityIndicator.hidesWhenStopped = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || self.iPadToolbarHidden) {
        iPadHeader.hidden = YES;
        iPadHeader.userInteractionEnabled = NO;
    }
    if ([self.createDiscussionStrategy shouldHideThreadedControls]) {
        [self.threadedDiscussionSwitch setHidden:YES];
        [self.threadedSwitchLabel setHidden:YES];
    }
    
    self.addInlineMediaButton.hidden = YES;
    [self.canvasAPI getMediaServerConfigurationWithBlock:^(NSError *error, BOOL isFinalValue) {
        if (self.canvasAPI.mediaServer.enabled) {
            self.addInlineMediaButton.hidden = NO;
        }
    }];
    
    [self.addInlineMediaButton setImage:[self.addInlineMediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.addInlineMediaButton setTintColor:Brand.current.tintColor];
}

- (void)cancelCreateDiscussion
{
    DDLogVerbose(@"cancelCreateDiscussion");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)setIPadToolbarHidden:(BOOL)iPadToolbarHidden
{
    _iPadToolbarHidden = iPadToolbarHidden;
    iPadHeader.hidden = iPadToolbarHidden;
    iPadHeader.userInteractionEnabled = !iPadToolbarHidden;
}

- (void)setFirstResonder {
    if (titleField.text.length == 0) {
        [titleField becomeFirstResponder];
    } else {
        [descriptionInputView becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setFirstResonder];
    
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
    [Analytics logScreenView:kGAIScreenCreateDiscussion];
}

- (BOOL)hasContent
{
    return titleField.text.length > 0 || [descriptionInputView hasContent];
}

- (BOOL)isReadyToPost
{
    return titleField.text.length > 0 && [descriptionInputView hasContent];
}

- (IBAction)tappedAttachementsButton:(id)sender 
{
    [self dismissKeyboard];
    
    DDLogVerbose(@"tappedAttachementsButton");
    [descriptionInputView addAttachment:sender];
}

- (void)createDiscussion
{
    DDLogVerbose(@"createDiscussionPressed");
    if (![self isReadyToPost]) {
        CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc]initWithTitle:NSLocalizedString(@"Oops!", @"Title for an error alert") message:NSLocalizedString(@"You need a title and a description to post", @"Error message")];
        [alert addCancelButtonWithTitle:NSLocalizedString(@"OK", @"OK Button Title")];
        [alert show];
    }
    else {
        [descriptionInputView tappedPostCommentButton:nil];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)dismissKeyboard
{
    [titleField resignFirstResponder];
    [descriptionInputView dismissKeyboard];
}

#pragma mark - CKRichTextInputViewDelegate methods

- (void)resizeRichTextInputViewToHeight:(CGFloat)height
{
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIEdgeInsets inset = self.tableView.contentInset;
    CGFloat height = self.view.bounds.size.height - 88.f - inset.top - inset.bottom;
    if (self.descriptionInputViewHeight != height) {
        self.descriptionInputViewHeight = height;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self.tableView setContentOffset:CGPointZero animated:NO];
    }
}

- (void)richTextView:(CKRichTextInputView *)inputView postComment:(NSString *)comment withAttachments:(NSArray*)attachments andCompletionBlock:(CKSimpleBlock)block
{
    postButton.enabled = NO;
    [self dismissKeyboard];
    [activityIndicator startAnimating];
    
    NSString *title = titleField.text;
    
    [self.createDiscussionStrategy postDiscussionTopicForContext:self.contextInfo
                                                       withTitle:title
                                                         message:comment
                                                     attachments:attachments
                                                       topicType:[self.createDiscussionStrategy topicTypeForThreaded:threadedDiscussionSwitch.isOn]
                                                  usingCanvasAPI:self.canvasAPI
                                                           block:^(NSError *error, CKDiscussionTopic *topic) {
        if (error) {
            DDLogVerbose(@"Error createDiscussionTopic: %@", error);
            [activityIndicator stopAnimating];
            postButton.enabled = YES;
            
            CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:NSLocalizedString(@"Oops!", @"Title for an error alert") 
                                                                                message:NSLocalizedString(@"Unable to post. Please try again later", @"Error message")];
            [alert addCancelButtonWithTitle:NSLocalizedString(@"OK", @"OK Button Title")];
            [alert show];
        }
        else {
            DDLogVerbose(@"newTopicCreated : %llu : %@", topic.ident, topic.title);
            [self.delegate showNewDiscussion:topic];
        }
    }];
    
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 1) {
        return 44.f;
    }
    
    return self.descriptionInputViewHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 2) {
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0, 2000, 0, -2000);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
