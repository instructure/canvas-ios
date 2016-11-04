
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
    
    

#import "UnsupportedViewController.h"


#import "UIViewController+AnalyticsTracking.h"
#import "CBILog.h"

@import CanvasKit;
@import CanvasKeymaster;

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
    [self.openInSafariButton setTitle:NSLocalizedString(@"Open in Safari", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DDLogVerbose(@"%@ - viewDidAppear : %@", NSStringFromClass([self class]), self.tabName);
}

- (IBAction)openInSafarButtonTouched:(id)sender
{
    DDLogVerbose(@"openInSafarButtonTouched : %@", self.tabName);
    if ([[UIApplication sharedApplication] canOpenURL:self.canvasURL]) {
        [[UIApplication sharedApplication] openURL:self.canvasURL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Whoops!", "Error Title") message:NSLocalizedString(@"There was a problem launching Safari",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alertView show];
    }
}

- (NSString *)messageForTab
{
    NSString *message;
    
    if ([self.tabName isEqualToString:@"Quizzes"] || [self.tabName isEqualToString:@"People"] || [self.tabName isEqualToString:@"External"] || [self.tabName isEqualToString:@"Modules"]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"%@ is coming soon!", @"Message for unsupported tab coming soon"), self.tabName];
    } else {
        message = [NSString stringWithFormat:NSLocalizedString(@"%@ is not currently supported.", @"Message for unsupported tab"), self.tabName];
    }
    
    return message;
}

@end
