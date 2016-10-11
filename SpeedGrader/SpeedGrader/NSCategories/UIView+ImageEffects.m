//
//  UIView+ImageEffects.m
//  Polling
//
//  Created by Miles Wright on 5/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "UIView+ImageEffects.h"
#import "UIImage+ImageEffects.h"

@implementation UIView (ImageEffects)

- (UIImage *)blurredLightSnapshot
{
    UIImage *image = [self getSnapshotImage];
    UIImage *blurredImage = [image applyLightEffect];
    return blurredImage;
}

- (UIImage *)blurredExtraLightSnapshot
{
    UIImage *image = [self getSnapshotImage];
    UIImage *blurredImage = [image applyExtraLightEffect];
    return blurredImage;
}

- (UIImage *)blurredDarkSnapshot
{
    UIImage *image = [self getSnapshotImage];
    UIImage *blurredImage = [image applyDarkEffect];
    return blurredImage;
}

// Could add a tint version as well

- (UIImage *)getSnapshotImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end
