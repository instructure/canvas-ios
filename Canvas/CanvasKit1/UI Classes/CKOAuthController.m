
//
//  CKOAuthController.m
//  CanvasKit
//
//  Created by BJ Homer on 8/4/11.
//  Copyright 2011 Instructure, Inc. All rights reserved.
//

#import "CKOAuthController.h"
#import "CKCanvasAPI.h"
#import "NSString+CKAdditions.h"
#import "CKStylingButton.h"
#import "CKOAuthWebLoginViewController.h"
#import "UIImage+Resize.h"
#import "UIImage+CanvasKit1.h"
#import <QuartzCore/QuartzCore.h>

@interface CKOAuthController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    CGFloat verticalSlideValue;
}

@property (strong, nonatomic) IBOutlet UITextField *domainTextField;
@property (strong, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) IBOutlet UILabel *exampleTextLabel;
@property (strong, nonatomic) IBOutlet CKStylingButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *canvasNetworkButton;
@property (weak, nonatomic) IBOutlet UITableView *domainsTableView;

@property (weak, nonatomic) IBOutlet UIView *forceCanvasLoginView;
@property (weak, nonatomic) IBOutlet UISwitch *forceCanvasLoginSwitch;

@property NSString *domainToUse;

@property NSMutableArray *domainSuggestions;
@property NSArray *matchingSuggestions;
@property (nonatomic) BOOL showsSuggestions;
@end

@implementation CKOAuthController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.domainSuggestions = [[self recordedDomainSuggestions] mutableCopy];
    
    self.domainTextField.delegate = self;
    self.domainTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.domainTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    if (self.domainSuggestions.count > 0) {
        self.domainTextField.placeholder = self.domainSuggestions[0];
    }
    
    [self.domainTextField setValue:[UIColor colorWithRed:135.0f/255.0f green:135.0f/255.0f blue:135.0f/255.0f alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    
    NSString * favoriteHost = [[NSUserDefaults standardUserDefaults] objectForKey:CKCanvasHostnameKey];
    if (favoriteHost) {
        self.domainTextField.text = favoriteHost;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        verticalSlideValue = [self.forceCanvasLoginView frame].size.height + 20;
    }
    else {
        verticalSlideValue = [self.forceCanvasLoginView frame].size.height + 10;
    }
    
    float arrow = 18.0f;
    UIImageView * arrowView = [[UIImageView alloc] initWithImage:[UIImage canvasKit1ImageNamed:@"icon_arrow_right"]];
    [arrowView setFrame:CGRectMake(self.canvasNetworkButton.titleLabel.frame.size.width + 2.5f * arrow, 0, arrow, arrow)];
    [self.canvasNetworkButton addSubview:arrowView];
    
    self.canvasNetworkButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -1.0f * arrow, 0.0f, 0.0f);
    
    
    self.connectButton.style = CKButtonStyleLogin;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *doubleTwoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleForceCanvasLogin:)];
    doubleTwoFingerTap.numberOfTapsRequired = 2;
    doubleTwoFingerTap.numberOfTouchesRequired = 2;
    
    [self.view addGestureRecognizer:doubleTwoFingerTap];
    
    self.domainsTableView.alpha = 0.0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (void)doLoginForDomain:(NSString *)domain {
    self.domainTextField.text = domain;
    self.domainToUse = domain;
    CKOAuthWebLoginViewController *webLoginController = [[CKOAuthWebLoginViewController alloc] init];
    [self prepareWebLoginControllerForPushing:webLoginController];
    [self.navigationController pushViewController:webLoginController animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushWebView"] == NO) {
        return;
    }
    CKOAuthWebLoginViewController *webLoginController = (CKOAuthWebLoginViewController *)[segue destinationViewController];
    [self prepareWebLoginControllerForPushing:webLoginController];
}

- (void)prepareWebLoginControllerForPushing:(CKOAuthWebLoginViewController *)webLoginController
{
    [self.domainTextField endEditing:YES];
    
    NSString *hostname = [self.domainToUse lowercaseString];
    if ([hostname length] == 0) {
        hostname = self.domainTextField.placeholder;
    }
    else if ([hostname hasPrefix:@"https://"]) {
        hostname = [hostname substringFromIndex:8];
    }
    else if ([hostname hasPrefix:@"http://"]) {
        hostname = [hostname substringFromIndex:7];
    }
    
    hostname = [hostname stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    
    if ([hostname rangeOfString:@"."].location == NSNotFound &&
        [hostname rangeOfString:@":"].location == NSNotFound) {
        hostname = [NSString stringWithFormat:@"%@.instructure.com", hostname];
    }
    self.domainToUse = self.domainTextField.text = hostname;
    self.canvasAPI.hostname = hostname;
    
    
    webLoginController.canvasAPI = self.canvasAPI;
    webLoginController.forceCanvasLogin = self.forceCanvasLoginSwitch.on;
    webLoginController.finishedBlock = ^(NSError *error, NSString *accessToken, CKUser *user) {
        if (accessToken) {
            [self recordSuccessfulDomain:hostname];
        }
        if (self.finishedBlock) {
            self.finishedBlock(error, accessToken, user);
        }
    };
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self performSegueWithIdentifier:@"PushWebView" sender:self];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardBounds;
    NSValue *keyboardBoundsValue = [note userInfo][@"UIKeyboardBoundsUserInfoKey"];
    [keyboardBoundsValue getValue:&keyboardBounds];
    
    // Pull out the animation timing
    NSNumber *animationCurve = [note userInfo][UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = [note userInfo][UIKeyboardAnimationDurationUserInfoKey];
    
    // Animate the view to move at the same time the keyboard does
    [UIView animateWithDuration:[animationDuration doubleValue]
                          delay:0
                        options:[animationCurve intValue]
                     animations:
     ^ {
         CGRect visibleViewBounds = self.view.bounds;
         visibleViewBounds.size.height = visibleViewBounds.size.height - keyboardBounds.size.height - 3;
         CGPoint middle = CGPointMake(CGRectGetMidX(visibleViewBounds), CGRectGetMidY(visibleViewBounds));
         self.viewContainer.center = middle;
         self.connectBottomConstraint.constant = 80.0f;
         [self.view layoutIfNeeded];
     }
                     completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    CGRect keyboardBounds;
    NSValue *keyboardBoundsValue = [note userInfo][@"UIKeyboardBoundsUserInfoKey"];
    [keyboardBoundsValue getValue:&keyboardBounds];
    
    // Pull out the animation timing
    NSNumber *animationCurve = [note userInfo][UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = [note userInfo][UIKeyboardAnimationDurationUserInfoKey];
    
    // Animate the view to move at the same time the keyboard does
    [UIView animateWithDuration:[animationDuration doubleValue]
                          delay:0
                        options:[animationCurve intValue]
                     animations:
     ^ {
         CGPoint middle = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
         self.viewContainer.center = middle;
         self.connectBottomConstraint.constant -= 80.0f;
         [self.view layoutIfNeeded];
     }
                     completion:NULL];
    
}

- (void)toggleForceCanvasLogin:(UITapGestureRecognizer *)gestureRecognizer
{
    gestureRecognizer.enabled = NO;
    
    if (self.forceCanvasLoginView.hidden) {
        self.forceCanvasLoginView.hidden = NO;
    }
    else {
        self.forceCanvasLoginView.hidden = YES;
    }
    
    gestureRecognizer.enabled = YES;
    
}

#pragma mark - UITextFieldDelegate

- (void)setShowsSuggestions:(BOOL)showsSuggestions {
    _showsSuggestions = showsSuggestions;
    [UIView animateWithDuration:0.25 animations:^{
        if (showsSuggestions) {
            self.domainsTableView.alpha = 1.0;
        }
        else {
            self.domainsTableView.alpha = 0.0;
        }
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *domain = [textField.text mutableCopy];
    [domain replaceCharactersInRange:range withString:string];
    
    [self updateSuggestionsWithDomain:domain];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self updateSuggestionsWithDomain:nil];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.domainToUse = textField.text;
}

- (void)updateSuggestionsWithDomain:(NSString *)domain {
    if (domain.length == 0) {
        self.showsSuggestions = NO;
    }
    else {
        NSArray *matches = [self.domainSuggestions filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@ AND SELF != %@", domain, domain]];
        self.matchingSuggestions = matches;
        self.showsSuggestions = (matches.count > 0);
        [self.domainsTableView reloadData];
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

static NSString * const DomainsKey = @"com.instructure.domains";

- (void)recordSuccessfulDomain:(NSString *)domain {
    [self.domainSuggestions removeObject:domain];
    [self.domainSuggestions insertObject:domain atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:self.domainSuggestions forKey:DomainsKey];
}

- (NSArray *)recordedDomainSuggestions {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *domains = [defaults arrayForKey:DomainsKey] ?: @[];
    return domains;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.matchingSuggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SuggestedDomain";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.textLabel.text = self.matchingSuggestions[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *domain = self.matchingSuggestions[indexPath.row];
    self.domainTextField.text = domain;
    self.showsSuggestions = NO;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - button actions

- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)loginToCanvasNetwork:(id)sender {
    [self doLoginForDomain:@"learn.canvas.net"];
}

#pragma mark - Help
/*
// WIP Nathan Lambson - August 1, 2013
- (void)showHelp
{
    [[Helpshift sharedInstance] showSupportForCurrentInstitutionInViewController:self];
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"UI Action" withAction:@"Tapped Help Button" withLabel:nil withValue:nil];
}
*/
@end
