//
//  UIColor+Canvas.h
//  iCanvas
//
//  Created by Jason Larsen on 5/15/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CBI_RGB(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]

@interface UIColor (Canvas)

- (UIColor *)colorByAdjustingBrightness:(CGFloat)adjustment;

+ (UIColor *)cbi_red;
+ (UIColor *)cbi_orange;
+ (UIColor *)cbi_gold;
+ (UIColor *)cbi_green;
+ (UIColor *)cbi_chartreuse;
+ (UIColor *)cbi_cyan;
+ (UIColor *)cbi_slate;
+ (UIColor *)cbi_blue;
+ (UIColor *)cbi_purple;
+ (UIColor *)cbi_violet;
+ (UIColor *)cbi_pink;
+ (UIColor *)cbi_hotPink;
+ (UIColor *)cbi_grey;
+ (UIColor *)cbi_dark_grey;
+ (UIColor *)cbi_black;
+ (UIColor *)cbi_dots;

#pragma mark - Legacy Colors
+ (UIColor *)canvasBlack;
+ (UIColor *)canvasGray29;
+ (UIColor *)canvasGray45;
+ (UIColor *)canvasGray59;
+ (UIColor *)canvasGray91;
+ (UIColor *)canvasGray147;
+ (UIColor *)canvasGray171;
+ (UIColor *)canvasGray203;
+ (UIColor *)canvasGray227;
+ (UIColor *)canvasGray238;
+ (UIColor *)canvasOffWhite; // gray243
+ (UIColor *)canvasOrange;
+ (UIColor *)canvasRed;
+ (UIColor *)canvasGreen;
+ (UIColor *)canvasBlue;
+ (UIColor *)canvasTableViewHeaderGray;
+ (UIColor *)canvasTintColor;

@end
