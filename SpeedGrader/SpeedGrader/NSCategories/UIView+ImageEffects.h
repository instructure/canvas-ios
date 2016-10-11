//
//  UIView+ImageEffects.h
//  Polling
//
//  Created by Miles Wright on 5/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ImageEffects)

- (UIImage *)blurredLightSnapshot;
- (UIImage *)blurredExtraLightSnapshot;
- (UIImage *)blurredDarkSnapshot;

- (UIImage *)getSnapshotImage;

@end
