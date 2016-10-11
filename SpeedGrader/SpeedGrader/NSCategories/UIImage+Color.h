//
//  UIImage+Color.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/1/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithGradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor size:(CGSize)size;
+ (UIImage *)imageWithGradientStartColor:(UIColor *)startColor centerColor:(UIColor *)centerColor endColor:(UIColor *)endColor size:(CGSize)size;
+ (UIImage *)imageWithGradient:(CGGradientRef)gradientRef size:(CGSize)size;

@end
