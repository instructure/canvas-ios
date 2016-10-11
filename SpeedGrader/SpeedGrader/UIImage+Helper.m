//
//  UIImage (Helper).m
//  SpeedGrader
//
//  Created by Nathan Lambson on 1/6/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import "UIImage+Helper.h"

@implementation UIImage (Helper)

+ (UIImage *)drawImage:(UIImage*)foregroundImage inImage:(UIImage*)backgroundImage atPoint:(CGPoint)point
{
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, FALSE, 0.0);
    [backgroundImage drawInRect:CGRectMake( 0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    [foregroundImage drawInRect:CGRectMake( point.x, point.y, foregroundImage.size.width, foregroundImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color
{
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

@end
