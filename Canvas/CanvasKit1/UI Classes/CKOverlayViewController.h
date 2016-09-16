//
//  CKOverlayViewController.h
//  CanvasKit
//
//  Created by BJ Homer on 4/25/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CKOverlayViewPositionTop,
    CKOverlayViewPositionMiddle,
    CKOverlayViewPositionBottom
    
} CKOverlayViewPosition;

@interface CKOverlayViewController : UIViewController
- (id)initWithView:(UIView *)view;

@property BOOL canTapBackgroundToDismiss;
@property CKOverlayViewPosition viewPosition;

@end


@interface UIViewController (CKOverlayViewController)

- (void)presentOverlayController:(CKOverlayViewController *)overlay;
- (void)dismissOverlayController;

@end