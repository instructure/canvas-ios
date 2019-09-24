//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import <QuartzCore/QuartzCore.h>
#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit1/CKActionSheetWithBlocks.h>
#import "UIAlertController+TechDebt.h"
#import "AboutViewController.h"
@import SafariServices;
@import CanvasCore;

typedef NS_ENUM(NSInteger, AboutSections) {
    InfoSection,
    LegalSection,
    SubscribeSection
};

typedef NS_ENUM(NSInteger, LegalRows) {
    PrivacyRow,
    TermsRow,
    OpenSourceRow
};

@interface AboutViewController ()

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UILabel *loginIDLabel;
@property (strong, nonatomic) IBOutlet UILabel *domainLabel;
@property (strong, nonatomic) IBOutlet UILabel *subscribeCalendarLabel;
@property (strong, nonatomic) IBOutlet UILabel *privacyPolicyLabel;
@property (strong, nonatomic) IBOutlet UILabel *termsOfUseLabel;
@property (strong, nonatomic) IBOutlet UILabel *openSourceLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *emailField;
@property (weak, nonatomic) IBOutlet UILabel *loginField;
@property (weak, nonatomic) IBOutlet UILabel *domainField;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionNameLabel;

@end

@implementation AboutViewController

@synthesize canvasAPI = _canvasAPI;

- (id)init {
    return [[UIStoryboard storyboardWithName:@"AboutViewController" bundle:[NSBundle bundleForClass:[self class]]] instantiateViewControllerWithIdentifier:@"AboutViewController"];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    [self updateForUser];
    
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString = [NSString stringWithFormat:@"v %@ (%@)", bundleInfo[@"CFBundleShortVersionString"], bundleInfo[@"CFBundleVersion"]];
    self.versionLabel.text = versionString;
    
    self.versionNameLabel.text = bundleInfo[@"VersionName"];

    NSBundle *techDebtBundle = [NSBundle bundleForClass:AboutViewController.self];
    self.title = NSLocalizedStringFromTableInBundle(@"About", nil, techDebtBundle, @"Name of a tab displaying Canvas Info including legal info");
    self.user = self.canvasAPI.user;
    [self localizeLabels];
}

- (void)localizeLabels {
    NSBundle *bundle = [NSBundle bundleForClass:AboutViewController.self];
    [self.nameLabel setText:NSLocalizedStringFromTableInBundle(@"Name", nil, bundle, @"the users name")];
    [self.emailLabel setText:NSLocalizedStringFromTableInBundle(@"Email", nil, bundle, @"the users email")];
    [self.loginIDLabel setText:NSLocalizedStringFromTableInBundle(@"Login ID", nil, bundle, @"Typically the email address correlated to the user")];
    [self.domainLabel setText:NSLocalizedStringFromTableInBundle(@"Domain", nil, bundle, @"The domain for the institution/school that the user is currently using")];
    [self.privacyPolicyLabel setText:NSLocalizedStringFromTableInBundle(@"Privacy Policy", nil, bundle, @"Link to the privacy policy")];
    [self.termsOfUseLabel setText:NSLocalizedStringFromTableInBundle(@"Terms of Use", nil, bundle, @"Link to the Terms of Use")];
    [self.openSourceLabel setText:NSLocalizedStringFromTableInBundle(@"Open Source Components", nil, bundle, @"Link to Open Source Components")];
    [self.subscribeCalendarLabel setText:NSLocalizedStringFromTableInBundle(@"Subscribe to calendar feed", nil, bundle, @"Subscribe to calendar feed allows the user to export their calendar events to a 3rd party calendar")];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect bounds = self.tableView.bounds;
    CGFloat footerHeight = self.footerView.bounds.size.height;
    CGFloat contentHeight = MAX(bounds.size.height - self.tableView.contentInset.top, self.tableView.contentSize.height);
    CGFloat surprise = 30;
    CGFloat minY = contentHeight - footerHeight;
    CGFloat maxY = CGRectGetMaxY(bounds) - footerHeight - surprise;
    CGFloat originY = MAX(minY, maxY);
    CGRect frame = self.footerView.frame;
    frame.origin.y = originY;
    self.footerView.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - User
- (CKCanvasAPI *)canvasAPI {
    return _canvasAPI;
}

- (void)setCanvasAPI:(CKCanvasAPI *)canvasAPI {
    _canvasAPI = canvasAPI;
    [self setUser:_canvasAPI.user];
}

- (void)setUser:(CKUser *)user {
    _user = user;
    [self updateForUser];
}

- (void)updateForUser {
    self.nameField.text = self.user.displayName;
    self.emailField.text = self.user.primaryEmail;
    self.loginField.text = self.user.loginId;
    self.domainField.text = [self.canvasAPI hostname];
    self.title = self.user.displayName;
    if (![self isPersonalProfile]) {
        self.nameField.enabled = NO;
        self.emailField.enabled = NO;
        self.loginField.enabled = NO;
        self.domainField.enabled = NO;
    }
}

- (BOOL)isPersonalProfile {
    return [self.user isEqual:self.canvasAPI.user];
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    switch (section) {
        case InfoSection:
            return NSLocalizedStringFromTableInBundle(@"User Info", nil, bundle, @"Title for User Info section on the about page");
            break;
        case LegalSection:
            return NSLocalizedStringFromTableInBundle(@"Legal", nil, bundle, @"Title for legal section on the about page");
            break;
        default:
            break;
    }
    
    return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect cellRect = cell.bounds;
    UIView *backgroundView = [[UIView alloc] initWithFrame:cellRect];
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cellRect];
    
    if (indexPath.section == SubscribeSection) {
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        [label setTextColor:Brand.current.tintColor];
        [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    else if (indexPath.section == InfoSection){
        backgroundView.backgroundColor = [UIColor prettyLightGray];
        selectedBackgroundView.backgroundColor = Brand.current.tintColor;
    }
    else{
        backgroundView.backgroundColor = [UIColor whiteColor];
        selectedBackgroundView.backgroundColor = Brand.current.tintColor;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    
    cell.backgroundView = backgroundView;
    cell.selectedBackgroundView = selectedBackgroundView;
    
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == InfoSection) {
        return NO;
    }
    return YES;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == SubscribeSection) {
        return nil;
    }

    CGFloat headerWidth = tableView.bounds.size.width;
    CGFloat headerHeight = 38;
    
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWidth, headerHeight)];
    [header setBackgroundColor:[UIColor clearColor]];
    
    UIView *backgroundColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWidth, headerHeight)];
    [header addSubview:backgroundColorView];
    
    // Prepare label
    int labelBuffer = 10;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelBuffer, labelBuffer, headerWidth - (labelBuffer * 2), headerHeight - (labelBuffer * 2) + 5)];
    label.numberOfLines = 0;
    label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    [backgroundColorView addSubview:label];
    
    return header;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == LegalSection) {
        
        if (indexPath.row == OpenSourceRow) {
            OSSAttributionViewController *viewController = [OSSAttributionViewController new];
            [self.navigationController pushViewController:viewController animated:YES];
            return;
        }
        
        NSString *urlAddress = @"";
        
        if (indexPath.row == TermsRow) {
            return [[HelmManager shared]
                pushFrom: @"/profile/settings"
                destinationModule: @"/accounts/:accountID/terms_of_service"
                withProps: @{ @"accountID": @"self" }
                options: @{}
                callback: nil
            ];
        }

        if (indexPath.row == PrivacyRow) {
            urlAddress = @"https://www.instructure.com/policies/privacy/";
        }
        
        NSURL *url = [NSURL URLWithString:urlAddress];
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:url];
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    }
    if (indexPath.section == SubscribeSection){
        [self addCalendar:nil];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == InfoSection || section == LegalSection) {
        return 40;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == InfoSection){
        return 20.0;
    }
    if (section == SubscribeSection) {
        return 0;
    }
    return 10.0;
}

#pragma mark - Actions

- (void)addCalendar:(id)sender {
    
    CKUser *user = self.canvasAPI.user;
    NSURL *calendarURL = user.calendarURL;
    
    NSMutableString *mutableURLStr = [[calendarURL absoluteString] mutableCopy];
    [mutableURLStr replaceOccurrencesOfString:@"http://" withString:@"caldav://" options:0 range:NSMakeRange(0, mutableURLStr.length)];
    
    NSURL *caldavURL = [NSURL URLWithString:mutableURLStr];
    [[UIApplication sharedApplication] openURL:caldavURL options:@{} completionHandler:nil];
}

@end
