//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Dismiss", nil, [NSBundle bundleForClass:self.class], @"Dismiss button title") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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
