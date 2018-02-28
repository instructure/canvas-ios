//
//  UIAlertController+Show.m
//  CanvasKit
//
//  Created by Layne Moseley on 2/20/18.
//  Copyright © 2018 Instructure. All rights reserved.
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
