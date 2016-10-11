//
//  UIImage (Helper).h
//  SpeedGrader
//
//  Created by Nathan Lambson on 1/6/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

+ (UIImage *)drawImage:(UIImage*)foregroundImage inImage:(UIImage*)backgroundImage atPoint:(CGPoint)point;
+ (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color;

@end
