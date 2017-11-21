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

#import "CKMDomainPickerViewController.h"
#import "CKMDomainSuggestionTableViewController.h"
@import ReactiveObjC;
#import <CocoaLumberjack/DDLog.h>
#import <MessageUI/MessageUI.h>
@import Mantle;

@import Reachability;
#import "CanvasKeymaster.h"
#import "CKMMultiUserTableViewController.h"
@import CanvasKit;
@import CocoaLumberjack;
#import "CKMLocationManager.h"
#import "CKMDomainHelpViewController.h"
#import "SupportTicketViewController.h"

#define ddLogLevel LOG_LEVEL_VERBOSE

int ddLogLevel =
#ifdef DEBUG
    DDLogLevelVerbose;
#else
    DDLogLevelError;
#endif

@interface CKMDomainPickerViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

// UI
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property(nonatomic, weak) IBOutlet UIButton *connectButton;
@property(nonatomic, weak) IBOutlet UIView *domainTextFieldContainer;
@property(nonatomic, weak) IBOutlet UITextField *domainTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectToCanvasNetworkButton;
@property (nonatomic, weak) IBOutlet UILabel *forceCanvasLoginLabel;
@property (nonatomic, weak) IBOutlet UIButton *helpButton;
@property (nonatomic, strong) UIView *backgroundView;

// Animation related properties
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textFieldContainerToSuperViewConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *paddingBetweenTextFieldAndLogoConstraint;
@property (nonatomic) CGFloat textFieldContainerToSuperViewConstraintOriginalValue;

// Signal Stuff
@property (nonatomic, strong) RACSubject *domainSubject;
@property (nonatomic, strong) RACSubject *userSubject;
@property (nonatomic, strong) RACScopedDisposable *loginGestureDisposable;

// Domain Suggestions
@property (nonatomic, weak) IBOutlet UIView *suggestionContainer;
@property (nonatomic, strong) CKMDomainSuggestionTableViewController *suggestionTableViewController;

// Multiple User Support
@property (nonatomic, weak) IBOutlet UIView *multiUserContainer;
@property (nonatomic, strong) CKMMultiUserTableViewController *multiUserTableViewController;

// Local Variables
@property (nonatomic, strong) NSString *defaultDomainTextfieldValue;

@end

@implementation CKMDomainPickerViewController

- (id)init
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self = [[UIStoryboard storyboardWithName:@"CKMDomainPickerPhone" bundle:[NSBundle bundleForClass:[CKMDomainPickerViewController class]]] instantiateInitialViewController];
    } else {
        self = [[UIStoryboard storyboardWithName:@"CKMDomainPickerPad" bundle:[NSBundle bundleForClass:[CKMDomainPickerViewController class]]] instantiateInitialViewController];
    }
    
    self.defaultDomainTextfieldValue = @"";
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gray_dots_bg"]];
    
    [self styleDomainPicker];
    [self setupForceCanvasLoginGestureRecognizer];
    [self setupForceCanvasLoginLabel];
    [self setupTextFieldContainer];
    [self setupTextField];
    [self setupSuggestions];
    [self setupConnectButton];
    [self setupHelpButton];
    [self setupMultiUserLogin];
    [self startUpdatingLocation];
    
    UITapGestureRecognizer *dismissKeyboardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    dismissKeyboardGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:dismissKeyboardGestureRecognizer];

    self.activityIndicatorView.hidesWhenStopped = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.activityIndicatorView stopAnimating];
    [self.domainTextField setText:self.defaultDomainTextfieldValue];
    [self imitateLaunchScreen];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
    
    [self launchAnimation];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

#pragma mark - Setup

- (void)setupMultiUserLogin
{
    [self.multiUserTableViewController.selectedUserSignal subscribeNext:^(CKIClient *selectedClient) {
        [self sendClient:selectedClient];
    }];
    
    [self.keyboardWillShowSignal subscribeNext:^(NSNotification *keyboardNotification) {
        NSInteger curve = [keyboardNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSTimeInterval duration = [keyboardNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [self hideMultipleUsersWithDuration:duration curve:curve];
    }];
    
    [self.keyboardWillHideSignal subscribeNext:^(NSNotification *keyboardNotification) {
        NSInteger curve = [keyboardNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSTimeInterval duration = [keyboardNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [self hideMultipleUsersWithDuration:duration curve:curve];
    }];
}

- (void)setupSuggestions
{
    // self.suggestionTableViewController should be set in -prepareForSegue:sender:

    [self addThinGrayBorderToView:self.suggestionContainer];

    @weakify(self);
    [self.suggestionTableViewController.selectedSchoolSignal subscribeNext:^(CKIAccountDomain *school) {
        @strongify(self);
        DDLogVerbose(@"suggestionTableViewControllerSelected : %@", school.domain);
        self.domainTextField.text = school.domain;
        [self sendDomain:school];
    }];
    
    [self.suggestionTableViewController.selectedHelpSignal subscribeNext:^(id x) {
        @strongify(self);
        [self showHelpPopover];
    }];

    RAC(self, suggestionTableViewController.query) = self.domainTextField.rac_textSignal;

    [self.keyboardWillShowSignal subscribeNext:^(NSNotification *keyboardNotification) {
        @strongify(self);
        NSInteger curve = [keyboardNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSTimeInterval duration = [keyboardNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [self showSuggestionsWithDuration:duration curve:curve];
    }];
}

- (void)setupForceCanvasLoginLabel
{
    RAC(self, forceCanvasLoginLabel.text) = [RACObserve(self, authenticationMethod) map:^id(NSNumber *authMethodNumber) {
        switch (authMethodNumber.unsignedIntegerValue) {
            case CKIAuthenticationMethodForcedCanvasLogin:
                return NSLocalizedString(@"Canvas Login", @"Label displayed when forcing canvas login");
            case CKIAuthenticationMethodSiteAdmin:
                return NSLocalizedString(@"Site Admin Login", @"Label displayed when logging in as site admin");
        }
        return @"";
    }];
}

- (void)setupForceCanvasLoginGestureRecognizer
{
    UITapGestureRecognizer *doubleDoubleTapGestureRecognizer = [UITapGestureRecognizer new];
#if TARGET_IPHONE_SIMULATOR
    doubleDoubleTapGestureRecognizer.numberOfTapsRequired = 1;
#else
    doubleDoubleTapGestureRecognizer.numberOfTapsRequired = 2;
#endif
    doubleDoubleTapGestureRecognizer.numberOfTouchesRequired = 2;
    @weakify(self);
    self.loginGestureDisposable = [[[doubleDoubleTapGestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
        @strongify(self);
        self.authenticationMethod = (self.authenticationMethod + 1) % CKIAuthenticationMethodCount;
    }] asScopedDisposable];

    [self.backgroundView addGestureRecognizer:doubleDoubleTapGestureRecognizer];
}

- (void)setupConnectButton
{
    UIImage *theImage = [self.connectButton imageForState:UIControlStateNormal];
    [self.connectButton setImage:[theImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [self.connectButton setTintColor:[UIColor colorWithRed:0.10 green:0.20 blue:0.44 alpha:1]];
    
    [self.connectButton setAccessibilityIdentifier:@"domainPickerSubmitButton"];
    [self.connectButton setAccessibilityLabel:NSLocalizedString(@"Search for domain.", @"Placeholder for search button on Domain Picker View")];
    
    RAC(self, connectButton.enabled) = [self.domainTextField.rac_textSignal map:^id(NSString *text) {
        return @(![text isEqualToString:@""]);
    }];

    [[self.connectButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id value) {
        DDLogVerbose(@"connectButtonPressed : %@", self.domainTextField.text);
        [self sendTextFieldDomain];
    }];
}

- (void)setupHelpButton
{
    [self.helpButton setImage:[[UIImage imageNamed:@"icon_help" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.helpButton setAccessibilityIdentifier:@"helpButton"];
    NSString *openHelp = NSLocalizedStringFromTableInBundle(@"Open help menu", @"Localizable", [NSBundle bundleForClass:[self class]], @"Placeholder for help icon (question mark) on Domain Picker View");
    [self.helpButton setAccessibilityLabel:openHelp];
    
    [[self.helpButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        DDLogVerbose(@"helpButtonPressed : %@", self.domainTextField.text);
        NSString *title = NSLocalizedStringFromTableInBundle(@"Help Menu", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
        NSString *problem = NSLocalizedStringFromTableInBundle(@"Report a Problem", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
        NSString *feature = NSLocalizedStringFromTableInBundle(@"Request a Feature", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
        NSString *findSchool = NSLocalizedStringFromTableInBundle(@"Find School Domain", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
        NSString *cancel = NSLocalizedStringFromTableInBundle(@"Cancel", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:problem, feature, findSchool, nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [actionSheet showFromRect:button.bounds inView:button animated:YES];
        } else {
            [actionSheet showInView:self.view];
        }
    }];
}

- (void)styleDomainPicker
{
    self.logoImageView.image = TheKeymaster.delegate.logoForDomainPicker;
    UIView *background = TheKeymaster.delegate.backgroundViewForDomainPicker;
    background.frame = self.view.bounds;
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:background atIndex:0];
    self.backgroundView = background;
}

- (void)setupTextFieldContainer
{
    [self addThinGrayBorderToView:self.domainTextFieldContainer];
    self.textFieldContainerToSuperViewConstraintOriginalValue = self.textFieldContainerToSuperViewConstraint.constant;
}

- (void)setupTextField
{
    self.domainTextField.returnKeyType = UIReturnKeyGo;
    self.domainTextField.keyboardType = UIKeyboardTypeDefault;
    self.domainTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self.domainTextField setAccessibilityIdentifier:@"domainPickerTextField"];
    [self.domainTextField setAccessibilityLabel:NSLocalizedString(@"Enter school domain.", @"Text field to enter school domain that user would like the search in Domain Picker View")];

    self.domainTextField.delegate = self;
    [self.textFieldShouldReturnSignal subscribeNext:^(RACTuple *arguments) {
        DDLogVerbose(@"textFieldReturnPressed : %@", self.domainTextField.text);
        [self sendTextFieldDomain];
    }];
    // make the placeholder italic. unfortunately, setting an attributedPlaceholder cannot change the font.
    RAC(self, domainTextField.font) = [self.domainTextField.rac_textSignal map:^id(NSString *text) {
        if ([text isEqualToString:@""]) {
            return [UIFont italicSystemFontOfSize:16];
        }
        else {
            return [UIFont systemFontOfSize:16];
        }
    }];
}

- (void)startUpdatingLocation {
    [[CKMLocationManager sharedInstance] startUpdatingLocation];
}

#pragma mark - Style

- (void)addThinGrayBorderToView:(UIView *)view
{
    view.layer.borderColor = [UIColor colorWithRed:209/255.f green:211/255.f blue:212/255.f alpha:1].CGColor;
    view.layer.borderWidth = 1.0f;
}

#pragma mark - User Signal

- (RACSubject *)userSubject
{
    if (!_userSubject) {
        _userSubject = [RACSubject subject];
    }
    return _userSubject;
}

- (void)sendClient:(CKIClient *)client
{
    [self.userSubject sendNext:client];
}

- (RACSignal *)selectUserSignal
{
    return self.userSubject;
}

#pragma mark - Domain Signal

- (RACSubject *)domainSubject
{
    if (!_domainSubject) {
        _domainSubject = [RACSubject subject];
    }
    return _domainSubject;
}

- (void)sendTextFieldDomain
{
    CKIAccountDomain *domain = [[CKIAccountDomain alloc] initWithDomain:self.domainTextField.text];
    [self sendDomain: domain];
}

- (void)sendDomain:(CKIAccountDomain *)domain
{
    // check if we've got network connectivity
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable: {
            NSString *alertTitle = @"Whoops!";
            NSString *alertMessage = @"We can't connect to Canvas. Have you checked your internet connection?";
            NSString *alertCloseButtonText = @"Close";
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                     message:alertMessage
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:alertCloseButtonText
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
            }
        case ReachableViaWWAN:
        case ReachableViaWiFi: {
            [self.domainSubject sendNext:domain];
            [[TheKeymaster analyticsProvider] trackScreenView:@"Domain Picker"];
            break;
        }
        default: {
            NSLog(@"Something crazy happened. We shouldn't get here.");
            break;
        }
    }
}

- (RACSignal *)selectedADomainSignal
{
    return self.domainSubject;
}

- (void)prepopulateWithDomain:(NSString *)domain
{
    if (self.domainTextField) {
        self.domainTextField.text = domain;
    } else {
        self.defaultDomainTextfieldValue = domain;
    }
}

#pragma mark - Launch Animation

// unfortunately, we don't get the correct bounds until viewDidAppear if we
// are are in landscape, and since we need to layout in viewDidAppear, we don't
// want things to flicker so we make them hidden until we lay them out.

/**
 Makes the view initially look like the launch screen image
 */
- (void)imitateLaunchScreen
{
    self.domainTextFieldContainer.alpha = 0.0f;
    self.connectButton.alpha = 0.0f;
    self.multiUserContainer.alpha = 0.0f;

    // calculate offset so that the center of the logo is at the center of the view
    CGFloat offset;
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)) {
        offset = self.view.bounds.size.width / 2;
    }
    else {
        offset = self.view.bounds.size.height / 2;
    }
    offset += self.logoImageView.bounds.size.height / 2;
    offset += self.paddingBetweenTextFieldAndLogoConstraint.constant;
    offset -= self.domainTextFieldContainer.bounds.size.height / 2;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.textFieldContainerToSuperViewConstraint.constant = offset;
    }
    else {
        self.textFieldContainerToSuperViewConstraint.constant = offset;
    }

    [self.view layoutIfNeeded];

}

/**
 launch the animation that will transition between the launch screen imposter
 and the way we designed the storyboard.
*/
- (void)launchAnimation
{
    [self.view layoutIfNeeded];

    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.textFieldContainerToSuperViewConstraint.constant = self.textFieldContainerToSuperViewConstraintOriginalValue;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            self.connectButton.alpha = 1.0f;
            self.domainTextFieldContainer.alpha = 1.0f;
            self.multiUserContainer.alpha = 1.0f;

        }];
    }];
}

#pragma mark - Suggestions

- (void)showSuggestionsWithDuration:(NSInteger)duration curve:(NSInteger)animationCurve
{
    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | (animationCurve << 16)) animations:^{
        self.suggestionContainer.alpha = 1.0f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.helpButton.alpha = 0.0f;
            self.textFieldContainerToSuperViewConstraint.constant = 0;
            [self.view layoutIfNeeded];
        }
    } completion:nil];
}

- (void)hideSuggestionsWithDuration:(NSInteger)duration curve:(NSInteger)animationCurve
{
    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | (animationCurve << 16)) animations:^{
        self.suggestionContainer.alpha = 0.0f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.helpButton.alpha = 1.0f;
            self.textFieldContainerToSuperViewConstraint.constant = self.textFieldContainerToSuperViewConstraintOriginalValue;
            [self.view layoutIfNeeded];
        }
    } completion:nil];
}

#pragma mark - Multiple Users

- (void)showMultipleUsersWithDuration:(NSInteger)duration curve:(NSInteger)animationCurve
{
    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | (animationCurve << 16)) animations:^{
        self.multiUserContainer.alpha = 1.0f;
    } completion:nil];
}

- (void)hideMultipleUsersWithDuration:(NSInteger)duration curve:(NSInteger)animationCurve
{
    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | (animationCurve << 16)) animations:^{
        self.multiUserContainer.alpha = 0.0f;
    } completion:nil];
}

#pragma mark - Canvas Network

static NSString *const CanvasNetworkDomain = @"learn.canvas.net";

- (IBAction)logIntoCanvasNetwork
{
    DDLogVerbose(@"logIntoCanvasNetworkPressed : %@", CanvasNetworkDomain);
    self.domainTextField.text = CanvasNetworkDomain;
    [self sendTextFieldDomain];
}

#pragma mark - UITextFieldDelegate

- (RACSignal *)textFieldShouldReturnSignal
{
    return [self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)];
}

#pragma mark - Keyboard Signals

- (RACSignal *)keyboardWillShowSignal
{
    return [[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil];
}

- (RACSignal *)keyboardWillHideSignal
{
    return [[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil];
}

- (void)dismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.domainTextField isFirstResponder]) {
        [self.domainTextField resignFirstResponder];
        [self showMultipleUsersWithDuration:0.3 curve:UIViewAnimationOptionCurveEaseOut];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![touch.view isDescendantOfView:self.suggestionContainer] && ![touch.view isDescendantOfView:self.multiUserContainer];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // Report a Problem
            [SupportTicketViewController presentFromViewController:self supportTicketType:SupportTicketTypeProblem];
            break;
        case 1:
            // Request a mobile feature
            [SupportTicketViewController presentFromViewController:self supportTicketType:SupportTicketTypeFeatureRequest];
            break;
        case 2:
            [self showHelpPopover];
            break;
    }
    
}

- (void)showHelpPopover {
    CKMDomainHelpViewController *helpViewController = [CKMDomainHelpViewController instantiateFromStoryboard];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:helpViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
    
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedSuggestions"]) {
        self.suggestionTableViewController = segue.destinationViewController;
    }
    if ([segue.identifier isEqualToString:@"EmbedMultiUsers"]) {
        
        self.multiUserTableViewController = segue.destinationViewController;
    }
}

@end
