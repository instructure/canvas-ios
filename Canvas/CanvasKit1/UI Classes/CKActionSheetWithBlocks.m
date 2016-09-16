//
//  CKActionSheetWithBlocks.m
//  CanvasKit
//
//  Created by BJ Homer on 2/21/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "CKActionSheetWithBlocks.h"

//External Constants
NSString * const CKActionSheetDidShowNotification = @"CKAlertViewDidShowNotification";

@interface CKActionSheetWithBlocks () <UIActionSheetDelegate>
@end

@implementation CKActionSheetWithBlocks {
    NSMutableDictionary *blocks;
}

@synthesize dismissalBlock;

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        blocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    [super showInView:view];
    [[NSNotificationCenter defaultCenter] postNotificationName:CKActionSheetDidShowNotification object:self];
}

- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))handler {
    NSInteger buttonIndex = [super addButtonWithTitle:title];
    if (handler) {
        blocks[@(buttonIndex)] = [handler copy];
    }
}

- (void)addCancelButtonWithTitle:(NSString *)title {
    NSInteger buttonIndex = [super addButtonWithTitle:title];
    self.cancelButtonIndex = buttonIndex;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    void (^handler)(void) = blocks[@(buttonIndex)];
    if (handler) {
        handler();
    }
    [blocks removeAllObjects];
    
    if (dismissalBlock) {
        dismissalBlock();
    }
}

@end
