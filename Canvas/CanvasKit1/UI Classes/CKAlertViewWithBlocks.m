//
//  CKAlertViewWithBlocks.m
//  CanvasKit
//
//  Created by BJ Homer on 3/22/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKAlertViewWithBlocks.h"

@interface CKAlertViewWithBlocks () <UIAlertViewDelegate>
@end

@implementation CKAlertViewWithBlocks {
    NSMutableDictionary *blocks;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        blocks = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))handler {
    int buttonIndex = [self addButtonWithTitle:title];
    NSNumber *buttonNumber = @(buttonIndex);
    
    blocks[buttonNumber] = [handler copy];
}


- (void)addCancelButtonWithTitle:(NSString *)title {
    int buttonIndex = [self addButtonWithTitle:title];
    self.cancelButtonIndex = buttonIndex;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSNumber *indexNumber = @(buttonIndex);
    
    void (^block)(void) = blocks[indexNumber];
    
    if (block) {
        block();
    }
    [blocks removeAllObjects];
}

@end
