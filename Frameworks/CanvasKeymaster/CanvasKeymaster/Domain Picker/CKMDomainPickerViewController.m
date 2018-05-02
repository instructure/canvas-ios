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
#import "CKMDomainSearchViewController.h"
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
#import "CKMDomainPickerViewController.h"
#import "CKMLocationSchoolSuggester.h"

#define ddLogLevel LOG_LEVEL_VERBOSE

int ddLogLevel =
#ifdef DEBUG
    DDLogLevelVerbose;
#else
    DDLogLevelError;
#endif

static BOOL PerformedStartupAnimation = NO;

@interface CKMDomainPickerViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CKMDomainSearchViewControllerDelegate>

// UI
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic) IBOutlet NSLayoutConstraint *logoImageStageTwoConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *fullLogoImageView;
@property (nonatomic, weak) IBOutlet UIButton *findSchoolButton;
@property (nonatomic, weak) IBOutlet UIButton *canvasNetworkButton;
@property (nonatomic, weak) IBOutlet UILabel *forceCanvasLoginLabel;
@property (nonatomic, weak) IBOutlet UIView *bottomContainer;
@property (nonatomic, weak) IBOutlet UIButton *customLoginButton;
@property (nonatomic, strong) UIView *backgroundView;

// Signal Stuff
@property (nonatomic, strong) RACSubject *domainSubject;
@property (nonatomic, strong) RACSubject *userSubject;
@property (nonatomic, strong) RACScopedDisposable *loginGestureDisposable;

// Previous Logins
@property (nonatomic, strong) CKMMultiUserTableViewController *multiUserTableViewController;
@property (nonatomic, strong) NSLayoutConstraint *bottomContainerHiddenConstraint;

// Data from the preload-account-info.plist file
// Used to bypass mobileverify during development
@property (nonatomic) NSDictionary *preloadedAccountInfo;

@end

@implementation CKMDomainPickerViewController

- (id)init
{
    return [[UIStoryboard storyboardWithName:@"CKMDomainPickerViewController" bundle:[NSBundle bundleForClass:[CKMDomainPickerViewController class]]] instantiateInitialViewController];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.fullLogoImageView.alpha = 0.0;
    self.findSchoolButton.alpha = 0.0;
    self.canvasNetworkButton.alpha = 0.0;
    self.logoImageStageTwoConstraint.active = false;
    self.findSchoolButton.layer.cornerRadius = 5.0;
    self.findSchoolButton.clipsToBounds = YES;
    
    self.bottomContainerHiddenConstraint = [self.view.bottomAnchor constraintEqualToAnchor:self.bottomContainer.topAnchor];
    self.bottomContainerHiddenConstraint.active = true;
    
    [self styleDomainPicker];
    [self setupForceCanvasLoginGestureRecognizer];
    [self setupForceCanvasLoginLabel];
    [self setupMultiUserLogin];
    [self startUpdatingLocation];
        
    if (PerformedStartupAnimation) {
        [self skipLaunchAnimations];
    }
    
    // Start getting all the accounts
    [[CKMLocationSchoolSuggester shared] fetchSchools];
    
    NSURL *preloadedAccountInfoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"preload-account-info" withExtension:@"plist"];
    if (preloadedAccountInfoURL) {
        self.preloadedAccountInfo = [NSDictionary dictionaryWithContentsOfURL:preloadedAccountInfoURL];
        self.customLoginButton.hidden = [self.preloadedAccountInfo[@"client_secret"] length] == 0;
        [self.customLoginButton setTitle:self.preloadedAccountInfo[@"base_url"] forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
    
    if (!PerformedStartupAnimation) {
        [self launchAnimation];
        PerformedStartupAnimation = YES;
    }
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

#pragma mark - Setup

- (void)setupMultiUserLogin
{
    [self.multiUserTableViewController.selectedUserSignal subscribeNext:^(CKIClient *selectedClient) {
        [self sendClient:selectedClient];
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

- (void)styleDomainPicker {
    [CKILoginViewController setLoadingImage:TheKeymaster.delegate.logoForDomainPicker];
    self.logoImageView.image = TheKeymaster.delegate.logoForDomainPicker;
    self.fullLogoImageView.image = TheKeymaster.delegate.fullLogoForDomainPicker;
    UIView *background = TheKeymaster.delegate.backgroundViewForDomainPicker;
    background.frame = self.view.bounds;
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:background atIndex:0];
    self.backgroundView = background;
}

- (void)startUpdatingLocation {
    [[CKMLocationManager sharedInstance] startUpdatingLocation];
}

#pragma mark - User Signal

- (RACSubject *)userSubject {
    if (!_userSubject) {
        _userSubject = [RACSubject subject];
    }
    return _userSubject;
}

- (void)sendClient:(CKIClient *)client {
    [self.userSubject sendNext:client];
}

- (RACSignal *)selectUserSignal {
    return self.userSubject;
}

#pragma mark - Domain Signal

- (RACSubject *)domainSubject {
    if (!_domainSubject) {
        _domainSubject = [RACSubject subject];
    }
    return _domainSubject;
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

- (RACSignal *)selectedADomainSignal {
    return self.domainSubject;
}

#pragma mark - Launch Animation

- (void)launchAnimation
{
    [self.view layoutIfNeeded];
    [self animationStepOne];
    
    [UIView animateWithDuration:.75f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            [self animationStepTwo];
        } completion:^(BOOL finished) {
            [self animationStepThree];
            [UIView animateWithDuration:0.5f delay:0.5f usingSpringWithDamping:0.75f initialSpringVelocity:2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.view layoutIfNeeded];
            } completion:nil];
        }];
    }];
}

- (void)animationStepOne {
    self.logoImageStageTwoConstraint.active = true;
}

- (void)animationStepTwo {
    self.fullLogoImageView.alpha = 1.0;
    self.findSchoolButton.alpha = 1.0;
    self.canvasNetworkButton.alpha = 1.0;
}

- (void)animationStepThree {
    if ([[FXKeychain sharedKeychain] clients].count > 0) {
        self.bottomContainerHiddenConstraint.active = false;
    }
}

- (void)skipLaunchAnimations {
    [self animationStepOne];
    [self animationStepTwo];
    [self animationStepThree];
    [self.view layoutIfNeeded];
}

#pragma mark - Canvas Network

static NSString *const CanvasNetworkDomain = @"learn.canvas.net";

- (IBAction)logIntoCanvasNetwork {
    DDLogVerbose(@"logIntoCanvasNetworkPressed : %@", CanvasNetworkDomain);
    CKIAccountDomain *domain = [[CKIAccountDomain alloc] initWithDomain:CanvasNetworkDomain];
    [self sendDomain:domain];
}

- (IBAction)customLoginAction:(id)sender {
    [[CanvasKeymaster theKeymaster] loginWithMobileVerifyDetails:self.preloadedAccountInfo];
}

#pragma mark - UITextFieldDelegate

- (RACSignal *)textFieldShouldReturnSignal {
    return [self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)];
}

- (void)showHelpPopover {
    CKMDomainHelpViewController *helpViewController = [CKMDomainHelpViewController instantiateFromStoryboard];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:helpViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FindSchool"]) {
        CKMDomainSearchViewController *controller = (CKMDomainSearchViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"EmbedMultiUsers"]) {
        self.multiUserTableViewController = segue.destinationViewController;
    }
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return NO;
    }
    return YES;
}
    
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    return UIInterfaceOrientationMaskAll;
}

@end
