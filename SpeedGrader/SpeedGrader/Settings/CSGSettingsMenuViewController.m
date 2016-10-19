//
//  CSGSettingsMenuViewController.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 7/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGSettingsMenuViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "CSGAppDataSource.h"
#import "UIImage+Color.h"

#import "CSGSettingsSwitchView.h"
@import CanvasKeymaster;

typedef NS_ENUM(NSInteger, CSGUserSettingSection) {
    CSGUserSettingSectionAbout,
    CSGUserSettingSectionHelp,
    CSGUserSettingSectionSettings
};

typedef NS_ENUM(NSInteger, CSGUserSetting) {
    CSGUserSettingHideNames,
    CSGUserSettingShowUngradedFirst,
    CSGUserSettingHideUngradedCount,
    CSGUserSettingViewHTML
};

static NSString *const HIDE_NAMES_SETTING_STRING = @"Hide names while grading";
static NSString *const SHOW_UNGRADED_FIRST_SETTING_STRING = @"Show ungraded students first";
static NSString *const HIDE_UNGRADED_COUNT_SETTING_STRING = @"View ungraded count on icon";
static NSString *const VIEW_HTML_SETTING_STRING = @"View HTML";

static NSString *const HELP_URL_STRING = @"http://guides.instructure.com/m/19294";

static NSString *const SETTINGS_SWITCH_CELL_ID = @"SettingsSwitchCell";

@interface CSGSettingsMenuViewController () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIView *userInfoContainerView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *userEmailLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *bannerImageView;

@property (nonatomic, weak) IBOutlet UIView *helpView;
@property (nonatomic, weak) IBOutlet UILabel *helpLabel;

@property (nonatomic, weak) IBOutlet UIView *reportProblemView;
@property (nonatomic, weak) IBOutlet UILabel *reportProblemLabel;

@property (nonatomic, weak) IBOutlet UIView *settingsHeaderView;
@property (nonatomic, weak) IBOutlet UILabel *settingsHeaderLabel;

@property (nonatomic, weak) IBOutlet UIView *settingsContainerView;

@property (nonatomic, weak) IBOutlet CSGSettingsSwitchView *hideNamesView;
@property (nonatomic, weak) IBOutlet CSGSettingsSwitchView *showUngradedFirstView;

@property (nonatomic, weak) IBOutlet UILabel *aboutCopyrightLabel;
@property (nonatomic, weak) IBOutlet UILabel *aboutVersionLabel;

@property (nonatomic, weak) IBOutlet UIView *logoutView;

@property (nonatomic, weak) IBOutlet UILabel *logoutLabel;
@property (nonatomic, weak) IBOutlet UILabel *switchUserLabel;

@property (nonatomic, strong) NSArray *settingsStrings;

@end


@implementation CSGSettingsMenuViewController

+ (instancetype)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *startMasqueradeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(masqueradeAsUser)];
    startMasqueradeTap.numberOfTouchesRequired = 2;
    startMasqueradeTap.numberOfTapsRequired = 2;
    [self.userInfoContainerView addGestureRecognizer:startMasqueradeTap];
    
    UITapGestureRecognizer *stopMasqueradeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopMasquerade)];
    stopMasqueradeTap.numberOfTouchesRequired = 2;
    stopMasqueradeTap.numberOfTapsRequired = 3;
    [self.userInfoContainerView addGestureRecognizer:stopMasqueradeTap];
    
    self.view.backgroundColor = [UIColor csg_settingsBackgroundColor];

    NSString *helveticaNeue = @"HelveticaNeue";
    
    // User Info View
    self.userInfoContainerView.backgroundColor = [UIColor csg_settingsLightBlue];
    [self.bannerImageView setImage:[UIImage imageNamed:@"settings_banner"]];
    
    self.usernameLabel.textColor = [UIColor csg_settingsTextColor];
    self.usernameLabel.font = [UIFont fontWithName:helveticaNeue size:18.0f];
    RAC(self, usernameLabel.text) = [RACObserve(TheKeymaster, currentClient.currentUser.name) map:^id(NSString *value) {
        return [value uppercaseString];
    }];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height/2;
    self.avatarImageView.layer.borderWidth = 0.0f;
    self.avatarImageView.layer.masksToBounds = YES;
    @weakify(self);
    [RACObserve(TheKeymaster, currentClient.currentUser.avatarURL) subscribeNext:^(id x) {
        @strongify(self);
        [self.avatarImageView setImageWithURL:TheKeymaster.currentClient.currentUser.avatarURL placeholderImage:[UIImage imageNamed:@"icon_user"]];
    }];
    
    self.userEmailLabel.textColor = [UIColor csg_settingsTextColor];
    self.userEmailLabel.font = [UIFont fontWithName:helveticaNeue size:14.0f];
    RAC(self, userEmailLabel.text) = RACObserve(TheKeymaster, currentClient.currentUser.email);
    
    // Help
    self.helpView.backgroundColor = [UIColor csg_settingsContainerBackgroundColor];
    self.helpView.layer.cornerRadius = 3.0f;
    self.helpView.layer.borderColor = [UIColor csg_settingsContainerBorderColor].CGColor;
    self.helpView.layer.borderWidth = 1.0f;
    UITapGestureRecognizer *helpTappedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(helpTapped:)];
    [self.helpView addGestureRecognizer:helpTappedGesture];
    
    self.helpLabel.textColor = [UIColor csg_settingsDarkGreyTextColor];
    self.helpLabel.font = [UIFont fontWithName:helveticaNeue size:14.0f];
    
    // Help
    self.reportProblemView.backgroundColor = [UIColor csg_settingsContainerBackgroundColor];
    self.reportProblemView.layer.cornerRadius = 3.0f;
    self.reportProblemView.layer.borderColor = [UIColor csg_settingsContainerBorderColor].CGColor;
    self.reportProblemView.layer.borderWidth = 1.0f;
    UITapGestureRecognizer *reportProblemTappedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reportProblemTapped:)];
    [self.reportProblemView addGestureRecognizer:reportProblemTappedGesture];
    
    self.reportProblemLabel.textColor = [UIColor csg_settingsDarkGreyTextColor];
    self.reportProblemLabel.font = [UIFont fontWithName:helveticaNeue size:14.0f];
    
    // Settings View
    self.settingsHeaderView.backgroundColor = [UIColor csg_settingsLightBlue];
    self.settingsHeaderLabel.textColor = [UIColor csg_settingsTextColor];
    
    self.hideNamesView.textLabel.text = HIDE_NAMES_SETTING_STRING;
    [self.hideNamesView setUserPrefKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsHideNames] andGenericKey:CSGUserPrefsHideNames];
    
    self.showUngradedFirstView.textLabel.text = SHOW_UNGRADED_FIRST_SETTING_STRING;
    [self.showUngradedFirstView setUserPrefKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsShowUngradedFirst] andGenericKey:CSGUserPrefsShowUngradedFirst];
    
    self.settingsContainerView.backgroundColor = [UIColor csg_settingsContainerBackgroundColor];
    self.settingsContainerView.layer.cornerRadius = 3.0f;
    self.settingsContainerView.layer.borderColor = [UIColor csg_settingsContainerBorderColor].CGColor;
    self.settingsContainerView.layer.borderWidth = 1.0f;
    
    self.aboutCopyrightLabel.text = [self aboutCopyrightText];
    self.aboutCopyrightLabel.textColor = [UIColor csg_settingsLightGreyTextColor];
    self.aboutCopyrightLabel.font = [UIFont fontWithName:helveticaNeue size:14.0f];
    
    self.aboutVersionLabel.text = [self aboutVersionText];
    self.aboutVersionLabel.textColor = [UIColor csg_settingsLightGreyTextColor];
    self.aboutVersionLabel.font = [UIFont fontWithName:helveticaNeue size:14.0f];
    
    // Logout View
    self.logoutView.backgroundColor = [UIColor csg_settingsLogoutButtonColor];

    // Logout
    self.logoutLabel.textColor = [UIColor csg_settingsTextColor];
    self.logoutLabel.font = [UIFont fontWithName:helveticaNeue size:18.0f];
    [self.logoutLabel setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *logoutGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutTapped:)];
    [self.logoutLabel addGestureRecognizer:logoutGesture];
    
    // Switch User
    self.switchUserLabel.textColor = [UIColor csg_settingsTextColor];
    self.switchUserLabel.font = [UIFont fontWithName:helveticaNeue size:18.0f];
    [self.switchUserLabel setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *switchUserGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchUserTapped:)];
    [self.switchUserLabel addGestureRecognizer:switchUserGesture];
}

- (void)switchUserTapped:(UITapGestureRecognizer *)recognizer
{
    [[CSGAppDataSource sharedInstance] clearData];
    [TheKeymaster switchUser];
}

- (void)logoutTapped:(UITapGestureRecognizer *)recognizer
{
    [[CSGAppDataSource sharedInstance] clearData];
    [TheKeymaster logout];
}

- (void)helpTapped:(UITapGestureRecognizer *)recognizer
{
    //PUSH Help
    NSURL *url = [NSURL URLWithString:HELP_URL_STRING];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)reportProblemTapped:(UITapGestureRecognizer *)recognizer
{
    //PUSH Help
    UINavigationController *navController = [[UIStoryboard storyboardWithName:@"SupportTicket-iPad" bundle:nil] instantiateInitialViewController];
    SupportTicketViewController *controller = navController.viewControllers[0];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    controller.ticketType = SupportTicketTypeProblem;
    [self presentViewController:navController animated:YES completion:nil];
}

- (NSString *)aboutCopyrightText
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    return [NSString stringWithFormat:@"©2010-%@ Instructure Inc.", [formatter stringFromDate:[NSDate date]]];
}

- (NSString *)aboutVersionText
{
    return [NSString stringWithFormat:@"Version %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

#pragma mark - Masquerade

- (void)masqueradeAsUser {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Masquerade" message:@"Enter user id:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Masquerade", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: //cancel
            DDLogVerbose(@"masqueradeAsUserCancelled");
            break;
        case 1: { //masquerade
            DDLogVerbose(@"masqueradeAsUserSubmit");
            UITextField *textField = [alertView textFieldAtIndex:0];
            [textField resignFirstResponder];
            [self masquerade:[textField text]];
        } break;
        default:
            break;
    }
}

- (void)masquerade:(NSString *)masqueradeAs {
    if (masqueradeAs.length > 0) {
        [[TheKeymaster masqueradeAsUserWithID:masqueradeAs] subscribeNext:^(id client) {
            DDLogVerbose(@"masqueradeAsUserSuccess : %@", [CKIClient currentClient].currentUser.id);
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success!", @"Masquerade success title") message:[NSString stringWithFormat:NSLocalizedString(@"You are now masquerading as %@", @"Masquerade success message"), [CKIClient currentClient].currentUser.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } error:^(NSError *error) {
            DDLogVerbose(@"masqueradeAsUserError : %@", [error localizedDescription]);
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops!", @"Title for an error alert") message:NSLocalizedString(@"You don't have permission to masquerade as this user or there is no user with that ID", @"Masquerade error message") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }];
    }
}

- (void)stopMasquerade {
    DDLogVerbose(@"stopMasqueradePressed");
    [TheKeymaster stopMasquerading];
}

@end
