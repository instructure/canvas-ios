//
//  ActionSheetWithBlocks.h
//  CanvasKit
//
//  Created by BJ Homer on 2/21/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const CKActionSheetDidShowNotification;

@interface CKActionSheetWithBlocks : UIActionSheet

- (id)initWithTitle:(NSString *)title;
- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))handler;
- (void)addCancelButtonWithTitle:(NSString *)title;

@property (copy) void (^dismissalBlock)(void);

@end