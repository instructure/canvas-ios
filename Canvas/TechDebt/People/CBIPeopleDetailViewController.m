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
#import "UIAlertController+TechDebt.h"
#import <CanvasKit/CKIConversationRecipient.h>
#import "CBIPeopleDetailViewController.h"
#import "CBIPeopleViewModel.h"
#import "CBIConversationStarter.h"
#import "UIView+Circular.h"
@import CanvasKeymaster;
@import CanvasCore;

@interface CBIPeopleDetailViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIButton *messageButton;
@property (nonatomic) PageViewEventLoggerLegacySupport * pageViewEventLog;
@end

@implementation CBIPeopleDetailViewController

- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"CBIPeopleDetail" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
    if(self) {
        _pageViewEventLog = [PageViewEventLoggerLegacySupport new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.avatarImageView makeViewCircular];
            RAC(self, avatarImageView.image) = RACObserve(self, viewModel.icon);
    RAC(self, nameLabel.text) = RACObserve(self, viewModel.model.name);
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    self.title = NSLocalizedStringFromTableInBundle(@"People", nil, bundle, nil);
    
    [self.messageButton setTitle:NSLocalizedStringFromTableInBundle(@"Send Message", nil, bundle, nil) forState:UIControlStateNormal];
    UITapGestureRecognizer *doubleTwoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(masqueradeAsUser)];
    doubleTwoFingerTap.numberOfTapsRequired = 2;
    doubleTwoFingerTap.numberOfTouchesRequired = 2;
    
    [self.view addGestureRecognizer:doubleTwoFingerTap];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pageViewEventLog start];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.pageViewEventLog stopWithEventName:[self.viewModel.model path]];
}

- (IBAction)sendMessagePressed
{
    CKIUser *user = self.viewModel.model;
    if (!user.context) {
        [self showMessageErrorAlert];
        return;
    }
    NSString *permissionsPath = [[[NSURL URLWithString:user.context.path] URLByAppendingPathComponent:@"permissions"] path];
    RACSignal *getPermissions = [[CKIClient currentClient] fetchResponseAtPath:permissionsPath parameters:nil modelClass:[CKIPermissions class] context:nil];
    [getPermissions subscribeNext:^(CKIPermissions *permissions) {
        if (permissions.sendMessages) {
            // there is a chance that the user id is an NSNumber instance through an obscure bug.
            NSString *userID = [NSString stringWithFormat:@"%@", user.id];
            CBIConversationRecipient *recipient = [[CBIConversationRecipient alloc] initWithName:user.name id:userID avatarURL:user.avatarURL.absoluteString];
            NSString *context = nil;
            if ([user.context isKindOfClass:[CKICourse class]]) {
                context = [NSString stringWithFormat:@"course_%@", [(CKICourse *)user.context id]];
            } else if ([user.context isKindOfClass:[CKIGroup class]]) {
                context = [NSString stringWithFormat:@"group_%@", [(CKIGroup *)user.context id]];
            }
            [CBIConversationStarter startAConversationWithRecipients:@[recipient] inContext:context];
        } else {
            [self showMessageErrorAlert];
        }
    } error:^(NSError * _Nullable error) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *title = NSLocalizedStringFromTableInBundle(@"Network Error", nil, bundle, nil);
        NSString *message = NSLocalizedStringFromTableInBundle(@"Something went wrong. Please try again.", nil, bundle, nil);
        [UIAlertController showAlertWithTitle:title message:message];
    }];
}

- (void)showMessageErrorAlert
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *title = NSLocalizedStringFromTableInBundle(@"Permission Denied", nil, bundle, nil);
    NSString *message = NSLocalizedStringFromTableInBundle(@"You are not allowed to send messages at this time.", nil, bundle, nil);
    [UIAlertController showAlertWithTitle:title message:message];
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [self.messageButton isFirstResponder];
}

#pragma mark - Masquerade

- (void)masqueradeAsUser
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Do you want to masquerade as this user?", nil, bundle, "Alert title asking if you want to masquerade") message:nil preferredStyle:UIAlertControllerStyleAlert];

    @weakify(self);
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Masquerade", nil, bundle, "Button title for beginning masquerading") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self masquerade:self.viewModel.model.id];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, bundle, "Cancel button title") style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void)masquerade:(NSString *)masqueradeAs
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    if (masqueradeAs.length > 0) {
        [[TheKeymaster masqueradeAsUserWithID:masqueradeAs] subscribeNext:^(id client) {
            NSString *title = NSLocalizedStringFromTableInBundle(@"Success!", nil, bundle, @"Masquerade success title");
            NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"You are now masquerading as %@. To Stop Masquerading go to your Profile.", nil, bundle, @"Masquerade success message"), [CKIClient currentClient].currentUser.name];
            [UIAlertController showAlertWithTitle:title message:message];
        } error:^(NSError *error) {
            NSString *title = NSLocalizedStringFromTableInBundle(@"Oops!", nil, bundle, @"Title for an error alert");
            NSString *message = NSLocalizedStringFromTableInBundle(@"You don't have permission to masquerade as this user or there is no user with that ID", nil, bundle, @"Masquerade error message");
            [UIAlertController showAlertWithTitle:title message:message];
        }];
    }
}

@end
