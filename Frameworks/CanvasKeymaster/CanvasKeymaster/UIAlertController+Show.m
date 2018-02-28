//
//  UIAlertController+Show.m
//  CanvasKit
//
//  Created by Layne Moseley on 2/20/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

#import "UIAlertController+Show.h"

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

@end
