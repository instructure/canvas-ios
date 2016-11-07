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
    
    

#import "CBINotificationMessageViewController.h"
@import CanvasKit;

@interface CBINotificationMessageViewController ()
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@end

@implementation CBINotificationMessageViewController

- (instancetype)init
{
    return self = [[UIStoryboard storyboardWithName:@"CBINotificationMessage" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupViewConstraints];

    RAC(self, messageLabel.text) = [RACObserve(self, streamItem.message) map:^id(NSString *message) {
        return [[[NSAttributedString alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil] string];
    }];
}

- (void)setupViewConstraints
{
    UIView *spacerView = [[UIView alloc] init];
    spacerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    spacerView.hidden = YES;
    [self.view insertSubview:spacerView belowSubview:self.messageLabel];
    UILabel *messageLabel = self.messageLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(spacerView, messageLabel);
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spacerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.33f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spacerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spacerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spacerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:spacerView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[messageLabel]-|" options:0 metrics:nil views:views]];
}

@end