
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
#import <CanvasKit1/CKAlertViewWithBlocks.h>
#import <CanvasKit/CKIConversationRecipient.h>
#import "CBIPeopleDetailViewController.h"
#import "CBIPeopleViewModel.h"
#import "CBIConversationStarter.h"
#import "UIView+Circular.h"
@import CanvasKeymaster;
#import "CBILog.h"

@interface CBIPeopleDetailViewController () <UIGestureRecognizerDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIButton *messageButton;
@end

@implementation CBIPeopleDetailViewController

- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"CBIPeopleDetail" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.avatarImageView makeViewCircular];
            RAC(self, avatarImageView.image) = RACObserve(self, viewModel.icon);
    RAC(self, nameLabel.text) = RACObserve(self, viewModel.model.name);
    self.title = NSLocalizedString(@"People", nil);
    
    [self.messageButton setTitle:NSLocalizedString(@"Send Message", nil) forState:UIControlStateNormal];
    UITapGestureRecognizer *doubleTwoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(masqueradeAsUser)];
    doubleTwoFingerTap.numberOfTapsRequired = 2;
    doubleTwoFingerTap.numberOfTouchesRequired = 2;
    
    [self.view addGestureRecognizer:doubleTwoFingerTap];
}

- (IBAction)sendMessagePressed
{
    CKIUser *user = self.viewModel.model;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *userID = [numberFormatter numberFromString:user.id];
    CKIConversationRecipient *recipient = [CKIConversationRecipient modelFromJSONDictionary:@{@"id": userID, @"name": user.name}];
    [[CBIConversationStarter sharedConversationStarter] startAConversationWithRecipients:@[recipient]];
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [self.messageButton isFirstResponder];
}

#pragma mark - Masquerade

- (void)masqueradeAsUser
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Do you want to masquerade as this user?", "Alert title asking if you want to masquerade") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", "Cancel button title") otherButtonTitles:NSLocalizedString(@"Masquerade", "Button title for beginning masquerading"), nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0: //cancel
            DDLogVerbose(@"masqueradeAsUserCancelled");
            break;
        case 1: { //masquerade
            DDLogVerbose(@"masqueradeAsUserSubmit");
            [self masquerade:self.viewModel.model.id];
        } break;
        default:
            break;
    }
}

- (void)masquerade:(NSString *)masqueradeAs
{
    if (masqueradeAs.length > 0) {
        [[TheKeymaster masqueradeAsUserWithID:masqueradeAs] subscribeNext:^(id client) {
            DDLogVerbose(@"masqueradeAsUserSuccess : %@", [CKIClient currentClient].currentUser.id);
            CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:NSLocalizedString(@"Success!", @"Masquerade success title") message:[NSString stringWithFormat:NSLocalizedString(@"You are now masquerading as %@. To Stop Masquerading go to your Profile.", @"Masquerade success message"), [CKIClient currentClient].currentUser.name]];
            [alert addCancelButtonWithTitle:NSLocalizedString(@"OK", nil)];
            [alert show];
        } error:^(NSError *error) {
            DDLogVerbose(@"masqueradeAsUserError : %@", [error localizedDescription]);
            
            CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:NSLocalizedString(@"Oops!", @"Title for an error alert") message:NSLocalizedString(@"You don't have permission to masquerade as this user or there is no user with that ID", @"Masquerade error message")];
            [alert addCancelButtonWithTitle:NSLocalizedString(@"OK", nil)];
            [alert show];
        }];
    }
}

@end
