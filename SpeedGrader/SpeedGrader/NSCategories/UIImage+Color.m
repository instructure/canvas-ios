//
//  UIImage+Color.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/1/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [UIImage imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithGradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor size:(CGSize)size {

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    BOOL startOK, endOK;
    CGFloat r1,r2,g1,g2,b1,b2,a1,a2;
    
    startOK = [startColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    endOK = [endColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    size_t gradientNumberOfLocations = 2;
    CGFloat gradientLocations[2] = { 0.0, 1.0 };
    CGFloat gradientComponents[8] = { r1, g1, b1, a1,     // Start color
                                    r2, g2, b2, a2, };  // End color
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents (colorSpace, gradientComponents, gradientLocations, gradientNumberOfLocations);
    
    UIImage *image = [UIImage imageWithGradient:gradient size:size];
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

+ (UIImage *)imageWithGradientStartColor:(UIColor *)startColor centerColor:(UIColor *)centerColor endColor:(UIColor *)endColor size:(CGSize)size {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    BOOL startOK, endOK, centerOK;
    CGFloat r1,r2,r3,g1,g2,g3,b1,b2,b3,a1,a2,a3;
    
    startOK = [startColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    centerOK = [centerColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    endOK = [endColor getRed:&r3 green:&g3 blue:&b3 alpha:&a3];
    
    size_t gradientNumberOfLocations = 3;
    CGFloat gradientLocations[3] = { 0.0, 0.5, 1.0 };
    CGFloat gradientComponents[12] = { r1, g1, b1, a1,     // Start color
        r2, g2, b2, a2,     // Center Color
        r3, g3, b3, a3, };  // End color
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents (colorSpace, gradientComponents, gradientLocations, gradientNumberOfLocations);
    
    UIImage *image = [UIImage imageWithGradient:gradient size:size];
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

+ (UIImage *)imageWithGradient:(CGGradientRef)gradientRef size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawLinearGradient(context, gradientRef, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
