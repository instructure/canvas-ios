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

#import "UnsupportedViewController.h"
#import "UIAlertController+TechDebt.h"

@import CanvasKit;
@import CanvasCore;

@interface UnsupportedViewController ()
@property (nonatomic, weak) IBOutlet UILabel *unsupportedLabel;
@property (strong, nonatomic) IBOutlet UIButton *openInSafariButton;
@end

@implementation UnsupportedViewController

- (id)init
{
    return [[UIStoryboard storyboardWithName:@"UnsupportedView" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.unsupportedLabel setText:[self messageForTab]];
    [self.openInSafariButton setTitle:NSLocalizedStringFromTableInBundle(@"Open in Safari", nil, [NSBundle bundleForClass:self.class], nil) forState:UIControlStateNormal];
    [self.openInSafariButton setTitleColor:Brand.current.linkColor forState:UIControlStateNormal];
}

- (IBAction)openInSafarButtonTouched:(id)sender
{
    if ([[UIApplication sharedApplication] canOpenURL:self.canvasURL]) {
        
        [[APIBridge shared] call:@"getAuthenticatedSessionURL" args: [NSArray arrayWithObjects: self.canvasURL.absoluteString, nil] callback:^(id  _Nullable response, NSError * _Nullable error) {
            
            NSURL *url = nil;
            if (error == nil && response != nil && [response isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = response;
                if ([[data allKeys] containsObject:@"session_url"]) {
                    NSString *sessionURL = data[@"session_url"];
                    url = [NSURL URLWithString:sessionURL];
                }
            }
            
            if (url == nil) {
                url = self.canvasURL;
            }
            
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }];
        
    } else {
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        [UIAlertController showAlertWithTitle:NSLocalizedStringFromTableInBundle(@"Whoops!", nil, bundle, "Error Title") message:NSLocalizedStringFromTableInBundle(@"There was a problem launching Safari", nil, bundle, nil)];
    }
}

- (NSString *)messageForTab
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *message;

    if ([self.tabName isEqualToString:@"Quizzes"] || [self.tabName isEqualToString:@"People"] || [self.tabName isEqualToString:@"External"] || [self.tabName isEqualToString:@"Modules"]) {
        message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%@ is coming soon!", nil, bundle, @"Message for unsupported tab coming soon"), self.tabName];
    } else {
        message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%@ is not currently supported.", nil, bundle, @"Message for unsupported tab"), self.tabName];
    }
    
    return message;
}

@end
