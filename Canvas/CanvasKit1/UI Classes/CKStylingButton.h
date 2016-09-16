//
//  CKStylingButton.h
//  CanvasKit
//
//  Created by Mark Suman on 2/16/11.
//  Copyright 2011 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    CKButtonStyleDefault,
    CKButtonStyleTextComment,
    CKButtonStyleMediaComment,
    CKButtonStyleVideoOverlay,
    CKButtonStyleLogin
} CKButtonStyle;

@interface CKStylingButton : UIButton

@property (nonatomic) CKButtonStyle style;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)initWithFrame:(CGRect)aFrame;

@end
