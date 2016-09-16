//
//  CKAlertViewWithBlocks.h
//  CanvasKit
//
//  Created by BJ Homer on 3/22/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKAlertViewWithBlocks : UIAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))handler;
- (void)addCancelButtonWithTitle:(NSString *)title;

#pragma mark Unavailable
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... UNAVAILABLE_ATTRIBUTE;

@end
