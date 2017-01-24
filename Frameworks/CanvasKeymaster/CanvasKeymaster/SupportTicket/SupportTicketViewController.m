//
//  SupportTicketViewController.m
//  iCanvas
//
//  Created by Rick Roberts on 8/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "SupportTicketViewController.h"
#import "SupportTicket.h"
#import "ImpactTableViewController.h"
#import "SupportTicketManager.h"
#import "CanvasKeymaster.h"

@import CWNotification;

static float DefaultToastDuration = 1.65f;

@interface SupportTicketViewController () <UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UIButton *impactButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat keyBoardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionPlaceholderTopConstraint;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (nonatomic, strong) SupportTicket *ticket;
@property (nonatomic, strong) NSString *descriptionValue;
@property (weak, nonatomic) IBOutlet UILabel *descriptionPlaceholder;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailContainerHeightConstraint;

@end

@implementation SupportTicketViewController

- (void)setInitialTicketBody:(NSString *)initialTicketBody {
    _initialTicketBody = initialTicketBody;
    [self view]; // force view to load
    self.bodyTextView.text = [NSLocalizedString(@"\n\n===== tell us what happened above this line =====\n\n", "prompt for a support error message") stringByAppendingString:initialTicketBody];
}

+ (SupportTicketViewController *)presentFromViewController:(UIViewController *)presenter supportTicketType:(SupportTicketType)type {
    UINavigationController *nav = (UINavigationController *)[UIStoryboard storyboardWithName:@"SupportTicket" bundle:[NSBundle bundleForClass:self]].instantiateInitialViewController;
    SupportTicketViewController *support = (SupportTicketViewController *)nav.viewControllers[0];
    support.ticketType = type;
    
    [presenter presentViewController:nav animated:YES completion:nil];
    return support;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self makePretty];
    
    [self setupAccessibility];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    self.ticket = [[SupportTicket alloc] init];
    self.ticket.impactValue = SupportTicketImpactLevelNone;
    self.sendButton.enabled = NO;
    
    [self.subjectTextField addTarget:self action:@selector(editingChanged) forControlEvents:UIControlEventEditingChanged];
    [self.emailField addTarget:self action:@selector(editingChanged) forControlEvents:UIControlEventEditingChanged];
    
    if (TheKeymaster.currentClient.isLoggedIn) {
        self.emailContainerHeightConstraint.constant = 0;
        self.emailField.text = TheKeymaster.currentClient.currentUser.email;
    }
    
    if (self.ticketType == SupportTicketTypeFeatureRequest) {
        self.ticket.ticketType = SupportTicketTypeFeatureRequest;
        self.title = NSLocalizedStringFromTableInBundle(@"Request a feature", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
        self.subjectTextField.placeholder = NSLocalizedStringFromTableInBundle(@"Build all the things", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
        self.descriptionPlaceholder.text = NSLocalizedStringFromTableInBundle(@"Describe the feature here", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
    } else {
        self.ticket.ticketType = SupportTicketTypeProblem;
        self.title = NSLocalizedStringFromTableInBundle(@"Report a problem", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
    }
    
}

- (void)editingChanged
{
    [self enableSendIfValidates];
}

- (void)keyboardDidShow:(NSNotification *)note
{
    NSDictionary* keyboardInfo = [note userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [keyboardFrameBegin CGRectValue];
    self.keyBoardHeight = frame.size.height;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.scrollView.scrollIndicatorInsets.top, 0, frame.size.height, 0);
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat newHeight = [textView sizeThatFits:textView.frame.size].height + self.keyBoardHeight;
    CGFloat oldHeight = self.bodyTextViewHeightConstraint.constant;
    
    self.bodyTextViewHeightConstraint.constant = newHeight;
    if (newHeight > oldHeight && self.scrollView.contentSize.height > self.scrollView.frame.size.height) {
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y + (newHeight - oldHeight)) animated:YES];
    }
    
    if (textView.text.length > 0) {
        self.descriptionPlaceholderTopConstraint.constant = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.descriptionPlaceholder.alpha = 0.0f;
            [self.view layoutIfNeeded];
        }];
    } else if (textView.text.length == 0 && self.descriptionValue.length > 0) {
        self.descriptionPlaceholderTopConstraint.constant = 14;
        [UIView animateWithDuration:0.2 animations:^{
            self.descriptionPlaceholder.alpha = 1.0f;
            [self.view layoutIfNeeded];
        }];
    }
    
    self.descriptionValue = textView.text;
    
    [self enableSendIfValidates];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ImpactSegue"]) {
        ImpactTableViewController *controller = segue.destinationViewController;
        controller.ticket = self.ticket;
    } 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.impactButton setTitle:self.ticket.impactString forState:UIControlStateNormal];
    [self enableSendIfValidates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonTouched:(id)sender
{
    if (self.bodyTextView.text.length > 20) {
        UIActionSheet *verifyActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Continue Editing" destructiveButtonTitle:@"Cancel Request" otherButtonTitles:nil];
        if (self.tabBarController) {
            [verifyActionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            [verifyActionSheet showFromBarButtonItem:_cancelButton animated:true];
        }
        
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)enableSendIfValidates
{

    self.sendButton.enabled = YES;
    
    if (self.subjectTextField.text.length == 0) {
        self.sendButton.enabled = NO;
    } else if (self.bodyTextView.text.length == 0) {
        self.sendButton.enabled = NO;
    } else if (self.ticket.impactValue == SupportTicketImpactLevelNone) {
        self.sendButton.enabled = NO;
    }
    
}

- (IBAction)sendButtonTouched:(id)sender
{
    
    self.ticket.subject = self.subjectTextField.text;
    self.ticket.commentBody = self.bodyTextView.text;
    self.ticket.requesterEmail = TheKeymaster.currentClient.currentUser.email;
    if (TheKeymaster.currentClient.isLoggedIn) {
        self.ticket.requesterName = TheKeymaster.currentClient.currentUser.name;
    }
    
    NSURL *baseURL = TheKeymaster.currentClient.baseURL ? TheKeymaster.currentClient.baseURL : [NSURL URLWithString:@"https://canvas.instructure.com"];
    SupportTicketManager *manager = [[SupportTicketManager alloc] initWithBaseURL:baseURL];
    __block CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationLabelTextColor = [UIColor whiteColor];
    notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0];
    
    [manager sendTicket:self.ticket withSuccess:^{
        [notification displayNotificationWithMessage:@"Thanks, your request was received!"
                                              forDuration:DefaultToastDuration];
    } failure:^(NSError *error) {
        [notification displayNotificationWithMessage:@"Request Failed!  Check network and try again!"
                                         forDuration:DefaultToastDuration];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)promptUserToEnterMissingFields
{
    NSString *requiredActionString = @"";
    
    if (self.ticket.impactValue == SupportTicketImpactLevelNone) {
        requiredActionString = NSLocalizedString(@"select the impact", nil);
    } else if (self.subjectTextField.text.length == 0) {
        requiredActionString = NSLocalizedString(@"enter a subject", nil);
    } else if (self.bodyTextView.text.length == 0) {
        requiredActionString = NSLocalizedString(@"describe your problem", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"All Fields are required. Please %@.", requiredActionString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)makePretty
{
    self.bodyTextView.layer.borderWidth = 0.0f;
}

- (void)setupAccessibility
{
    [self.sendButton setAccessibilityIdentifier:@"sendTicketButton"];
    [self.sendButton setAccessibilityLabel:NSLocalizedString(@"Send", nil)];

    [self.cancelButton setAccessibilityIdentifier:@"cancelTicketButton"];
    [self.cancelButton setAccessibilityLabel:NSLocalizedString(@"Cancel", nil)];

    [self.subjectTextField setAccessibilityIdentifier:@"ticketSubjectTextField"];
    [self.subjectTextField setAccessibilityLabel:NSLocalizedString(@"Enter ticket subject", @"Text field to enter subject of the ticket")];

    [self.impactButton setAccessibilityLabel:NSLocalizedString(@"Select ticket impact level", @"Button to select the severity of the ticket")];
    [self.impactButton setAccessibilityIdentifier:@"ticketImpactButton"];

    [self.bodyTextView setAccessibilityIdentifier:@"ticketBodyTextView"];
    [self.bodyTextView setAccessibilityLabel:NSLocalizedString(@"Enter ticket description", @"Text view to enter the description of the ticket")];
}

@end
