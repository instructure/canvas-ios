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

#import "UIAlertController+TechDebt.h"

@implementation UIAlertController (Show)

- (UIViewController *)topViewController {
    UIViewController *top = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (top.presentedViewController != nil) {
        top = top.presentedViewController;
    }
    
    return top;
}

- (void)show {
    [self show:nil];
}

- (void)show:(void(^)(void))completion {
    [[self topViewController] presentViewController:self animated:YES completion:completion];
}

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    return [self showAlertWithTitle:title message:message handler:nil];
}

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message handler:(void(^)(void))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"Dismiss button title") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (handler) {
            handler();
        }
    }]];
     
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
     
    return alert;
}

@end
