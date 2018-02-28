//
//  UIAlertController+Show.h
//  CanvasKit
//
//  Created by Layne Moseley on 2/20/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Show)

- (void)show;
- (void)show:(void(^)(void))completion;

// Shows an alert with a title, message and dismiss message
// The alert is shown on the next tick of the run loop, so you the caller can make any configurations if needed
+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message;

// Handler is called when the basic dismiss button is selected
+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message handler:(void(^)(void))handler;

@end
