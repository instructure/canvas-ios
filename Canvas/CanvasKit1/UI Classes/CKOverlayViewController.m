//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "CKOverlayViewController.h"


@interface CKOverlayView : UIView
@end

@implementation CKOverlayView

- (BOOL)accessibilityPerformEscape {
    return [self.nextResponder accessibilityPerformEscape];
}

@end

@implementation CKOverlayViewController {
    UIView *floatingView;
    
    CGFloat effectiveBottom;
    id keyboardShowObserver;
    id keyboardHideObserver;
}
@synthesize canTapBackgroundToDismiss = _canTapBackgroundToDismiss;
@synthesize viewPosition = _viewPosition;

- (id)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        floatingView = view;
        _viewPosition = CKOverlayViewPositionMiddle;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //TODO I think this line is unnecessary in iOS 7, remove it if that is the case
        //self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)loadView {
    UIView *overlay = [[CKOverlayView alloc] init];
    overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    if (_canTapBackgroundToDismiss) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        tap.delaysTouchesEnded = NO;
        tap.cancelsTouchesInView = NO;
        [overlay addGestureRecognizer:tap];
    }
    floatingView.accessibilityViewIsModal = YES;
    
    self.view = overlay;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self startObservingKeyboard];
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopObservingKeyboard];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void)viewDidLayoutSubviews {
    if (floatingView.superview == nil) {
        effectiveBottom = CGRectGetMaxY(self.view.bounds);
        [self updateFloatingViewPosition];
        floatingView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleBottomMargin |
                                         UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin);
        [self.view addSubview:floatingView];
    }
}

- (void)updateFloatingViewPosition {
    CGRect frame = floatingView.frame;
    switch (_viewPosition) {
        case CKOverlayViewPositionTop:
        {
            CGFloat top = 0;
            if ([[UIApplication sharedApplication] isStatusBarHidden] == NO) {
                CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
                top  = statusBarFrame.size.height;
            }
            frame = CGRectWithMinY(frame, top);
            break;
        }
             
            
        case CKOverlayViewPositionMiddle:
            frame = CGRectWithCenter(frame, self.view.center);
            break;
            
        case CKOverlayViewPositionBottom:
            frame = CGRectWithMaxY(frame, CGRectGetMaxY(self.view.bounds));
            break;
    }
    if (CGRectGetMaxY(frame) > effectiveBottom) {
        frame = CGRectWithMaxY(frame, effectiveBottom);
    }
    floatingView.frame = frame;
}

- (void)dismiss:(UIGestureRecognizer *)sender {
    UIView *view = sender.view;
    if ([view hitTest:[sender locationInView:view] withEvent:nil] == view) {
        [self.parentViewController dismissOverlayController];
    }
}

static CGRect CGRectWithCenter(CGRect input, CGPoint center) {
    CGSize size = input.size;
    input.origin.x = center.x - size.width / 2.0;
    input.origin.y = center.y - size.height / 2.0;
    return input;
}

static CGRect CGRectWithMaxY(CGRect input, CGFloat maxY) {
    CGSize size = input.size;
    input.origin.y = maxY - size.height;
    return input;
}

static CGRect CGRectWithMinY(CGRect input, CGFloat minY) {;
    input.origin.y = minY;
    return input;
}

- (void)startObservingKeyboard {
    void (^keyboardFrameBlock)(NSNotification *) = ^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        
        CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
        
        keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
        CGFloat topOfKeyboard = CGRectGetMinY(keyboardFrame);
//        CGRect frame = floatingView.frame;
//        CGFloat bottomOfView = CGRectGetMaxY(frame);
        
        effectiveBottom = topOfKeyboard;
        
//        CGFloat overlapAmount = bottomOfView - topOfKeyboard;
//        
//        if (overlapAmount > 0) {
//            frame = CGRectWithMaxY(frame, topOfKeyboard);
//        }
//        else {
//            frame = CGRectWithCenter(frame, self.view.center);
//        }
//
        [UIView animateWithDuration:duration animations:^{
            [UIView setAnimationCurve:curve];
            [self updateFloatingViewPosition];
        }];
        
    };
    
    keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil
                                                                              queue:[NSOperationQueue mainQueue]
                                                                         usingBlock:keyboardFrameBlock];
    
    keyboardHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil
                                                                              queue:[NSOperationQueue mainQueue]
                                                                         usingBlock:keyboardFrameBlock];
}

- (void)stopObservingKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:keyboardHideObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:keyboardShowObserver];
}

- (void)dismissOverlayController {
    [self.parentViewController dismissOverlayController];
}

- (BOOL)accessibilityPerformEscape {
    [self dismissOverlayController];
    return YES;
}

@end

@implementation UIViewController (CKOverlayViewController) 

- (void)presentOverlayController:(CKOverlayViewController *)overlay {
    UIView *overlayView = overlay.view;
    overlayView.alpha = 0.0;
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    BOOL mustCallAppearance = !([self shouldAutomaticallyForwardAppearanceMethods] && [self shouldAutomaticallyForwardRotationMethods]);
#pragma GCC diagnostic pop
    
    if ([self respondsToSelector:@selector(shouldAutomaticallyForwardAppearanceMethods)]) {
        mustCallAppearance = [self shouldAutomaticallyForwardAppearanceMethods];
    }
    
    [self addChildViewController:overlay];
    
    if (mustCallAppearance) {
        [overlay viewWillAppear:YES];
    }
    
    overlayView.frame = self.view.bounds;
    overlayView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:overlayView];
    
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        overlayView.alpha = 1.0;
    }
     completion:^(BOOL finished) {
         if (mustCallAppearance) {
             [overlay viewDidAppear:YES];
         }
         [overlay didMoveToParentViewController:self];
     }];
}

- (void)dismissOverlayController {
    CKOverlayViewController *overlay = nil;
    for (UIViewController *controller in self.childViewControllers) {
        if ([controller isKindOfClass:[CKOverlayViewController class]]) {
            overlay = (id)controller;
            break;
        }
    }
    UIView *overlayView = overlay.view;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BOOL mustCallAppearance = !([self shouldAutomaticallyForwardAppearanceMethods] && [self shouldAutomaticallyForwardRotationMethods]);
#pragma clang diagnostic pop
    
    [overlay willMoveToParentViewController:nil];
    if (mustCallAppearance) {
        [overlay viewWillDisappear:YES];
    }
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        overlayView.alpha = 0.0;
    }
     completion:^(BOOL finished) {
         [overlayView removeFromSuperview];
         if (mustCallAppearance) {
             [overlay viewDidDisappear:YES];
         }
         [overlay removeFromParentViewController];
     }];
}

@end
