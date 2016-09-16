//
//  CKCrossfadingImageView.h
//  CanvasKit
//
//  Created by BJ Homer on 8/27/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKCrossfadingImageView : UIView

@property NSArray *animationImages;
@property CFTimeInterval animationDuration;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
