//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "SupportTicketViewController.h"
#import "SupportTicket.h"
#import "ImpactTableViewController.h"
#import "SupportTicketManager.h"
#import "CanvasKeymaster.h"

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
        self.title = NSLocalizedStringFromTableInBundle(@"Request a Feature", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
        self.subjectTextField.placeholder = NSLocalizedStringFromTableInBundle(@"Build all the things", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
        self.descriptionPlaceholder.text = NSLocalizedStringFromTableInBundle(@"Describe the feature here", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
    } else {
        self.ticket.ticketType = SupportTicketTypeProblem;
        self.title = NSLocalizedStringFromTableInBundle(@"Report a Problem", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
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
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *cancelButton = NSLocalizedStringFromTableInBundle(@"Continue Editing", nil, bundle, @"");
        NSString *destructiveButton = NSLocalizedStringFromTableInBundle(@"Cancel Request", nil, bundle, @"");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *destroy = [UIAlertAction actionWithTitle:destructiveButton style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:cancel];
        [alert addAction:destroy];
        alert.popoverPresentationController.barButtonItem = _cancelButton;
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
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

- (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:true completion:nil];
}

- (IBAction)sendButtonTouched:(id)sender
{
    
    self.ticket.subject = self.subjectTextField.text;
    self.ticket.commentBody = self.bodyTextView.text;
    self.ticket.requesterEmail = TheKeymaster.currentClient.currentUser.email;
    self.ticket.reportedError = self.reportedError;
    if (TheKeymaster.currentClient.isLoggedIn) {
        self.ticket.requesterName = TheKeymaster.currentClient.currentUser.name;
    }
    
    NSURL *baseURL = TheKeymaster.currentClient.baseURL ? TheKeymaster.currentClient.baseURL : [NSURL URLWithString:@"https://canvas.instructure.com"];
    SupportTicketManager *manager = [[SupportTicketManager alloc] initWithBaseURL:baseURL];
    
    NSBundle *keymaster = [NSBundle bundleForClass:[self class]];
    [manager sendTicket:self.ticket withSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = NSLocalizedStringFromTableInBundle(@"Success!", @"Localizable", keymaster, @"");
            NSString *message = NSLocalizedStringFromTableInBundle(@"Thanks, your request was received!", @"Localizable", keymaster, @"");
            [self alertWithTitle:title message:message];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = NSLocalizedStringFromTableInBundle(@"Request Failed!", @"Localizable", keymaster, @"");
            NSString *message = NSLocalizedStringFromTableInBundle(@"Check network and try again!", @"Localizable", keymaster, @"");
            [self alertWithTitle:title message:message];
        });
    }];
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
    
    NSString *message = [NSString stringWithFormat:@"All Fields are required. Please %@.", requiredActionString];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:nil]];
    [self.presentingViewController presentViewController:alert animated:true completion:nil];
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
