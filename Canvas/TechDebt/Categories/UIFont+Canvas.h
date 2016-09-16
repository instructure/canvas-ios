//
//  UIFont+Canvas.h
//  iCanvas
//
//  Created by Jason Larsen on 6/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Canvas)

#pragma mark - Font Generators
+ (UIFont *)canvasFontOfSize:(CGFloat)size;
+ (UIFont *)boldCanvasFontOfSize:(CGFloat)size;
+ (UIFont *)italicCanvasFontOfSize:(CGFloat)size;

#pragma mark - Predefined Fonts
+ (UIFont *)canvasHeaderFont; // 18pt regular
+ (UIFont *)canvasHeader2Font; // 13pt regular
+ (UIFont *)canvasHeader2BoldFont; // 13pt bold
+ (UIFont *)canvasSubHeaderFont; // 11pt bold;
+ (UIFont *)canvasFont; // 11 regular
+ (UIFont *)canvasSmallFont; // 9pt regular
@end
